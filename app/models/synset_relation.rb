class SynsetRelation < ActiveRecord::Base

  belongs_to :parent, :class_name => "Synset"
  belongs_to :child, :class_name => "Synset"

  def as_json(options = {})
    if options[:reverse]
      { relation_id: relation_id, synset: true, target: parent.as_json }
    else
      { relation_id: relation_id, synset: true, target: child.as_json }
    end
  end
end
