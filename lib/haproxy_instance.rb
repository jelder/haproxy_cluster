#!/usr/bin/env ruby
require 'csv'
require 'rest-client'
require 'haproxy_instance/backend'
require 'haproxy_instance/server'

class HAProxyInstance
  BACKEND = 1
  SERVER  = 2

  def initialize(source)
    @source = source
    @backends = Hash.new { |h,k| h[k] = Backend.new }
    if source =~ /https?:/
      @type = :url
    else
      @type = :file
    end
    update!
  end

  def update!
    case @type
    when :url
      csv = RestClient.get(@source + ';csv').gsub(/^# /,'').gsub(/,$/,'')
    when :file
      File.read(@source)
    end
    CSV.parse(csv, { :headers => :first_row, :converters => :all, :header_converters => [:downcase,:symbol] } ) do |row|
      case row[:type]
      when BACKEND
        @backends[ row[:pxname].to_sym ].stats.merge! row.to_hash 
      when SERVER
        @backends[ row[:pxname].to_sym ].servers << Server.new(row.to_hash, self)
      end
    end
  end

  attr_accessor :backends, :source, :type

  def get_binding; binding; end
  def to_s; @source; end
  def reload!; update! ; end

  # Allow Backends to be accessed by dot-notation
  def method_missing(m, *args, &block)
    if @backends.has_key? m
      @backends[m]
    else
      super
    end
  end

end
