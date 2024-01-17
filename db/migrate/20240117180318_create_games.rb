class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.integer :balls, array: true, default: "{}"

      t.timestamps
    end
  end
end
