class SynsetSense < ActiveRecord::Base

  belongs_to :synset
  belongs_to :sense

end

