require 'csv'
require 'rest-client'
require 'haproxy_cluster/backend'
require 'haproxy_cluster/server'

class HAProxyCluster
  class Member
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
      poll!
    end

    def poll!
      csv = case @type
      when :url
        RestClient.get(@source + ';csv')
      when :file
        File.read(@source)
      end
      CSV.parse(csv.gsub(/^# /,'').gsub(/,$/,''), { :headers => :first_row, :converters => :all, :header_converters => [:downcase,:symbol] } ) do |row|
        backend = row[:pxname].to_sym
        case row[:type]
        when BACKEND
          @backends[ backend ].stats.merge! row.to_hash 
        when SERVER
          server = row[:svname]
          if @backends[ backend ].servers.has_key? row[:svname]
            @backends[backend].servers[server].merge! row.to_hash
          else
            @backends[backend].servers[server] = Server.new(row.to_hash, self)
          end
        end
      end
    end

    attr_accessor :backends, :source, :type

    def get_binding; binding; end
    def to_s; @source; end

    # Allow Backends to be accessed by dot-notation
    def method_missing(m, *args, &block)
      if @backends.has_key? m
        @backends[m]
      else
        super
      end
    end

  end
end
