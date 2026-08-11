class CreateValueAddPoints < ActiveRecord::Migration[7.1]
  def change
    create_table :value_add_points do |t|
      t.date :day, null: false
      t.integer :actual_cents, null: false
      t.integer :baseline_cents, null: false # modelled revenue without GrowCentric interventions
      t.timestamps
    end
  end
end
