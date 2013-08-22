require 'rack/coffee'

ExampleApp = Rack::Builder.new do
  use Rack::Coffee, :urls => ['/example', '/src']
  use Rack::Static, urls: ['/example', '/vendor', '/src']

  run proc{ |env| [302, {'Location' => '/example/index.html'}, []] }
end
