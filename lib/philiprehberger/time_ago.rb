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

    # Format a time as a human-readable relative string
    #
    # @param time [Time] the timestamp to format
    # @param style [Symbol] :long (default) or :short
    # @param relative_to [Time] reference time (default: Time.now)
    # @param max_days [Integer, nil] fallback to absolute date after this many days
    # @return [String] relative time string
    # @raise [Error] if time is not a Time object
    def self.format(time, style: :long, relative_to: Time.now, max_days: nil)
      raise Error, 'Expected a Time object' unless time.is_a?(Time)
      raise Error, 'Expected relative_to to be a Time object' unless relative_to.is_a?(Time)

      diff = relative_to - time
      absolute_diff = diff.abs
      past = diff.positive?

      if max_days && absolute_diff >= max_days * SECONDS_PER_DAY
        return time.strftime('%b %-d, %Y')
      end

      case style
      when :long  then format_long(absolute_diff, past)
      when :short then format_short(absolute_diff, past)
      else raise Error, "Unknown style: #{style}"
      end
    end

    # @api private
    def self.format_long(seconds, past)
      return 'just now' if seconds < 30

      if seconds >= SECONDS_PER_DAY && seconds < 2 * SECONDS_PER_DAY
        return past ? 'yesterday' : 'tomorrow'
      end

      unit, count = resolve_unit(seconds)
      unit_str = count == 1 ? unit.to_s : "#{unit}s"

      past ? "#{count} #{unit_str} ago" : "in #{count} #{unit_str}"
    end

    # @api private
    def self.format_short(seconds, past)
      return 'now' if seconds < 30

      unit, count = resolve_unit(seconds)
      label = "#{count}#{SHORT_LABELS[unit]}"

      past ? "#{label} ago" : "in #{label}"
    end

    # @api private
    def self.resolve_unit(seconds)
      UNITS.each do |unit, threshold|
        next if seconds < threshold

        return [unit, (seconds / threshold).floor]
      end

      [:second, 0]
    end

    private_class_method :format_long, :format_short, :resolve_unit
  end
end
