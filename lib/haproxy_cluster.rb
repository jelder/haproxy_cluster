require 'haproxy_instance'
require 'thread'

class HAProxyCluster
  def initialize(members = [])
    @members = []
    threads = []
    members.each do |url|
      threads << Thread.new do
        @members << HAProxyInstance.new(url)
      end
    end
    threads.each{|t|t.join}
  end

  def eval(string)
    results = {}
    @members.each do |member|
      results[member.to_s] = Kernel.eval(string, member.get_binding)
    end
    return results
  end

end
