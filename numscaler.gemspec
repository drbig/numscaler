# encoding: utf-8

require File.expand_path('../lib/numscaler', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'numscaler'
  gem.version       = NumScaler::VERSION
  gem.date          = Time.now

  gem.summary       = 'Easily convert numbers between different ranges'
  gem.description   = 'Convert numbers e.g. between 0.0 - 1.0 and 0.0 - Math::PI and vice-versa.'
  gem.license       = 'BSD'
  gem.authors       = ['Piotr S. Staszewski']
  gem.email         = 'p.staszewski@gmail.com'
  gem.homepage      = 'https://github.com/drbig/numscaler'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'yard', '~> 0.8'
end
