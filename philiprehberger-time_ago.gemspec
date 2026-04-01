# frozen_string_literal: true

require_relative 'lib/philiprehberger/time_ago/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-time_ago'
  spec.version = Philiprehberger::TimeAgo::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Relative time formatting for past and future timestamps'
  spec.description = 'Format timestamps as human-readable relative strings like "3 minutes ago" or ' \
                     '"in 2 hours". Supports short format, custom reference times, and automatic ' \
                     'fallback to absolute dates beyond a configurable threshold.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-time_ago'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-time-ago'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-time-ago/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-time-ago/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
