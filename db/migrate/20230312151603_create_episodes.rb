class CreateEpisodes < ActiveRecord::Migration[7.0]
  def change
    create_table :episodes do |t|
      t.string :title
      t.string :slug
      t.text :tease
      t.text :description
      t.string :audio_url
      t.datetime :publish_at
      t.string :image_url
      t.integer :length

      t.timestamps
    end
  end
end
