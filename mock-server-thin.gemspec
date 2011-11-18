Gem::Specification.new do |s|
  s.name        = "mock-server-thin"
  s.version     = "0.1.1"
  s.summary     = %{A quick way of mocking an external web service you want to consume.}
  s.authors     = ["Damian Janowski", "Pablo Astigarraga"]
  s.email       = ["djanowski@dimaion.com", "pote@tardis.com.uy"]
  s.homepage    = "http://github.com/pote/mock-server-thin"
  s.files       = ["lib/mock_server_thin.rb", "README.markdown", "test/mock_server_test.rb"]

  s.add_dependency "sinatra"
  s.add_dependency "thin"
end
