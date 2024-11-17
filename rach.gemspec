lib = File.expand_path("../lib/", __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require "rach/version"

Gem::Specification.new do |spec|
  spec.name          = "rach"
  spec.version       = Rach::VERSION
  spec.authors       = ["Roger Garcia"]
  spec.email         = ["rach@rogergarcia.me"]
  spec.summary       = "Orchestrate AI agents like a virtuoso"
  spec.description   = "Rach is a lightweight framework for orchestrating AI agents"
  spec.homepage      = "https://github.com/roginn/rach"
  spec.license       = "MIT"
  
  spec.required_ruby_version = ">= 3.0"
  
  spec.files         = Dir["{lib}/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "bundler", ">= 1.0", "< 3"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_dependency "ruby-openai", "~> 7.3"
  spec.add_dependency "anthropic", "~> 0.3.0"
  # Add other dependencies as needed
end
