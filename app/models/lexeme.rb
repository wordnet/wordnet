class Lexeme < ActiveRecord::Base
  has_many :senses

  def as_json(options = {})
    super.merge(
      :senses => senses.map(&:as_json)
    )
  end
end
