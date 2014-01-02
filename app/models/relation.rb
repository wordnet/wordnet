class Relation < Ohm::Model
  attribute :external_id
  index :external_id

  attribute :name
  attribute :description
end
