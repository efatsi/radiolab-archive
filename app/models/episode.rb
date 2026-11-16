class Episode < ApplicationRecord
  has_many :user_episodes

  # Set by `rails episodes:import` for rebroadcasts. A replay may have no
  # original_episode when the description says it's a rerun but no matching
  # title is in the archive.
  belongs_to :original_episode, class_name: "Episode", optional: true
  has_many :replays, -> { reorder(:publish_at) }, class_name: "Episode", foreign_key: :original_episode_id

  default_scope { order(publish_at: :desc) }

  def audio_url
    if Rails.env.development?
      "/audios/#{slug}.mp3"
    elsif Rails.env.production?
      "https://fatsi-hobby.sfo3.cdn.digitaloceanspaces.com/radiolab/audios/#{slug}.mp3"
    else
      super
    end
  end

  def to_param
    slug
  end

  def cut_description
    # remove rest of text after "Our newsletter comes out every Wednesday"
    description.split("Our newsletter comes out every Wednesday").first
  end

  def pretty_length
    return if length.nil?

    minute_seconds = [length / 60 % 60, length % 60].map {
      |t| t.to_s.rjust(2,'0')
    }.join(':')

    if length > 3600
      "#{length / 3600}:#{minute_seconds}"
    else
      minute_seconds
    end

  end
end
