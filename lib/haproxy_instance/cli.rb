require 'rubygems'
require 'optparse'
require 'pp'
require 'thread'
require 'smart_colored/extend'
require 'haproxy_instance'
require 'haproxy_cluster'

urls = []
code_string = ""
OptionParser.new do |opts|
  opts.banner = "Inspect and manipulate collections of HAProxy instances"
  opts.on("-i", "--instance URL", "Instance status page URL (may be specified more than once)") do |o|
    urls << o
  end
  opts.on("-e", "--eval CODE", "Ruby code block to be evaluated on each instance") do |o|
    code_string = o
  end
  opts.on("-v", "--verbose", "Verbose logging") do
    RestClient.log = STDERR
  end
end.parse!

pp HAProxyCluster.new(urls).eval(code_string)
