# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "haproxy_instance/version"

Gem::Specification.new do |s|
  s.name        = "haproxy_instance"
  s.version     = HAProxyInstance::VERSION
  s.authors     = ["Jacob Elder"]
  s.email       = ["jacob.elder@gmail.com"]
  s.homepage    = "https://github.com/jelder/haproxy_instance"
  s.summary     = "A richer interface to HA Proxy"
  s.description = s.summary 

  s.required_ruby_version     = '>= 1.9.2'

  s.files         = Dir["README.md", "bin/**/*", "lib/**/*"]
  s.require_path  = "lib"
  
  s.bindir        = "bin"
  s.executables   = ["check_haproxy"]

  s.add_dependency 'rest-client'
  s.add_dependency 'smart_colored'
end
