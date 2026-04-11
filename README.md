# philiprehberger-time_ago

[![Tests](https://github.com/philiprehberger/rb-time-ago/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-time-ago/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-time_ago.svg)](https://rubygems.org/gems/philiprehberger-time_ago)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-time-ago)](https://github.com/philiprehberger/rb-time-ago/commits/main)

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

### Precision Control

```ruby
# Show only the largest unit at hour precision
Philiprehberger::TimeAgo.format(Time.now - 5400, precision: :hour)
# => "1 hour ago"
```

### Multiple Units

```ruby
Philiprehberger::TimeAgo.format(Time.now - 3720, max_units: 2)
# => "1 hour 2 minutes ago"

Philiprehberger::TimeAgo.format(Time.now - 3720, style: :short, max_units: 2)
# => "1h 2m ago"
```

### Compound Mode

```ruby
Philiprehberger::TimeAgo.format(Time.now - 5400, compound: true)
# => "1 hour and 30 minutes ago"

Philiprehberger::TimeAgo.format(Time.now + 5400, compound: true)
# => "in 1 hour and 30 minutes"
```

### Approximate Mode

```ruby
Philiprehberger::TimeAgo.format(Time.now - 7200, approximate: true)
# => "about 2 hours ago"

Philiprehberger::TimeAgo.format(Time.now + 300, approximate: true)
# => "in about 5 minutes"
```

### Until (Future Time)

```ruby
Philiprehberger::TimeAgo.until(Time.now + 180)   # => "in 3 minutes"
Philiprehberger::TimeAgo.until(Time.now + 7200)  # => "in 2 hours"
Philiprehberger::TimeAgo.until(Time.now + 86_400) # => "tomorrow"
```

### In Words

```ruby
Philiprehberger::TimeAgo.in_words(5400)   # => "1 hour and 30 minutes"
Philiprehberger::TimeAgo.in_words(300)    # => "5 minutes"
Philiprehberger::TimeAgo.in_words(45)     # => "45 seconds"
```

### Auto (Relative or Absolute)

```ruby
Philiprehberger::TimeAgo.auto(Time.now - 3600)
# => "1 hour ago"

Philiprehberger::TimeAgo.auto(Time.now - (5 * 86_400), threshold: 86_400)
# => "Mar 16, 2026"

Philiprehberger::TimeAgo.auto(Time.now - (5 * 86_400), threshold: 86_400, format: "%Y-%m-%d")
# => "2026-03-16"
```

### Configuration

```ruby
Philiprehberger::TimeAgo.configure(just_now: 10)

Philiprehberger::TimeAgo.format(Time.now - 15)  # => "15 seconds ago"
Philiprehberger::TimeAgo.format(Time.now - 5)   # => "just now"

Philiprehberger::TimeAgo.reset_config!  # restore defaults
```

### Format Duration

```ruby
Philiprehberger::TimeAgo.format_duration(5400)
# => "1 hour and 30 minutes"

Philiprehberger::TimeAgo.format_duration(5400, style: :short)
# => "1h 30m"

Philiprehberger::TimeAgo.format_duration(90_061, max_units: 3)
# => "1 day, 1 hour, and 1 minute"

Philiprehberger::TimeAgo.format_duration(5400, approximate: true)
# => "about 1 hour and 30 minutes"
```

### Duration Between

```ruby
t1 = Time.new(2026, 3, 21, 10, 0, 0)
t2 = Time.new(2026, 3, 22, 12, 30, 45)

Philiprehberger::TimeAgo.duration_between(t1, t2)
# => { days: 1, hours: 2, minutes: 30, seconds: 45 }
```

## API

| Method | Description |
|--------|-------------|
| `TimeAgo.format(time, **opts)` | Format a timestamp as a relative time string |
| `TimeAgo.until(time, **opts)` | Format a future time as a relative string (e.g., "in 3 minutes") |
| `TimeAgo.in_words(seconds)` | Format raw seconds as duration words (e.g., "5 minutes") |
| `TimeAgo.auto(time, **opts)` | Relative time if within threshold, otherwise absolute date |
| `TimeAgo.configure(**opts)` | Set module-level configuration thresholds |
| `TimeAgo.config` | Return the current configuration hash |
| `TimeAgo.reset_config!` | Reset configuration to defaults |
| `TimeAgo.format_duration(seconds, **opts)` | Format raw seconds as a human-readable duration string |
| `TimeAgo.duration_between(time1, time2)` | Return structured hash of time components between two times |

**Format Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `style` | Symbol | `:long` | `:long` for full words, `:short` for abbreviated |
| `relative_to` | Time | `Time.now` | Reference time for comparison |
| `max_days` | Integer, nil | `nil` | Fallback to absolute date after this many days |
| `precision` | Symbol, nil | `nil` | Smallest unit to show (`:hour`, `:minute`, etc.) |
| `max_units` | Integer, nil | `nil` | Maximum number of time components to show |
| `compound` | Boolean | `false` | Show two units joined with "and" |
| `approximate` | Boolean | `false` | Prefix output with "about" |

**Format Duration Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `style` | Symbol | `:long` | `:long` for full words, `:short` for abbreviated |
| `precision` | Symbol, nil | `nil` | Smallest unit to show (`:hour`, `:minute`, etc.) |
| `max_units` | Integer | `2` | Maximum number of time components to show |
| `compound` | Boolean | `true` | Join units with "and" |
| `approximate` | Boolean | `false` | Prefix with "about" |

**Auto Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `threshold` | Integer | `86400` | Seconds threshold for relative display |
| `format` | String | `'%b %d, %Y'` | strftime format for absolute fallback |
| `relative_to` | Time | `Time.now` | Reference time for comparison |

**Configure Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `just_now` | Integer | `30` | Seconds threshold for "just now" |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-time-ago)

🐛 [Report issues](https://github.com/philiprehberger/rb-time-ago/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-time-ago/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
