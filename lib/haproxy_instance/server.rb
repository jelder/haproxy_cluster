require 'haproxy_instance/stats_container'

# Servers represent physical servers and their stats
class HAProxyInstance::Server < HAProxyInstance::StatsContainer

  def initialize (stats,haproxy_instance)
    @haproxy_instance = haproxy_instance
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
      @haproxy_instance.poll!
    end
    return true
  end

  private

  def modify! (how)
    case @haproxy_instance.type
    when :url
      RestClient.post @haproxy_instance.source, { :s => self.name, :action => how, :b => self.pxname }
      @haproxy_instance.poll!
    else
      raise "Not implemented: #{how} on #{@haproxy_instance.type}"
    end
    return self.status
  end

  class Timeout < RuntimeError ; end

end
