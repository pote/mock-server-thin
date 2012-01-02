require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "mock_server_thin"))

require "test/unit"
require "ruby-debug"
require "open-uri"

class HelloWorldSinatra < Sinatra::Base
  get "/" do
    "Hello"
  end
end

class MockServerTest < Test::Unit::TestCase
  def setup
    @server = MockServerThin.new(HelloWorldSinatra)
    @server.start
  end

  def test_server
    assert_equal "Hello", open("http://localhost:4000").read
  end
end

HelloWorldRackBuilder = Rack::Builder.new do
  run lambda {|env|
    [200, {"Content-Type" => "text/plain", "Content-Length" => "7"}, ["Rackup!"]]
  }
end

class MockServerRackBuilderTest < Test::Unit::TestCase
  def setup
    @server = MockServerThin.new(HelloWorldRackBuilder, :port => 4001)
    @server.start
  end

  def test_server
    assert_equal "Rackup!", open("http://localhost:4001").read
  end
end

class MockServerMethodsTest < Test::Unit::TestCase
  extend MockServerThin::Methods

  mock_server(:port => 4002) {
    get "/" do
      "Goodbye"
    end
  }

  def test_server
    assert_equal "Goodbye", open("http://localhost:4002").read
  end
end

class MockServerConfigTest < Test::Unit::TestCase
  def setup
    MockServerThin.configure do |config|
      config.port = 5067
      config.timeout = 10
      config.host = "127.0.0.1"
    end
    @server = MockServerThin.new(HelloWorldSinatra)
    @server.start
  end

  def test_server_config
    assert_equal 5067, @server.config.port
    assert_equal 10, @server.config.timeout
    assert_equal "127.0.0.1", @server.config.host
  end
end
