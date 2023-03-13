class Episode < ApplicationRecord
  has_many :user_episodes

  default_scope { order(publish_at: :desc) }

  def to_param
    slug
  end

  def cut_description
    # remove rest of text after "Our newsletter comes out every Wednesday"
    description.split("Our newsletter comes out every Wednesday").first
  end
end
