# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-04-12

### Added
- `TimeAgo.format_duration(seconds, **opts)` method for formatting raw seconds as human-readable duration strings with full option support (style, precision, max_units, compound, approximate)

### Fixed
- Bug report template now requires Ruby version and gem version fields
- Feature request template now includes placeholder code example

## [0.4.0] - 2026-04-04

### Added
- `TimeAgo.until(time, relative_to:)` method for formatting future times as "in 3 minutes", "in 2 hours", etc. (inverse of `format` for past times)

## [0.3.0] - 2026-04-03

### Added
- `TimeAgo.configure(just_now: 30, ...)` for class-level threshold configuration
- `TimeAgo.config` and `TimeAgo.reset_config!` for reading and resetting configuration
- `compound: true` option on `TimeAgo.format` to show two units joined with "and" (e.g., "1 hour and 30 minutes ago")
- `approximate: true` option on `TimeAgo.format` to prefix with "about" (e.g., "about 2 hours ago")
- `TimeAgo.in_words(seconds)` to format raw seconds as duration words without directional suffix
- `TimeAgo.auto(time, threshold:, format:)` to return relative time within threshold or formatted absolute date

## [0.2.0] - 2026-04-01

### Added
- `precision:` parameter to limit output to a specific time unit granularity
- `max_units:` parameter to show multiple time components (e.g., "1 hour 2 minutes ago")
- `TimeAgo.duration_between(time1, time2)` method returning structured component hash

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-26

### Fixed
- Add Sponsor badge to README
- Fix license section link format

## [0.1.3] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.1] - 2026-03-22

### Changed
- Improve source code, tests, and rubocop compliance

## [0.1.0] - 2026-03-21

### Added
- Initial release
- Relative time formatting for past timestamps ("3 minutes ago", "yesterday")
- Future time formatting ("in 2 hours", "tomorrow")
- Short format style ("3m ago", "2h ago")
- Custom reference time via `relative_to` option
- Automatic fallback to absolute date format via `max_days` option
