require "sinatra/base"
require "logger"

class MockServerThin

  class App < Sinatra::Base
    use Rack::ShowExceptions
  end

  class << self
    attr_accessor :config
  end

  class Config
    attr_accessor :timeout, :port, :host

    def initialize
      @timeout = 5
      @port = 4000
      @host = "0.0.0.0"
    end

    def to_hash
      Hash[instance_variables.map { |var| [var[1..-1].to_sym, instance_variable_get(var)] }]
    end
  end

  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Config.new
  end

  def config
    self.class.config
  end

  def initialize(app, opts = {}, &block)
    @app = app
    options = config.to_hash.merge!(opts)
    puts "SERVER OPTIONS: %s" % options.inspect
    @port = options[:port]
    @timeout = options[:timeout]
    @host = options[:host]
  end

  def start
    Thread.new do
      with_quiet_logger do |logger|
        Rack::Handler::Thin.run(@app, :Port => @port, :Logger => logger, :AccessLog => [])
      end
    end

    wait_for_service(@host, @port)

    self
  end

  module Methods
    def mock_server(opts = {}, &block)
      app = Class.new(Sinatra::Base)
      app.class_eval(&block)
      @server = MockServerThin.new(app, opts, &block).start
    end
  end

protected
  def with_quiet_logger
    io = File.open("/dev/null", "w")
    yield(::Logger.new(io))
  ensure
    io.close
  end

  def listening?(host, port)
    begin
      socket = TCPSocket.new(host, port)
      socket.close unless socket.nil?
      true
    rescue Errno::ECONNREFUSED,
      Errno::EBADF,           # Windows
      Errno::EADDRNOTAVAIL    # Windows
      false
    end
  end

  def wait_for_service(host, port)
    start_time = Time.now

    until listening?(host, port)
      if @timeout && (Time.now > (start_time + @timeout))
        raise SocketError.new("Socket did not open within #{@timeout} seconds")
      end
    end

    true
  end
end
