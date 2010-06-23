require 'sinatra/base'
require 'json'
require 'lib/helpers'
require 'net/http'

SERVER_ROOT = File.expand_path(File.dirname(__FILE__))
DEVELOPMENT = ENV['RACK_ENV'] == 'development'

UKI_HOST = '127.0.0.1'
UKI_PORT = 21119
UKI_PATH = '/src/'

class ImageCutter < Sinatra::Base
  get '/' do
    File.open(File.join('public', 'imageCutter.html'), 'r') { |f| f.read }
  end
  
  get '/imageCutter' do
    File.open(File.join('public', 'imageCutter.html'), 'r') { |f| f.read }
  end
  
  get '/src/*' do
    proxy_response = Net::HTTP.start(UKI_HOST, UKI_PORT) { |http| http.get("#{UKI_PATH}#{params[:splat][0]}") }
    proxy_response.each_header { |name, value|
      response.header[name] = value
    }
    proxy_response.body
  end
  
  # Expects json: [ 
  #   { name: 'file-name.png', data: 'png data' },
  #   { name: 'file-name.gif', data: 'gif data' },
  #   ...
  # ]
  # returns json: {
  #   optimized: [
  #     { name: 'file-name.png', data: 'png data' },
  #     { name: 'file-name.gif', data: 'gif data' },
  #     ...
  #   ],
  #   url: 'path-to-zip-file'
  # }
  post '/imageCutter/' do
    items = JSON.load(params['json'])
    optimized = []
    Dir.mktmpdir { |dir|
      items.each do |row|
        data = Base64.decode64(row['data'])
        data = row['name'].match(/\.gif$/) ? optimize_gif(data) : optimize_png(data)
        File.open(File.join(dir, row['name']), 'w') { |f| f.write(data) }
        optimized << { 'name' => row['name'], 'data' => encode64(data) }
      end
      `zip #{dir}/tmp.zip #{dir}/*`
      suffix = "#{Time.now.to_i}#{rand(1e6)}"
      FileUtils.mv "#{dir}/tmp.zip", "#{SERVER_ROOT}/cutted/tmp#{suffix}.zip"
      response.header['Content-Type'] = 'application/x-javascript'
      { 'url' => "/cutted/tmp#{suffix}.zip", 'optimized' => optimized }.to_json
    }
  end
  
  if DEVELOPMENT
    get %r{^/cutted/.*\.zip} do
      response.header['Content-Type'] = 'application/x-zip-compressed'
      response.header['Content-Disposition'] = 'attachment; filename=tmp.zip'
      File.read(request.path.sub(%r{^/}, ''))
    end
  
    get '*' do
      path = request.path
      response.header['Content-type'] = 'image/png' if path.match(/\.png$/)
      response.header['Content-type'] = 'text/css' if path.match(/\.css$/)
      response.header['Content-type'] = 'image/jpeg' if path.match(/\.jpg$/)
      response.header['Content-type'] = 'text/javascript;charset=utf-8' if path.match(/\.js$/)
      response.header['Content-Encoding'] = 'gzip' if path.match(/\.gz/)
      if path.match(/.zip$/)
        response.header['Content-Type'] = 'application/x-zip-compressed'
        response.header['Content-Disposition'] = 'attachment; filename=tmp.zip'
      end
    
      File.read File.join(SERVER_ROOT, 'public', path) rescue pass
    end
  end
end