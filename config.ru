require 'rack/coffee'

use Rack::Coffee, :urls => ['/example', '/src']
use Rack::Static, urls: ['/example', '/vendor', '/src']

run proc{ |env| [302, {'Location' => '/example/index.html'}, []] }