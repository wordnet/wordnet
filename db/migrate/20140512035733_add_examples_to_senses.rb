class AddExamplesToSenses < ActiveRecord::Migration
  def change
    add_column :senses, :examples, :string,
      limit: 1023,
      array: true,
      default: []
  end
end
