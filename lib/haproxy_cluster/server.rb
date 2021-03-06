require 'haproxy_cluster/stats_container'

class HAProxyCluster

  class Server < StatsContainer
    TYPE_ID = 2

    def initialize(stats,member = nil)
      @member = member
      super stats
    end
    attr_reader :member

    def name
      self.svname 
    end

    def backup?
      self.bck == 1
    end

    def ok?
      self.status == 'UP'
    end

    def enable!
      modify! :enable
    end

    def disable!
      modify! :disable
    end

    private

    def modify! (how)
      case @member.type
      when :url
        RestClient.post @member.source, { :s => self.name, :action => how, :b => self.pxname }
        @member.poll!
      else
        raise "Not implemented: #{how} on #{@member.type}"
      end
      return self.status
    end

    class Timeout < RuntimeError ; end

  end

end
