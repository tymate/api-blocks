# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_blocks/version'

Gem::Specification.new do |s|
  s.name = 'api-blocks'
  s.version = ApiBlocks::VERSION
  s.date = '2019-10-29'
  s.summary = 'Simple and consistent rails api extensions'
  s.description = s.summary
  s.authors = ["Paul d'Hubert"]
  s.email = 'dev@tymate.com'
  s.homepage = 'https://github.com/tymate/api-blocks'
  s.license = 'MIT'

  s.files         = Dir['lib/*', 'lib/**/*.rb', 'lib/**/**/*.rb']
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '>= 5.1.0'
  s.add_dependency 'dry-configurable', '~> 0.8'
  s.add_dependency 'dry-monads', '~> 1.3'
  s.add_dependency 'dry-transaction', '~> 0.13'
  s.add_dependency 'dry-validation', '~> 1.3'
  s.add_dependency 'problem_details-rails', '~> 0.2'
  s.add_dependency 'pundit', '~> 2.1'
  s.add_dependency 'rails', '>= 6.0.0'
  s.add_dependency 'responders', '~> 3.0.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rails', '~> 6.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>= 3.0.0'
  s.add_development_dependency 'rubocop', '1.6.1'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'yard-activesupport-concern'

  # s.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
end
