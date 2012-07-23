require 'haproxy_cluster/stats_container'
require 'haproxy_cluster/server_collection'

class HAProxyCluster

  class Backend < StatsContainer

    def initialize
      @servers = ServerCollection.new
      super
    end

    attr_accessor :servers

    def name
      self.pxname
    end

    def rolling_restartable? (enough = 80)
      up_servers = @servers.map{ |s| s.ok? }.count
      if up_servers == 0
        return true    # All servers are down; can't hurt!
      elsif Rational(up_servers,@servers.count) >= Rational(enough,100)
        return true    # Minumum % is satisfied
      else
        return false   # Not enough servers are up to handle restarting #{number_to_restart} at a time.
      end
    end

  end

end
