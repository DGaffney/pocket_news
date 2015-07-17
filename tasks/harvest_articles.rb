class HarvestArticles
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    articles = user.all_articles_from_pocket["list"]
    articles.values.each do |article|
      ProcessArticle.perform_async(article, user.username, articles.count)
    end
  end
end