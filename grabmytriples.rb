require 'rubygems'
require 'net/http'
require 'uri'
require 'sinatra'
require 'erb'

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
  redirect params['url']
end

get '/' do
  erb %[
    <a href="javascript:location.href='http://grabmytriples.heroku.com/set?url='+location.href;">grabmytriples</a>
  ]
end
