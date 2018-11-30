
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_counter/version'

Gem::Specification.new do |spec|
  spec.name          = 'action_counter'
  spec.version       = ActionCounter::VERSION
  spec.authors       = ['Akira Kusumoto']
  spec.email         = ['akirakusumo10@gmail.com']

  spec.summary       = 'Action Counter'
  spec.description   = 'Action Counter'
  spec.homepage      = 'https://github.com/bluerabbit/action_counter'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'redis-objects'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'fakeredis'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
