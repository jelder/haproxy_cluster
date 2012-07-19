#!/usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require
require 'csv'

class HAProxyInstance

  def initialize(source)
    @backends = Hash.new { |h,k| h[k] = Backend.new }
    csv = if source =~ /^https?:/
      RestClient.get(source).gsub(/^# /,'').gsub(/,$/,'')
    else
      File.read(source) 
    end

    CSV.parse(csv, { :headers => :first_row, :converters => :all, :header_converters => [:downcase,:symbol] } ) do |row|
      case row[:type]
      when 1
        @backends[ row[:pxname].to_sym ].stats.merge! row.to_hash 
      when 2
        @backends[ row[:pxname].to_sym ].servers << Server.new(row.to_hash, source)
      end
    end
  end

  attr_accessor :backends

  # Allow Backends to be accessed by dot-notation
  def method_missing(m, *args, &block)
    if @backends.has_key? m
      @backends[m]
    else
      super
    end
  end

  # Backends present summary statistics for the servers they contain, and
  # individual servers also present their own specific data.
  class StatsContainer
    def initialize(stats = {})
      @stats = stats
    end
    attr_accessor :stats
    def name
      return @stats[:pxname] if @stats[:type] == 1
      return @stats[:svname] if @stats[:type] == 2
    end
    def method_missing(m, *args, &block)
      if @stats.has_key? m
        @stats[m]
      else
        super
      end
    end
  end

  # Backends contain servers
  class Backend < StatsContainer
    def initialize
      @servers = []
      super
    end
    attr_accessor :servers

    def rolling_restartable? (number_to_restart = 1)
      up_servers = @servers.map{ |s| s.ok? }.count
      if up_servers == 0
        return true    # All servers are down; can't hurt!
      elsif up_servers - number_to_restart >= up_servers / 2
        return true    # Half of servers would still be up, go ahead.
      else
        return false   #Not enough servers are up to handle restarting #{number_to_restart} at a time.
      end
    end

    def can_safely_restart (server)
      return true if @servers.select{|s| s.
    end

  end

  # Servers represent physical servers and their stats
  class Server < StatsContainer

    def initialize(lb)
      @lb = lb
      super
    end

    def enable!
      RestClient.post @lb, { :s => self.name, :action => :enable, :b => self.pxname }
    end

    def disable!
      RestClient.post @lb, { :s => self.name, :action => :disable, :b => self.pxname }
    end

    def backup?
      @stats[:bck] == 1
    end

    def ok?
      @stats[:status] == 'UP'
    end
  end

end
