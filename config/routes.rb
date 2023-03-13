Rails.application.routes.draw do
  devise_for :users

  root "episodes#index"

  get "/favorites", to: "episodes#favorites_index", as: :favorites
  get "/favorites/:token", to: "episodes#favorites_index", as: :user_favorites

  # Keep these last, since going off slugs
  get "/:slug", to: "episodes#show", as: :episode
  post "/:slug/listen", to: "episodes#update_listen", as: :listen
  post "/:slug/favorite", to: "episodes#update_favorite", as: :favorite
end
