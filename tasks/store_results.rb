class StoreResults
  include Sidekiq::Worker
  sidekiq_options :queue => :store_results
  
  def perform(username, stat)
    sr = StatResult.first_or_create(username: username, name: stat)
    sr.value = Stats.new.get(username, stat)
    sr.save!
  end
end
# while true
#   User.each do |u|
#     StoreResults.perform_async(u.username, "sentiment")
#     StoreResults.perform_async(u.username, "political_leanings")
#   end
# end

# StoreResults.new.perform("itsme@devingaffney.com", "political_leanings")
# StatResult.where(name: ["sentiment", "political_leanings"])