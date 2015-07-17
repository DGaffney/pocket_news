class User
  include MongoMapper::Document
  key :username, String
  key :access_token, String
  timestamps!
  
  def client
    Pocket::Client.new(access_token: self.access_token)
  end
  
  def all_articles_from_pocket
    client.retrieve({state: 'all'})
  end
end