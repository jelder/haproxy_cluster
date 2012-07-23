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

  # Poll the entire cluster using exponential backoff until the the given block's return value matches the condition (expressed as boolean or range).
  # 
  # wait_for(1!=1){false}
  # wait_for(1==1){true}
  # wait_for(1..3){2}
  def wait_for(condition)
    raise ArgumentError.new("block required") unless block_given?
    # eval here
    case condition.class.to_s.downcase.to_sym
    when :range
      puts "range: #{condition}"
    when :trueclass, :falseclass
      puts "boolean: #{condition}"
    else
       raise ArgumentError.new("TrueClass, FalseClass, or Range expected")
    end
  end


end
