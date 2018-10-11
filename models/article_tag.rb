class ArticleTag
  include Mongoid::Document
  field :item_id
  field :url
  field :status
  field :entity_list
  field :concept_list
  field :time_expression_list
  field :money_expression_list
  field :uri_list
  field :phone_expression_list
  field :other_expression_list
  field :quotation_list
  field :relation_list
  
  def self.from_raw(content, item_id, url)
    obj = self.new
    self.set_vals(obj, content, item_id, url)
    obj
  end
  
  def self.set_vals(obj, content, item_id, url)
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
  end
end