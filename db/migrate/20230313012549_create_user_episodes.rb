class CreateUserEpisodes < ActiveRecord::Migration[7.0]
  def change
    create_table :user_episodes do |t|
      t.integer :user_id
      t.integer :episode_id
      t.boolean :listened, default: false
      t.boolean :favorite, default: false

      t.timestamps

      t.index :user_id
      t.index [:user_id, :episode_id], unique: true
      t.foreign_key :users, on_delete: :cascade
      t.foreign_key :episodes, on_delete: :cascade
    end
  end
end
