class HarvestArticles
  include Sidekiq::Worker
  sidekiq_options :queue => :pocket_harvester

  def perform(user_id)
    user = User.find(user_id)
    articles = user.all_articles_from_pocket["list"]
    articles.values.each do |article|
      ProcessArticle.perform_async(article, user.username, articles.count)
    end
  end
end