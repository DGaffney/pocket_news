class StoreResults
  include Sidekiq::Worker
  sidekiq_options :queue => :store_results
  
  def perform(username, stat)
    sr = StatResult.first_or_create(username: username, name: stat)
    sr.value = Stats.new.get(username, stat)
    sr.save!
  end
end