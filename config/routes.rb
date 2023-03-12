Rails.application.routes.draw do
  devise_for :users

  root "episodes#index"

  get "/:slug", to: "episodes#show", as: :episode
end
