require 'haproxy_cluster/stats_container'

class HAProxyCluster

  class Server < StatsContainer

    def initialize (stats,member)
      @member = member
      super stats
    end

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

    def wait_until_ok
      return true if self.ok?
      start = Time.now
      until self.ok?
        raise Timeout if Time.now > start + 10
        sleep 1
        @member.poll!
      end
      return true
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