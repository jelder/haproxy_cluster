require 'haproxy_cluster'

# Backends present summary statistics for the servers they contain, and
# individual servers also present their own specific data.
class HAProxyCluster
  class StatsContainer

    def initialize(stats = {})
      @stats = stats
    end
    attr_accessor :stats

    def critical_fields(fields = [:status,:rate]) fields ; end

    def merge!(new)
      critical_fields.each do |field|
        if @stats[field] != new[field]
          STDERR.puts "#{self.member.name} noticed a #{field} transition on #{self.name}: #{@stats[field]} -> #{new[field]}"
        end
      end
      @stats.merge! new
    end

    def method_missing(m, *args, &block)
      if @stats.has_key? m
        @stats[m]
      else
        super
      end
    end

  end
end
