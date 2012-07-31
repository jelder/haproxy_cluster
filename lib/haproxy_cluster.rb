require 'haproxy_cluster/member'
require 'timeout'
require 'thread'

class HAProxyCluster

  Inf = +1.0/0.0
  NegInf = -1.0/0.0

  def initialize(members = [])
    @members = []
    threads = []
    members.each do |url|
      threads << Thread.new do
        @members << HAProxyCluster::Member.new(url)
      end
    end
    threads.each{|t|t.join}
  end

  attr_accessor :members

  # Poll the cluster, executing the given block with fresh data at the
  # prescribed interval.
  def poll(interval = 1.0)
    first = true
    loop do
      start = Time.now
      each_member { poll! } unless first
      first = false
      yield
      sleep interval - (Time.now - start)
    end
  end

  # Poll the entire cluster until the the given block's return value always
  # matches the condition (expressed as boolean or range).
  #
  # This block would not return until every member of the cluster is available
  # to serve requests.
  #
  #   wait_for(:condition => true) do
  #     api.servers.map{|s|s.ok?}
  #   end
  #
  # The constants `Inf` and `NegInf` (representing infinity and negative
  # infinity respectively) are available, which enables less than/greater than
  # expressions in the form of `Range`s.
  #
  # Parameters:
  #
  # * :condition, anything accepted by `check_condition`
  # * :interval, check interval (default 2 seconds, same as HA Proxy) 
  # * :timeout, give up after this number of seconds 
  # * :min_checks, require :condtion to pass this many times in a row
  #
  def wait_until (options = {}, &code)
    opts = {
      :condition => true,
      :interval => 2.0,
      :timeout => 300,
      :min_checks => 3
    }.merge options
    Timeout::timeout(opts[:timeout]) do
      history = []
      loop do
        results = each_member(&code)

        # Break out as soon as we reach :min_checks in a row
        history << check_condition(opts[:condition], results.values.flatten)
        return true if history.last(opts[:min_checks]) == [true] * opts[:min_checks]

        sleep opts[:interval]
        each_member { poll! }
      end
    end
  end

  # Run the specified code against every memeber of the cluster. Results are
  # returned as a Hash, with member.to_s being the key.
  def each_member (&code)
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
  #
  #   check_condition(0!=1,   [true])         #=> true
  #   check_condition(1==1,   [true])         #=> true
  #   check_condition(3..Inf, [2,2])          #=> false
  #   check_condition(true,   [true,false])   #=> raise Timeout::timeout
  def check_condition (condition, values)
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
