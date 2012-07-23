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

  # Poll the entire cluster using exponential backoff until the the given block's return value matches the condition (expressed as boolean or range).
  # 
  # wait_for(1!=1){false} #=> true
  # wait_for(1==1){true}  #=> true
  # wait_for(1..3){2}     #=> true
  # wait_for(true){sleep} #=> Timeout
  def wait_for (condition, &code)
    results = members_exec &code
    delay = 1.5
    loop do
      if check_all condition, results.values.flatten
        return true
      end
      if delay > 60
        puts "Too many timeouts, giving up"
        return false
      end
      delay *= 2
      sleep delay
      results = members_exec &code
    end
  end

  def members_exec (&code)
    threads = []
    results = {}
    @members.each do |member|
      threads << Thread.new do
        results[member.to_s] = member.instance_exec &code
      end
    end
    threads.each{|t|t.join}
    return results
  end

  private
 
  def check_all (condition, values)
    case condition.class.to_s
    when "Range"
      values.each{ |v| return false unless condition.cover? v }
    when "TrueClass", "FalseClass" 
      values.each{ |v| return false unless v == condition }
    else
      raise ArgumentError.new("Got #{condition.class.to_s} but TrueClass, FalseClass, or Range expected")
    end
    return true
  end

end
