class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :sport
      t.string :name
      t.string :position
      t.integer :salary
      t.string :site

      t.timestamps
    end
  end
end
