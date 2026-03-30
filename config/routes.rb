Rails.application.routes.draw do
  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, param: :token, only: [ :new, :create, :edit, :update ]
  resource :registration, only: [ :new, :create ]
  resources :notificaciones, only: [], path_names: { marcar_leida: 'marcar-leida' } do
    member do
      post :marcar_leida, as: :marcar_leida
    end
    collection do
      post :marcar_todas_leidas, as: :marcar_todas_leidas
      delete :eliminar_todas, as: :eliminar_todas
      delete :eliminar_leidas, as: :eliminar_leidas
    end
  end
  resources :productos do
    collection do
      get :suggestions
      post :buscar_por_imagen
    end
    member do
      get :fotos_json
    end
    resources :notas, only: [ :create, :update, :destroy ]
  end
  resources :categorias do
    collection do
      post :quick_create, to: "categorias#quick_create"
    end
  end

  get "gestionar_usuarios", to: "usuarios#gestionar", defaults: { format: "html" }
  get "usuarios-registrados", to: "usuarios#registrados", as: :usuarios_registrados
  resources :usuarios do
    collection do
      post :switch
      post :switch_to_admin
      post :switch_with_password
      post :switch_user_with_password
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
