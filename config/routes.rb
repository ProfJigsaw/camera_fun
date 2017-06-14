Rails.application.routes.draw do
  resources :images do
    member do
      get :inline
      post :update_image
    end
  end

  root 'images#index'
end
