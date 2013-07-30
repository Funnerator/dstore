# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "d_store/version"

Gem::Specification.new do |s|
  s.name        = "dstore"
  s.version     = DStore::VERSION
  s.authors     = ["Woody Peterson"]
  s.email       = ["woody@sigby.com"]
  s.homepage    = ""
  s.summary     = %q{Semi-structured data for any field}
  s.description = %q{Turn any field into a nested semi-structured document}

  s.rubyforge_project = "dstore"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency 'activerecord'
end
