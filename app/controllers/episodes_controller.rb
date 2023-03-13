class EpisodesController < ApplicationController
  before_action :authenticate_user!, only: [:update_listen, :update_favorite]

  def index
    if current_user
      # cache in memory to avoid N+1 queries
      @user_episodes = current_user.user_episodes.to_a
    end
  end

  def show
  end

  def update_listen
    update_and_render(:listened)
  end

  def update_favorite
    update_and_render(:favorite)
  end

  private

  def update_and_render(attribute)
    eu = current_user.user_episodes.find_or_initialize_by(episode: episode)
    eu.toggle!(attribute)

    render turbo_stream: turbo_stream.replace(
      "episode-row-#{episode.id}",
      partial: "episodes/episode_row",
      locals: { episode: episode, eu: eu }
    )
  end

  def episode
    @episode ||= Episode.find_by(slug: params[:slug])
  end
  helper_method :episode
end
