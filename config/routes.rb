# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :games, only: [:create] do
        member do
          put :throw_ball
          get :score
        end
      end
    end
  end
end
