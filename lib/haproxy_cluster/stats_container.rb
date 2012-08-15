require 'haproxy_cluster'

# Backends present summary statistics for the servers they contain, and
# individual servers also present their own specific data.
class HAProxyCluster
  class StatsContainer

    def initialize(stats = {})
      @stats = stats
      @monitor_fields = [:status]
    end

    attr_accessor :stats

    def monitor(field)
      @monitor_fields << field.to_sym
    end

    def stats=(new)
      old = @stats
      @stats = new
      @monitor_fields.each do |field|
        if new.has_key? field and not old.has_key? field
          @member.log.info { "#{self.member.name} believes #{name} #{field} is #{new[field]}" }
        elsif old[field] != new[field]
          @member.log.info { "#{self.member.name} noticed a #{field} transition on #{name}: #{old[field]} -> #{new[field]}" }
        end
      end
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
