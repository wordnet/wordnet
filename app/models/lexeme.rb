class Lexeme < ActiveRecord::Base
  has_many :senses

  def as_json(options = {})
    {
      lemma: lemma,
      language: language,
      senses: senses.order(:sense_index).map(&:id)
    }
  end
end
