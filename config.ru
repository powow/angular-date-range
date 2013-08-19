use Rack::Static, urls: ['/example', '/vendor']
run proc{ |env| [302, {'Location' => '/example/index.html'}, []] }
