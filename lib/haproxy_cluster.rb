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

  # Poll the entire cluster using exponential backoff until the the given
  # block's return value always matches the condition (expressed as boolean or
  # range).
  #
  # A common form of this is:
  #
  #   wait_for(true) do
  #     api.servers.map{|s|s.ok?}
  #   end
  #
  # This block would not return until every member of the cluster is available
  # to serve requests.
  # 
  # wait_for(1!=1){false} #=> true
  # wait_for(1==1){true}  #=> true
  # wait_for(1..3){2}     #=> true
  # wait_for(true){sleep} #=> Timeout
  def wait_for (condition, &code)
    results = map(&code)
    delay = 1.5
    loop do
      if reduce(condition, results.values.flatten)
        return true
      end
      if delay > 60
        puts "Too many timeouts, giving up"
        return false
      end
      delay *= 2
      sleep delay
      map { poll! }
      results = map(&code)
    end
  end

  # Run the specified code against every memeber of the cluster. Results are
  # returned as a Hash, with member.to_s being the key.
  def map (&code)
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

  # Return true or false depending on the relationship between `condition` and `values`.
  # `condition` may be specified as true, false, or a Range object.
  # `values` is an Array of whatever type is appropriate for the condition.
  def reduce (condition, values)
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
