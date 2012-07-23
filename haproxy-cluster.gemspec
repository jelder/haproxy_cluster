# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'haproxy_cluster/version'

Gem::Specification.new do |s|
  s.name        = "haproxy-cluster"
  s.version     = HAProxyCluster::VERSION
  s.authors     = ["Jacob Elder"]
  s.email       = ["jacob.elder@gmail.com"]
  s.homepage    = "https://github.com/jelder/haproxy_cluster"
  s.summary     = "Inspect and manipulate collections of HA Proxy instances"
  s.description = <<-EOF
  Ruby Gem and command line tool for quickly answering questions like, "Can we
  survive a rolling restart?", "How many transactions per second am I seeing?",
  "What's my session backlog?". Intended for use within continuous deployment
  and monitoring solutions.
  EOF

  s.required_ruby_version     = '~> 1.9.3'

  s.files         = Dir["README.md", "bin/**/*", "lib/**/*"]
  s.require_path  = "lib"
  
  s.bindir        = "bin"
  s.executables   = ["haproxy_cluster"]

  s.add_dependency 'rest-client'
end
