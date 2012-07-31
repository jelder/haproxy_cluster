require 'rubygems'
require 'optparse'
require 'ostruct'
require 'pp'
require 'thread'
require 'timeout'
require 'haproxy_cluster/version'
require 'haproxy_cluster'

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename $0} ARGS URL [URL] [...]"
  opts.on("-e", "--eval=CODE", "Ruby code block to be evaluated") do |o|
    options.code_string = o
  end
  opts.on("-v", "--verbose", "Verbose logging") do
    # TODO Need better coverage here
    RestClient.log = STDERR
  end
  opts.on("--csv", "Assume result will be an Array of Arrays and emit as CSV") do
    options.csv = true
  end
  opts.on("-t", "--timeout=SECONDS", "Give up after TIMEOUT seconds") do |o|
    options.timeout = o.to_f
  end
  opts.on_tail("--version", "Show version") do
    puts HAProxyCluster::VERSION
    exit
  end
  opts.on_tail "URL should be the root of an HA Proxy status page, either http:// or https://"
end.parse!
options.urls = ARGV


if options.code_string

  if options.timeout
    result = Timeout::timeout(options.timeout) do 
      Kernel.eval( options.code_string, HAProxyCluster.new(options.urls).instance_eval("binding") )
    end
  else
    result = Kernel.eval( options.code_string, HAProxyCluster.new(options.urls).instance_eval("binding") )
  end

  case result.class.to_s
  when "TrueClass","FalseClass"
    exit result == true ? 0 : 2
  when "Hash"
    pp result
  when "Array"
    if options.csv
      result.each{|row| puts row.to_csv}
    else
      pp result
    end
  else
    puts result
  end

end

