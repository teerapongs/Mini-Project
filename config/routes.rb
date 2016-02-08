Rails.application.routes.draw do

  root "dashboard#index"

  resources :channels, only: [] do
    resources :standups, only: :index
  end

  resources :users, only: [ :index, :update ]
  resources :settings, only: [ :index, :update, :create ]

  namespace :api do
    resources :standups, only: [] do
      get :start, on: :collection
    end

    get 'start' => 'standups#start'
  end

end
