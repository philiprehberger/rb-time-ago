# frozen_string_literal: true

require_relative 'time_ago/version'

module Philiprehberger
  module TimeAgo
    class Error < StandardError; end

    SECONDS_PER_MINUTE = 60
    SECONDS_PER_HOUR   = 3600
    SECONDS_PER_DAY    = 86_400
    SECONDS_PER_WEEK   = 604_800
    SECONDS_PER_MONTH  = 2_592_000
    SECONDS_PER_YEAR   = 31_536_000

    UNITS = {
      year: SECONDS_PER_YEAR,
      month: SECONDS_PER_MONTH,
      week: SECONDS_PER_WEEK,
      day: SECONDS_PER_DAY,
      hour: SECONDS_PER_HOUR,
      minute: SECONDS_PER_MINUTE,
      second: 1
    }.freeze

    SHORT_LABELS = {
      year: 'y',
      month: 'mo',
      week: 'w',
      day: 'd',
      hour: 'h',
      minute: 'm',
      second: 's'
    }.freeze

    PRECISION_ORDER = %i[year month week day hour minute second].freeze

    DEFAULT_CONFIG = {
      just_now: 30
    }.freeze

    @config = DEFAULT_CONFIG.dup

    # Configure module-level thresholds
    #
    # @param options [Hash] configuration options
    # @option options [Integer] :just_now seconds threshold for "just now" (default 30)
    # @return [Hash] current configuration
    def self.configure(**options)
      options.each do |key, value|
        raise Error, "Unknown config option: #{key}" unless DEFAULT_CONFIG.key?(key)

        @config[key] = value
      end
      @config.dup
    end

    # Return the current configuration
    #
    # @return [Hash] current configuration
    def self.config
      @config.dup
    end

    # Reset configuration to defaults
    #
    # @return [Hash] default configuration
    def self.reset_config!
      @config = DEFAULT_CONFIG.dup
    end

    # Format a time as a human-readable relative string
    #
    # @param time [Time] the timestamp to format
    # @param style [Symbol] :long (default) or :short
    # @param relative_to [Time] reference time (default: Time.now)
    # @param max_days [Integer, nil] fallback to absolute date after this many days
    # @param precision [Symbol, nil] smallest unit to show (:year, :month, :week, :day, :hour, :minute, :second)
    # @param max_units [Integer, nil] maximum number of time components to show
    # @param compound [Boolean] show two units (e.g., "1 hour and 30 minutes ago")
    # @param approximate [Boolean] prefix with "about" (e.g., "about 2 hours ago")
    # @return [String] relative time string
    # @raise [Error] if time is not a Time object
    def self.format(time, style: :long, relative_to: Time.now, max_days: nil, precision: nil, max_units: nil,
                    compound: false, approximate: false)
      raise Error, 'Expected a Time object' unless time.is_a?(Time)
      raise Error, 'Expected relative_to to be a Time object' unless relative_to.is_a?(Time)

      diff = relative_to - time
      absolute_diff = diff.abs
      past = diff.positive?

      return time.strftime('%b %-d, %Y') if max_days && absolute_diff >= max_days * SECONDS_PER_DAY

      effective_max_units = compound ? 2 : max_units

      result = case style
               when :long  then format_long(absolute_diff, past, precision: precision, max_units: effective_max_units, compound: compound)
               when :short then format_short(absolute_diff, past, precision: precision, max_units: effective_max_units)
               else raise Error, "Unknown style: #{style}"
               end

      approximate ? add_approximate(result) : result
    end

    # Format a future time as a human-readable relative string (e.g., "in 3 minutes")
    #
    # This is the inverse of `format` for past times. While `format` with a past
    # timestamp returns "3 minutes ago", `until` with a future timestamp returns
    # "in 3 minutes".
    #
    # @param time [Time] the future timestamp to format
    # @param relative_to [Time] reference time (default: Time.now)
    # @return [String] relative future time string (e.g., "in 2 hours")
    # @raise [Error] if time is not a Time object
    # @raise [Error] if time is not in the future relative to relative_to
    def self.until(time, relative_to: Time.now)
      raise Error, 'Expected a Time object' unless time.is_a?(Time)
      raise Error, 'Expected relative_to to be a Time object' unless relative_to.is_a?(Time)
      raise Error, 'Expected a future time' unless time > relative_to

      format(time, relative_to: relative_to)
    end

    # Format a raw number of seconds as duration words without "ago"/"from now"
    #
    # @param seconds [Numeric] number of seconds to format
    # @param compound [Boolean] show two units (default false)
    # @return [String] duration string (e.g., "5 minutes", "2 hours and 30 minutes")
    def self.in_words(seconds)
      raise Error, 'Expected a Numeric value' unless seconds.is_a?(Numeric)

      absolute = seconds.abs

      if absolute < @config[:just_now]
        count = absolute.floor
        return count == 1 ? '1 second' : "#{count} seconds"
      end

      parts = decompose(absolute, precision: nil, max_units: 2)
      if parts.length > 1
        labels = parts.map { |unit, count| "#{count} #{count == 1 ? unit : "#{unit}s"}" }
        "#{labels[0]} and #{labels[1]}"
      else
        unit, count = parts.first
        "#{count} #{count == 1 ? unit : "#{unit}s"}"
      end
    end

    # Return relative time if within threshold, otherwise formatted absolute date
    #
    # @param time [Time] the timestamp
    # @param threshold [Integer] seconds threshold for relative display (default 86400)
    # @param format [String] strftime format for absolute date (default '%b %d, %Y')
    # @param relative_to [Time] reference time (default: Time.now)
    # @return [String] relative or absolute time string
    def self.auto(time, threshold: 86_400, format: '%b %d, %Y', relative_to: Time.now)
      raise Error, 'Expected a Time object' unless time.is_a?(Time)

      diff = (relative_to - time).abs

      if diff < threshold
        self.format(time, relative_to: relative_to)
      else
        time.strftime(format)
      end
    end

    # True when `time` is strictly after `relative_to`.
    #
    # @param time [Time, DateTime, Integer] timestamp (Integer is epoch seconds)
    # @param relative_to [Time] reference time, defaults to now
    # @return [Boolean]
    def self.future?(time, relative_to: Time.now)
      coerce_time(time) > relative_to
    end

    # True when `time` is strictly before `relative_to`.
    #
    # @param time [Time, DateTime, Integer] timestamp (Integer is epoch seconds)
    # @param relative_to [Time] reference time, defaults to now
    # @return [Boolean]
    def self.past?(time, relative_to: Time.now)
      coerce_time(time) < relative_to
    end

    # Return a structured hash of time components between two times
    #
    # @param time1 [Time] first timestamp
    # @param time2 [Time] second timestamp
    # @return [Hash] { days:, hours:, minutes:, seconds: }
    def self.duration_between(time1, time2)
      raise Error, 'Expected Time objects' unless time1.is_a?(Time) && time2.is_a?(Time)

      total = (time2 - time1).abs.to_i
      days = total / SECONDS_PER_DAY
      remaining = total % SECONDS_PER_DAY
      hours = remaining / SECONDS_PER_HOUR
      remaining %= SECONDS_PER_HOUR
      minutes = remaining / SECONDS_PER_MINUTE
      seconds = remaining % SECONDS_PER_MINUTE

      { days: days, hours: hours, minutes: minutes, seconds: seconds }
    end

    # @api private
    def self.format_long(seconds, past, precision: nil, max_units: nil, compound: false)
      return 'just now' if seconds < @config[:just_now]

      if seconds >= SECONDS_PER_DAY && seconds < 2 * SECONDS_PER_DAY && precision.nil? && max_units.nil?
        return past ? 'yesterday' : 'tomorrow'
      end

      if max_units && max_units > 1
        parts = decompose(seconds, precision: precision, max_units: max_units)
        if compound
          labels = parts.map { |unit, count| "#{count} #{count == 1 ? unit : "#{unit}s"}" }
          label = labels.length > 1 ? "#{labels[0]} and #{labels[1]}" : labels[0]
        else
          label = parts.map { |unit, count| "#{count} #{count == 1 ? unit : "#{unit}s"}" }.join(' ')
        end
        return past ? "#{label} ago" : "in #{label}"
      end

      unit, count = resolve_unit(seconds, precision: precision)
      unit_str = count == 1 ? unit.to_s : "#{unit}s"

      past ? "#{count} #{unit_str} ago" : "in #{count} #{unit_str}"
    end

    # @api private
    def self.format_short(seconds, past, precision: nil, max_units: nil)
      return 'now' if seconds < @config[:just_now]

      if max_units && max_units > 1
        parts = decompose(seconds, precision: precision, max_units: max_units)
        label = parts.map { |unit, count| "#{count}#{SHORT_LABELS[unit]}" }.join(' ')
        return past ? "#{label} ago" : "in #{label}"
      end

      unit, count = resolve_unit(seconds, precision: precision)
      label = "#{count}#{SHORT_LABELS[unit]}"

      past ? "#{label} ago" : "in #{label}"
    end

    # @api private
    def self.add_approximate(result)
      return result if ['just now', 'now'].include?(result)

      if result.start_with?('in ')
        "in about #{result[3..]}"
      else
        "about #{result}"
      end
    end

    # @api private
    def self.resolve_unit(seconds, precision: nil)
      min_threshold = precision ? UNITS.fetch(precision, 1) : 1

      UNITS.each do |unit, threshold|
        next if seconds < threshold
        next if threshold < min_threshold

        return [unit, (seconds / threshold).floor]
      end

      [:second, seconds.floor]
    end

    # @api private
    def self.decompose(seconds, precision: nil, max_units: nil)
      min_threshold = precision ? UNITS.fetch(precision, 1) : 1
      remaining = seconds
      parts = []

      UNITS.each do |unit, threshold|
        break if max_units && parts.length >= max_units
        next if threshold < min_threshold
        next if remaining < threshold

        count = (remaining / threshold).floor
        remaining -= count * threshold
        parts << [unit, count]
      end

      parts = [[:second, seconds.floor]] if parts.empty?
      parts
    end

    # Format a raw number of seconds as a human-readable duration string
    #
    # Unlike `format`, this method produces a directionless duration (no "ago" / "in").
    # Unlike `in_words`, it supports all formatting options (style, precision, etc.).
    #
    # @param seconds [Numeric] number of seconds to format
    # @param style [Symbol] :long (default) or :short
    # @param precision [Symbol, nil] smallest unit to show (:year, :month, :week, :day, :hour, :minute, :second)
    # @param max_units [Integer] maximum number of time components to show (default 2)
    # @param compound [Boolean] join units with "and" (default true)
    # @param approximate [Boolean] prefix with "about" (default false)
    # @return [String] duration string (e.g., "1 hour and 30 minutes")
    # @raise [Error] if seconds is not Numeric
    def self.format_duration(seconds, style: :long, precision: nil, max_units: 2, compound: true, approximate: false)
      raise Error, 'Expected a Numeric value' unless seconds.is_a?(Numeric)

      absolute = seconds.abs

      if absolute < @config[:just_now]
        count = absolute.floor
        result = case style
                 when :long  then count == 1 ? '1 second' : "#{count} seconds"
                 when :short then "#{count}s"
                 else raise Error, "Unknown style: #{style}"
                 end
        return approximate ? "about #{result}" : result
      end

      parts = decompose(absolute, precision: precision, max_units: max_units)

      result = case style
               when :long  then format_duration_long(parts, compound: compound)
               when :short then parts.map { |unit, count| "#{count}#{SHORT_LABELS[unit]}" }.join(' ')
               else raise Error, "Unknown style: #{style}"
               end

      approximate ? "about #{result}" : result
    end

    # @api private
    def self.format_duration_long(parts, compound:)
      labels = parts.map { |unit, count| "#{count} #{count == 1 ? unit : "#{unit}s"}" }

      return labels[0] if labels.length == 1

      if compound
        if labels.length == 2
          "#{labels[0]} and #{labels[1]}"
        else
          "#{labels[0..-2].join(', ')}, and #{labels[-1]}"
        end
      else
        labels.join(' ')
      end
    end

    # @api private
    def self.coerce_time(time)
      case time
      when Time then time
      when Integer then Time.at(time)
      else
        return time.to_time if time.respond_to?(:to_time)

        raise Error, 'Expected a Time, DateTime, or Integer'
      end
    end

    private_class_method :format_long, :format_short, :resolve_unit, :decompose, :add_approximate,
                         :format_duration_long, :coerce_time
  end
end
