class AddProductDimensions < ActiveRecord::Migration[7.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :categories, :department, foreign_key: true
    add_column :products, :season, :string, null: false, default: "all_season"
  end
end
