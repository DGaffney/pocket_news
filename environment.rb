require 'activemodel-serializers-xml'
require 'nokogiri'
require 'stopwords'
require 'rest-client'
require 'pocket-ruby'
require 'mongo_mapper'
require 'json'
require 'pry'
require 'sinatra'
require 'bcrypt'
require 'sinatra/flash'
require 'sidekiq'
require 'sidekiq/web'
require 'yaml'
require 'hashids'
require 'sentimental'
require 'indico'
require 'sinatra/cross_origin'
require 'sinatra'
require 'thin'
class MyThinBackend < ::Thin::Backends::TcpServer
  def initialize(host, port, options)
    super(host, port)
    @ssl = true
    @ssl_options = options
  end
end

configure do
  enable :cross_origin
  set :environment, :production
  set :bind, '0.0.0.0'
  set :port, 443
  set :server, "thin"
  class << settings
    def server_settings
      {
        :backend          => MyThinBackend,
        :private_key_file => "/etc/ssl/private/apache-selfsigned.key",
        :cert_chain_file  => File.dirname(__FILE__) + "/etc/ssl/certs/apache-selfsigned.crt",
        :verify_peer      => false
      }
    end
  end
end
#configure do
#  enable :cross_origin
#end
#Sentimental.load_defaults
#Sentimental.threshold = 0.1
SETTINGS = YAML.load(File.read(File.dirname(__FILE__)+"/settings.yaml"))
Indico.api_key = SETTINGS["indico"]
MongoMapper.connection = Mongo::MongoClient.new(SETTINGS["mongo_host"], SETTINGS["mongo_port"], :pool_size => 25, :op_timeout => 600000, :timeout => 600000, :pool_timeout => 600000)
MongoMapper.database = SETTINGS["mongo_db"]
CALLBACK_URL = SETTINGS["callback_url"]
Pocket.configure do |config|
  config.consumer_key = SETTINGS["pocket_consumer_key"]
end

Dir[File.dirname(__FILE__) + '/extensions/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/handlers/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/before_hooks/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each {|file| require file }


set :erb, :layout => :'layouts/main'
enable :sessions
helpers Sinatra::Partials

# Article.fields(:resolved_url, :item_id).to_a.each do |article|
#   puts article.id
#   if ArticleTag.first(item_id: article.item_id, url: article.resolved_url).nil? || ArticleContent.first(item_id: article.item_id, url: article.resolved_url).nil?
#     ClassifyTopics.new.perform(article.item_id, article.resolved_url)
#   end
# end
