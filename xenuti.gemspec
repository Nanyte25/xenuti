Gem::Specification.new do |gem|
  gem.name                      = 'xenuti'
  gem.authors                   = ['Jan Rusnacko']
  gem.email                     = 'rusnackoj@gmail.com'
  gem.files                     = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.license                   = 'MIT'
  gem.required_ruby_version     = ['>= 1.9.3']
  gem.add_development_dependency 'rake', '>= 10.0.0'
  gem.add_development_dependency 'rspec', '>= 2.14'
  gem.add_development_dependency 'rubocop', '>= 0'
  gem.add_runtime_dependency 'safe_yaml', '>=1.0.0'
end
