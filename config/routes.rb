Rails.application.routes.draw do
  get "cozinha/show"
  get "orders/index"
  get "orders/show"
  get "orders/new"
  get "orders/create"
  devise_for :users
  resources :products

  # Rotas do Carrinho
  get "carrinho", to: "cart#show", as: "carrinho"
  post "carrinho/add/:product_id", to: "cart#add", as: "add_to_cart"
  delete "carrinho/remove/:id", to: "cart#remove", as: "remove_from_cart"
  post "carrinho/finalizar", to: "cart#finalizar", as: "finalizar_pedido"

  # Rota da Cozinha
  get "cozinha", to: "cozinha#show", as: "cozinha"

  patch "cozinha/:id/concluir", to: "cozinha#concluir", as: "concluir_pedido"
  patch "cozinha/:id/cancelar", to: "cozinha#cancelar", as: "cancelar_pedido"
  get "vendas", to: "cozinha#vendas", as: "historico_vendas"

  # Perfil Usuario
  get "perfil", to: "profile#show", as: "perfil_usuario"


  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
end
