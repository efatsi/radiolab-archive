Rails.application.routes.draw do
  devise_for :users

  root "episodes#index"

  get "/:slug", to: "episodes#show", as: :episode
  post "/:slug/listen", to: "episodes#update_listen", as: :listen
  post "/:slug/favorite", to: "episodes#update_favorite", as: :favorite
end
