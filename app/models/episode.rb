class Episode < ApplicationRecord
  has_many :user_episodes

  default_scope { order(publish_at: :desc) }

  def audio_url
    if Rails.env.development?
      return "/audios/#{slug}.mp3"
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
