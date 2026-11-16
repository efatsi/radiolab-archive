class AddReplayToEpisodes < ActiveRecord::Migration[7.0]
  def change
    add_column :episodes, :replay, :boolean, default: false, null: false
    add_reference :episodes, :original_episode, foreign_key: { to_table: :episodes }
  end
end
