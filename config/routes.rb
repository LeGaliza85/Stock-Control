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

  get "gestionar_usuarios", to: "usuarios#gestionar", defaults: { format: "html" }
  resources :usuarios do
    collection do
      post :switch
      post :switch_to_admin
      post :switch_with_password
      post :verify_password
      post :verify_admin
    end
  end

  scope :ia, as: :ia do
    post :analyze, to: "image_analysis#analyze"
    get :services, to: "image_analysis#services"
    resource :config, only: [], controller: "image_analysis" do
      patch :update, action: :update_config
    end
  end

  get :config_ia, to: "configuracion#ia", as: :config_ia

  root "productos#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
