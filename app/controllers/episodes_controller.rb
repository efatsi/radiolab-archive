class EpisodesController < ApplicationController
  before_action :authenticate_user!, only: [:update_listen, :update_favorite]

  def index
    if current_user
      # cache in memory to avoid N+1 queries
      @user_episodes = current_user.user_episodes.to_a
    end

    if current_user && params[:filter].in?(%w[unlistened listened])
      @filter = params[:filter]

      listened_ids = @user_episodes.select(&:listened?).map(&:episode_id)
      if @filter == "listened"
        @episodes = Episode.where(id: listened_ids)
      else
        @episodes = Episode.where.not(id: listened_ids)
      end
    else
      @episodes = Episode.all
    end
  end

  def favorites_index
    if params[:token]
      @user = User.find_by!(token: params[:token])
    elsif current_user
      @user = current_user
    else
      return redirect_to root_path
    end

    @user_episodes = @user.user_episodes.where(favorite: true).to_a
    @episodes = Episode.where(id: @user_episodes.map(&:episode_id))
  end

  def show
  end

  def roulette
    @random_episodes = Episode.all.sample(3).sort_by(&:publish_at)
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
