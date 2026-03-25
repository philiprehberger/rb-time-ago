# philiprehberger-time_ago

[![Tests](https://github.com/philiprehberger/rb-time-ago/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-time-ago/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-time_ago.svg)](https://rubygems.org/gems/philiprehberger-time_ago)
[![License](https://img.shields.io/github/license/philiprehberger/rb-time-ago)](LICENSE)

Relative time formatting for past and future timestamps

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-time_ago"
```

Or install directly:

```bash
gem install philiprehberger-time_ago
```

## Usage

```ruby
require "philiprehberger/time_ago"

Philiprehberger::TimeAgo.format(Time.now - 180)   # => "3 minutes ago"
Philiprehberger::TimeAgo.format(Time.now - 7200)  # => "2 hours ago"
```

### Short Format

```ruby
Philiprehberger::TimeAgo.format(Time.now - 180, style: :short)   # => "3m ago"
Philiprehberger::TimeAgo.format(Time.now - 7200, style: :short)  # => "2h ago"
```

### Future Timestamps

```ruby
Philiprehberger::TimeAgo.format(Time.now + 300)   # => "in 5 minutes"
Philiprehberger::TimeAgo.format(Time.now + 3600)  # => "in 1 hour"
```

### Custom Reference Time

```ruby
reference = Time.new(2026, 3, 15, 12, 0, 0)
target    = Time.new(2026, 3, 15, 10, 0, 0)

Philiprehberger::TimeAgo.format(target, relative_to: reference)  # => "2 hours ago"
```

### Max Days Fallback

```ruby
old_time = Time.now - (60 * 86_400)

Philiprehberger::TimeAgo.format(old_time, max_days: 30)  # => "Jan 20, 2026"
```

## API

| Method | Description |
|--------|-------------|
| `TimeAgo.format(time, style: :long, relative_to: Time.now, max_days: nil)` | Format a timestamp as a relative time string |

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `style` | Symbol | `:long` | `:long` for full words, `:short` for abbreviated |
| `relative_to` | Time | `Time.now` | Reference time for comparison |
| `max_days` | Integer, nil | `nil` | Fallback to absolute date after this many days |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
