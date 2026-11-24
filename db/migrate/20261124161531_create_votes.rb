class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :event, null: false, foreign_key: true
      t.string :user_id, null: false
      t.integer :direction, null: false # enum in Vote: up = 1, down = -1

      t.timestamps
    end
    add_index :votes, %i[event_id user_id], unique: true
  end
end
