require 'csv'
require 'logger'
require 'rest-client'
require 'haproxy_cluster/backend'
require 'haproxy_cluster/server'

class HAProxyCluster
  class Member

    def initialize(source)
      @source = source
      @log = Logger.new(STDOUT)
      original_formatter = Logger::Formatter.new
      @log.formatter = proc { |severity,datetime,progname,msg|
        original_formatter.call(severity,datetime,"HAProxyCluster",msg)
      }
      @backends = Hash.new { |h,k| h[k] = Backend.new({},self) }
      if source =~ /https?:/
        @type = :url
        @name = URI.parse(@source).host
      else
        @type = :file
        @name = @source
      end
      poll!
    end

    attr_accessor :backends, :source, :type, :name, :log
    def to_s; @name; end

    def poll!
      csv = case @type
      when :url
        RestClient.get(@source + ';csv')
      when :file
        File.read(@source)
      end
      CSV.parse(csv.gsub(/^# /,'').gsub(/,$/,''), { :headers => :first_row, :converters => :all, :header_converters => [:downcase,:symbol] } ) do |row|
        case row[:type]
        when Backend::TYPE_ID
          @backends[ row[:pxname].to_sym ].stats = row.to_hash 
        when Server::TYPE_ID
          @backends[ row[:pxname].to_sym ].servers[ row[:svname] ].stats = row.to_hash
        end
      end
    end

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
