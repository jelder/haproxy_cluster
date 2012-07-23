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

    def rolling_restartable? (number_to_restart = 1)
      up_servers = @servers.map{ |s| s.ok? }.count
      if up_servers == 0
        return true    # All servers are down; can't hurt!
      elsif up_servers - number_to_restart >= up_servers / 2
        return true    # Half of servers would still be up, go ahead.
      else
        return false   # Not enough servers are up to handle restarting #{number_to_restart} at a time.
      end
    end

  end

end
