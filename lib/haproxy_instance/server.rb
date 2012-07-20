require 'haproxy_instance/stats_container'

# Servers represent physical servers and their stats
class HAProxyInstance::Server < HAProxyInstance::StatsContainer

  def initialize(stats,lb)
    @lb = lb
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

  private

  def modify! (how)
    case @lb.type
    when :url
      RestClient.post @lb.source, { :s => self.name, :action => how, :b => self.pxname }
    else
      raise "Not implemented: #{how} on #{@lb.type}"
    end
  end

end
