# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::TimeAgo do
  let(:now) { Time.new(2026, 3, 21, 12, 0, 0) }

  it 'has a version number' do
    expect(Philiprehberger::TimeAgo::VERSION).not_to be_nil
  end

  describe '.format' do
    context 'with past timestamps (long style)' do
      it 'returns "just now" for less than 30 seconds' do
        expect(described_class.format(now - 10, relative_to: now)).to eq('just now')
      end

      it 'returns seconds ago for 30-59 seconds' do
        expect(described_class.format(now - 45, relative_to: now)).to eq('45 seconds ago')
      end

      it 'returns minutes ago' do
        expect(described_class.format(now - 180, relative_to: now)).to eq('3 minutes ago')
      end

      it 'returns "1 minute ago" for singular' do
        expect(described_class.format(now - 90, relative_to: now)).to eq('1 minute ago')
      end

      it 'returns hours ago' do
        expect(described_class.format(now - 7200, relative_to: now)).to eq('2 hours ago')
      end

      it 'returns "1 hour ago" for singular' do
        expect(described_class.format(now - 3600, relative_to: now)).to eq('1 hour ago')
      end

      it 'returns "yesterday" for 1 day ago' do
        expect(described_class.format(now - 86_400, relative_to: now)).to eq('yesterday')
      end

      it 'returns days ago for multiple days' do
        expect(described_class.format(now - (3 * 86_400), relative_to: now)).to eq('3 days ago')
      end

      it 'returns weeks ago' do
        expect(described_class.format(now - (2 * 604_800), relative_to: now)).to eq('2 weeks ago')
      end

      it 'returns months ago' do
        expect(described_class.format(now - (3 * 2_592_000), relative_to: now)).to eq('3 months ago')
      end

      it 'returns years ago' do
        expect(described_class.format(now - (2 * 31_536_000), relative_to: now)).to eq('2 years ago')
      end

      it 'returns "1 year ago" for singular' do
        expect(described_class.format(now - 31_536_000, relative_to: now)).to eq('1 year ago')
      end
    end

    context 'with future timestamps (long style)' do
      it 'returns "just now" for less than 30 seconds in the future' do
        expect(described_class.format(now + 10, relative_to: now)).to eq('just now')
      end

      it 'returns "in N seconds" for 30-59 seconds' do
        expect(described_class.format(now + 45, relative_to: now)).to eq('in 45 seconds')
      end

      it 'returns "in N minutes"' do
        expect(described_class.format(now + 300, relative_to: now)).to eq('in 5 minutes')
      end

      it 'returns "in N hours"' do
        expect(described_class.format(now + 7200, relative_to: now)).to eq('in 2 hours')
      end

      it 'returns "tomorrow" for 1 day in the future' do
        expect(described_class.format(now + 86_400, relative_to: now)).to eq('tomorrow')
      end
    end

    context 'with short style' do
      it 'returns "now" for less than 30 seconds' do
        expect(described_class.format(now - 10, style: :short, relative_to: now)).to eq('now')
      end

      it 'returns abbreviated seconds' do
        expect(described_class.format(now - 45, style: :short, relative_to: now)).to eq('45s ago')
      end

      it 'returns abbreviated minutes' do
        expect(described_class.format(now - 180, style: :short, relative_to: now)).to eq('3m ago')
      end

      it 'returns abbreviated hours' do
        expect(described_class.format(now - 7200, style: :short, relative_to: now)).to eq('2h ago')
      end

      it 'returns abbreviated days' do
        expect(described_class.format(now - (3 * 86_400), style: :short, relative_to: now)).to eq('3d ago')
      end

      it 'returns abbreviated weeks' do
        expect(described_class.format(now - (2 * 604_800), style: :short, relative_to: now)).to eq('2w ago')
      end

      it 'returns abbreviated future' do
        expect(described_class.format(now + 300, style: :short, relative_to: now)).to eq('in 5m')
      end
    end

    context 'with custom reference time' do
      it 'calculates relative to the given time' do
        reference = Time.new(2026, 3, 21, 14, 0, 0)
        target    = Time.new(2026, 3, 21, 12, 0, 0)

        expect(described_class.format(target, relative_to: reference)).to eq('2 hours ago')
      end
    end

    context 'with max_days' do
      it 'returns relative time within the threshold' do
        expect(described_class.format(now - (10 * 86_400), max_days: 30, relative_to: now)).to eq('1 week ago')
      end

      it 'returns absolute date beyond the threshold' do
        old_time = now - (60 * 86_400)
        result = described_class.format(old_time, max_days: 30, relative_to: now)
        expect(result).to match(/\A[A-Z][a-z]{2} \d{1,2}, \d{4}\z/)
      end

      it 'formats the fallback date correctly' do
        target = Time.new(2026, 1, 15, 10, 0, 0)
        expect(described_class.format(target, max_days: 30, relative_to: now)).to eq('Jan 15, 2026')
      end
    end

    context 'with edge cases' do
      it 'returns "just now" for exactly 0 seconds' do
        expect(described_class.format(now, relative_to: now)).to eq('just now')
      end

      it 'returns "just now" at the 29-second boundary' do
        expect(described_class.format(now - 29, relative_to: now)).to eq('just now')
      end

      it 'returns seconds at the 30-second boundary' do
        expect(described_class.format(now - 30, relative_to: now)).to eq('30 seconds ago')
      end

      it 'raises an error for non-Time input' do
        expect { described_class.format('not a time') }.to raise_error(Philiprehberger::TimeAgo::Error)
      end

      it 'raises an error for invalid style' do
        expect { described_class.format(now - 60, style: :invalid, relative_to: now) }
          .to raise_error(Philiprehberger::TimeAgo::Error)
      end
    end
  end

  describe '.format with precision' do
    it 'limits output to hour precision' do
      result = described_class.format(now - 5400, relative_to: now, precision: :hour)
      expect(result).to eq('1 hour ago')
    end

    it 'rounds to nearest precision unit' do
      result = described_class.format(now - 90, relative_to: now, precision: :minute)
      expect(result).to eq('1 minute ago')
    end

    it 'limits to day precision' do
      result = described_class.format(now - ((3 * 86_400) + 7200), relative_to: now, precision: :day)
      expect(result).to eq('3 days ago')
    end
  end

  describe '.format with max_units' do
    it 'shows single unit by default' do
      result = described_class.format(now - (3600 + 120), relative_to: now)
      expect(result).to eq('1 hour ago')
    end

    it 'shows multiple units when max_units > 1' do
      result = described_class.format(now - (3600 + 120), relative_to: now, max_units: 2)
      expect(result).to eq('1 hour 2 minutes ago')
    end

    it 'works with short style' do
      result = described_class.format(now - (3600 + 120), style: :short, relative_to: now, max_units: 2)
      expect(result).to eq('1h 2m ago')
    end

    it 'shows future with max_units' do
      result = described_class.format(now + (86_400 + 3600), relative_to: now, max_units: 2)
      expect(result).to eq('in 1 day 1 hour')
    end
  end

  describe '.duration_between' do
    it 'returns component hash' do
      t1 = Time.new(2026, 3, 21, 10, 0, 0)
      t2 = Time.new(2026, 3, 22, 12, 30, 45)
      result = described_class.duration_between(t1, t2)
      expect(result).to eq({ days: 1, hours: 2, minutes: 30, seconds: 45 })
    end

    it 'handles zero duration' do
      result = described_class.duration_between(now, now)
      expect(result).to eq({ days: 0, hours: 0, minutes: 0, seconds: 0 })
    end

    it 'is commutative' do
      t1 = Time.new(2026, 3, 21, 10, 0, 0)
      t2 = Time.new(2026, 3, 22, 12, 0, 0)
      expect(described_class.duration_between(t1, t2)).to eq(described_class.duration_between(t2, t1))
    end

    it 'raises Error for non-Time input' do
      expect { described_class.duration_between('not a time', now) }.to raise_error(described_class::Error)
    end
  end
end
