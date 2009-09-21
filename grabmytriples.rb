require 'rubygems'
require 'net/http'
require 'uri'
require 'sinatra'

def set(endpoint, graph, rdf)
  puts "#{endpoint} -> #{graph} - #{rdf.size}"
  http = Net::HTTP.new(endpoint.host, endpoint.port)
  http.start do |h|
    request = Net::HTTP::Put.new(endpoint.path + graph)
    request.body = rdf
    response = h.request(request)
  end
end

def get_rdf(url, content_type='application/rdf+xml')
  req = Net::HTTP::Get.new(url.path)
  req.add_field('Accept', content_type)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
end

def process(store, url, graph=nil)
  endpoint, uri = URI.parse(store), URI.parse(url)
  res = get_rdf(uri)
  p set(endpoint, (graph || url), res.body)
end

get '/set' do
  store = params['store'] || 'http://dbtune.org/beancounter/data/'
  process(store, params['url'], params['graph'])
end
# process('http://dbtune.org/beancounter/data/', 'http://www.bbc.co.uk/music/artists/5483e1c0-14ca-4ec4-9b03-c4e987420e4e')
