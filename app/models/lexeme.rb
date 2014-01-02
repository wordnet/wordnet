class Lexeme < ActiveRecord::Base

  has_many :senses

  validates :lemma, :uniqueness => true

  include Importable

  def self.unique_attributes
    [:lemma]
  end

  def self.wordnet_count(connection)
    connection[:lexicalunit].max(:ID)
  end

  def self.wordnet_load(connection, offset, limit)
    raw = connection[:lexicalunit].select(:lemma).order(:ID).
      where('ID >= ? AND ID < ?', offset, offset + limit).to_a

    lemmas = raw.map { |r| r[:lemma] }.uniq

    lemmas.map do |lemma|
      { lemma: lemma }
    end
  end
end
