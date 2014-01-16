class Lexeme < ActiveRecord::Base
  has_many :senses

  def as_json(options = {})
    {
      lemma: lemma,
      senses: senses.order(language: :desc, sense_index: :asc).map(&:id)
    }
  end
end
