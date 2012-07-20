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

# Junk for testing
# code_string = <<END
#   api.servers.select{|s|s.backup?}.map{|s|s.name}
# END

cluster = HAProxyCluster.new(urls)
results = cluster.eval code_string
pp results

# @hi = HAProxyInstance.new(@url)
# begin
#   deployable = @hi.api.rolling_restartable? 2
#   puts <<-END
# 
#   OK:           #{@hi.api.servers.select{|s| s.ok? }.count}
#   Not a backup: #{@hi.api.servers.select{|s| s.ok? and not s.backup? }.count}
#   I/O:          #{@hi.api.bin}/#{@hi.api.bout}
#   OK via BE:    #{@hi.api.check_status and "Yes" or "No"}
#   Deployable?   #{deployable and "Yes" or "No"}
# END
# rescue Exception => e
#   puts e
#   puts e.backtrace
# end
# 
