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
    threads = []
    results = {}
    @members.each do |member|
      threads << Thread.new do
        results[member.to_s] = Kernel.eval(string, member.get_binding)
      end
    end
    threads.each{|t|t.join}
    return results
  end

end
