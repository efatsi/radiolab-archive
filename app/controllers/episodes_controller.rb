class EpisodesController < ApplicationController
  def index
  end

  def show
  end

  private

  def episode
    @episode ||= Episode.find_by(slug: params[:slug])
  end
  helper_method :episode
end
