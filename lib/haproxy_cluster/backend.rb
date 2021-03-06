require 'haproxy_cluster/stats_container'

class HAProxyCluster

  class Backend < StatsContainer
    TYPE_ID = 1

    def initialize(stats,member = nil)
      @member = member
      @servers = Hash.new { |h,k| h[k] = Server.new({},@member) }
      super stats
    end

    attr_accessor :servers
    attr_reader :member

    def name
      self.pxname
    end

    def rolling_restartable? (enough = 80)
      up_servers = @servers.select{ |name,server| server.ok? }
      if up_servers.count == 0
        @member.log.warn { "All servers are down; can't hurt!" }
        return true
      elsif Rational(up_servers.count,@servers.count) >= Rational(enough,100)
        @member.log.info { "#{up_servers.count}/#{@servers.count} is at least #{enough}%, so #{name} is rolling restartable." }
        return true
      else
        @member.log.warn { "Insufficient capacity to handle a rolling restart at this time. (#{up_servers.count}/#{@servers.count})" }
        return false
      end
    end

  end

end
