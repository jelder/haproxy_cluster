require 'haproxy_cluster'

# Backends present summary statistics for the servers they contain, and
# individual servers also present their own specific data.
class HAProxyCluster
  class StatsContainer

    def initialize(stats = {})
      @stats = stats
    end

    attr_accessor :stats

    def method_missing(m, *args, &block)
      if @stats.has_key? m
        @stats[m]
      else
        super
      end
    end

  end
end
