class ArticleTag
  include MongoMapper::Document
  key :item_id
  key :url
  key :status
  key :entity_list
  key :concept_list
  key :time_expression_list
  key :money_expression_list
  key :uri_list
  key :phone_expression_list
  key :other_expression_list
  key :quotation_list
  key :relation_list
  
  def self.from_raw(content, item_id, url)
    obj = self.new
    obj.url = url
    obj.item_id = item_id
    obj.status = content.get(:status)
    obj.entity_list = content.get(:entity_list)
    obj.concept_list = content.get(:concept_list)
    obj.time_expression_list = content.get(:time_expression_list)
    obj.money_expression_list = content.get(:money_expression_list)
    obj.uri_list = content.get(:uri_list)
    obj.phone_expression_list = content.get(:phone_expression_list)
    obj.other_expression_list = content.get(:other_expression_list)
    obj.quotation_list = content.get(:quotation_list)
    obj.relation_list = content.get(:relation_list)
    obj.save!
    obj
  end
end