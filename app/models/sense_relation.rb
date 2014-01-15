class SenseRelation < ActiveRecord::Base

  belongs_to :parent, :class_name => "Sense"
  belongs_to :child, :class_name => "Sense"

  def as_json(options = {})
    if options[:reverse]
      { relation_id: relation_id, sense: true, target: parent.as_json }
    else
      { relation_id: relation_id, sense: true, target: child.as_json }
    end
  end
end
