class AddTypeToPlaces < ActiveRecord::Migration[7.0]
  def change
    add_reference :places, :type, null: false, foreign_key: true
  end
end
