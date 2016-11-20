$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'mapper/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'mapper'
  s.version     = Mapper::VERSION
  s.authors     = ['Will Poynter']
  s.email       = ['w.poynter@ucl.ac.uk']
  s.homepage    = 'https://wiki.ucl.ac.uk/display/CLOS/Archivist'
  s.summary     = 'A plugin that provides CLOSER Mapper functionality to Archivist.'
  s.description = 'The Mapper plugin allows the user to map variables to questions and map derived variables.'
  s.license     = 'NC-OGL'

  s.files = Dir['{app,config,db,lib}/**/*', 'LICENSE.md', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.0.0', '>= 5.0.0.1'

  s.add_development_dependency 'pg'
end
