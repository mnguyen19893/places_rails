class CreatePlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :places do |t|
      t.string :name
      t.decimal :latitude
      t.decimal :longitude
      t.string :picture_link
      t.string :build_in_year
      t.string :wikipedia_link
      t.string :location

      t.timestamps
    end
  end
end
