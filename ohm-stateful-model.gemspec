gem 'ohm'
gem 'state_machine'

# encoding: UTF-8

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ohm/stateful-model/version'

Gem::Specification.new do |s|
  s.name     = "ohm-stateful-model"
  s.version  = ::OhmStatefulModel::VERSION
  s.authors  = ["Cameron Dutro"]
  s.email    = ["camertron@gmail.com"]
  s.homepage = "http://github.com/camertron"

  s.description = s.summary = "Integrate state machines (from the state_machine gem) into your Ohm models."

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.add_dependency "ohm", "~> 1.3.2"
  s.add_dependency "state_machine", "~> 1.2.0"

  s.add_development_dependency 'rake'

  s.require_path = 'lib'
  s.files = Dir["{lib,spec}/**/**", "Gemfile", "History.txt", "Rakefile", "LICENSE", "ohm-stateful-model.gemspec"]
end
