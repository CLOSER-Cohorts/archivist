class AddDescriptionToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :description, :text, null: true
  end
end
