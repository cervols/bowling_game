# frozen_string_literal: true

Rails.application.routes.draw do
  post "/api-tokens", to: "api_tokens#create"
  delete "/api-tokens", to: "api_tokens#destroy"
  get "/api-tokens", to: "api_tokens#index"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :games, only: [:create] do
        member do
          post :throw_ball
          get :score
        end
      end
    end
  end
end
