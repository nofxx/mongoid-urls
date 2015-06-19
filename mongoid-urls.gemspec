# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mongoid/urls/version'

Gem::Specification.new do |s|
  s.name        = 'mongoid-urls'
  s.version     = Mongoid::Urls::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Marcos Piccinini']
  s.homepage    = 'http://github.com/nofxx/mongoid-urls'
  s.licenses    = ['MIT']
  s.summary     = 'A url sanitizer (slugs) for Mongoid documents.'
  s.description = 'Mongoid Urls creates unique sanitized URLs for Mongoid documents. Simple and great for making URLs look good.'

  s.rubyforge_project = 'mongoid-urls'
  s.add_dependency 'mongoid', '> 4.0.0'
  s.add_dependency 'babosa', '> 1.0.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end