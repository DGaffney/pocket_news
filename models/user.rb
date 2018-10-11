class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :username, type: String
  field :access_token, type: String
  
  def client
    Pocket::Client.new(access_token: self.access_token)
  end
  
  def all_articles_from_pocket
    client.retrieve({state: 'all'})
  end
  
  def hashid
    Hashids.new("pocket_app").encode(self.id.to_s.to_i(16))
  end
  
  def self.id_from_hashid(id)
    Hashids.new("pocket_app").decode(id).first.to_i.to_s(16)
  end
end