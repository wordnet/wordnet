class GraphQuery < ActiveRecord::Base
  serialize :params, JSON

  def nodes
    self.params["nodes"]
  end
end
