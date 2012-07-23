require 'rubygems'
require 'optparse'
require 'pp'
require 'thread'
require 'smart_colored/extend'
require 'haproxy_cluster'

code_string = ""
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename $0} ARGS URL [URL] [...]"
  opts.on("-e", "--eval CODE", "Ruby code block to be evaluated") do |o|
    code_string = o
  end
  opts.on("-v", "--verbose", "Verbose logging") do
    RestClient.log = STDERR
  end
  opts.separator "URL should be the root of an HA Proxy status page, either http:// or https://"
end.parse!
urls = ARGV

cluster = HAProxyCluster.new(urls)
pp Kernel.eval(code_string, cluster.instance_eval("binding"))

