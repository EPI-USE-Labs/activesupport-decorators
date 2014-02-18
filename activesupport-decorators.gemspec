$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_support_decorators/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activesupport-decorators"
  s.version     = ActiveSupportDecorators::VERSION
  s.authors     = ["Pierre Pretorius"]
  s.email       = ["pierre@labs.epiuse.com"]
  s.homepage    = "https://github.com/pierre-pretorius/activesupport-decorators"
  s.summary     = "Adds the decorator pattern to activesupport class loading."
  s.description = "Useful when extending functionality with Rails engines."
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.0"
end
