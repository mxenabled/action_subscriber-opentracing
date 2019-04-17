
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "action_subscriber/opentracing/version"

Gem::Specification.new do |spec|
  spec.name          = "action_subscriber-opentracing"
  spec.version       = ActionSubscriber::OpenTracing::VERSION
  spec.authors       = ["Marcos Minond"]
  spec.email         = ["minond.marcos@gmail.com"]

  spec.summary       = "ActionSubscriber"
  spec.description   = "ActionSubscriber"
  spec.homepage      = "https://github.com/mxenabled/action_subscriber-opentracing"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "opentracing"

  spec.add_development_dependency "action_subscriber", "~> 5.1.3"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "mad_rubocop"
  spec.add_development_dependency "opentracing_test_tracer"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
