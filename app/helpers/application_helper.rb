module ApplicationHelper

  def item(name, params)
    attributes = params.transform_keys { |key| String(key).gsub('_', '-').to_sym }
    attributes[:href] ||= '#'

    render('shared/item', name: name, attributes: attributes)
  end

end
