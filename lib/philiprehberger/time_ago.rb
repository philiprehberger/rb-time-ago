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

    # Format a time as a human-readable relative string
    #
    # @param time [Time] the timestamp to format
    # @param style [Symbol] :long (default) or :short
    # @param relative_to [Time] reference time (default: Time.now)
    # @param max_days [Integer, nil] fallback to absolute date after this many days
    # @param precision [Symbol, nil] smallest unit to show (:year, :month, :week, :day, :hour, :minute, :second)
    # @param max_units [Integer, nil] maximum number of time components to show
    # @return [String] relative time string
    # @raise [Error] if time is not a Time object
    def self.format(time, style: :long, relative_to: Time.now, max_days: nil, precision: nil, max_units: nil)
      raise Error, 'Expected a Time object' unless time.is_a?(Time)
      raise Error, 'Expected relative_to to be a Time object' unless relative_to.is_a?(Time)

      diff = relative_to - time
      absolute_diff = diff.abs
      past = diff.positive?

      return time.strftime('%b %-d, %Y') if max_days && absolute_diff >= max_days * SECONDS_PER_DAY

      case style
      when :long  then format_long(absolute_diff, past, precision: precision, max_units: max_units)
      when :short then format_short(absolute_diff, past, precision: precision, max_units: max_units)
      else raise Error, "Unknown style: #{style}"
      end
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
    def self.format_long(seconds, past, precision: nil, max_units: nil)
      return 'just now' if seconds < 30

      if seconds >= SECONDS_PER_DAY && seconds < 2 * SECONDS_PER_DAY && precision.nil? && max_units.nil?
        return past ? 'yesterday' : 'tomorrow'
      end

      if max_units && max_units > 1
        parts = decompose(seconds, precision: precision, max_units: max_units)
        label = parts.map { |unit, count| "#{count} #{count == 1 ? unit : "#{unit}s"}" }.join(' ')
        return past ? "#{label} ago" : "in #{label}"
      end

      unit, count = resolve_unit(seconds, precision: precision)
      unit_str = count == 1 ? unit.to_s : "#{unit}s"

      past ? "#{count} #{unit_str} ago" : "in #{count} #{unit_str}"
    end

    # @api private
    def self.format_short(seconds, past, precision: nil, max_units: nil)
      return 'now' if seconds < 30

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

    private_class_method :format_long, :format_short, :resolve_unit, :decompose
  end
end
