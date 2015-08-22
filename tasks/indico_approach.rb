class IndicoApproach
  include Sidekiq::Worker
  def perform(classname, lookup)
    return if !IndicoResult.first(lookup: lookup).nil?
    object = classname.constantize.first(lookup)
    IndicoResult.from_raw(indico_results(classname, object), lookup)
  end
  
  def indico_results(classname, object)
    {
      text_tags: Indico.text_tags(fields[classname].collect{|f| object.send(f)}),
      political: Indico.political(fields[classname].collect{|f| object.send(f)}),
      sentiment: Indico.sentiment(fields[classname].collect{|f| object.send(f)})
    }
  end
  
  def fields
    {
      "Article" => ["resolved_title", "excerpt"],
      "ArticleContent" => ["content"]
    }
  end
end