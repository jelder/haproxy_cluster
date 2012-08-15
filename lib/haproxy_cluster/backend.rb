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
      up_servers = @servers.map{ |name,server| s.ok? }.count
      if up_servers == 0
        @member.log.warn { "All servers are down; can't hurt!" }
        return true
      elsif Rational(up_servers,@servers.count) >= Rational(enough,100)
        @member.log.info { "#{up_servers}/#{@servers.count} is at least #{enough}%!" }
        return true
      else
        @member.log.warn { "Insufficient capacity to handle a rolling restart at this time." }
        return false
      end
    end

  end

end
