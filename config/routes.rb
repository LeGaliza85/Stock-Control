Rails.application.routes.draw do
  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, param: :token, only: [ :new, :create, :edit, :update ]
  resource :registration, only: [ :new, :create ]
  resources :productos do
    collection do
      get :suggestions
    end
  end
  resources :categorias

  root "productos#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
