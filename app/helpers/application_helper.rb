module ApplicationHelper

  def item(name, params)
    item_attributes = [:number, :description].map { |key| [key, params[key]] }.to_h
    item_attributes[:name] = name

    html_attributes = params.except(*item_attributes.keys).transform_keys(&method(:to_attr))
    html_attributes[:href] ||= '#' + name.parameterize

    render('shared/item', attributes: html_attributes, **item_attributes)
  end

private

  def to_attr(entity)
    String(entity).gsub('_', '-').to_sym
  end

end
