Rails.application.routes.draw do
  get "cozinha/show"
  get "orders/index"
  get "orders/show"
  get "orders/new"
  get "orders/create"
  devise_for :users
  get "produtos/arquivados", to: "products#arquivados", as: "produtos_arquivados"
  resources :products

  # Rotas do Carrinho
  get "carrinho", to: "cart#show", as: "carrinho"
  post "carrinho/add/:product_id", to: "cart#add", as: "add_to_cart"
  delete "carrinho/remove/:id", to: "cart#remove", as: "remove_from_cart"
  post "carrinho/finalizar", to: "cart#finalizar", as: "finalizar_pedido"

  # Aumentar/Diminuir Quantidade
  post "carrinho/aumentar/:id", to: "cart#increase_quantity", as: "increase_item"
  post "carrinho/diminuir/:id", to: "cart#decrease_quantity", as: "decrease_item"

  # Rota da Cozinha
  get "cozinha", to: "cozinha#show", as: "cozinha"
  patch "cozinha/:id/concluir", to: "cozinha#concluir", as: "concluir_pedido"

  # Rota de Cancelamento da COZINHA (Mantivemos o nome original aqui para não quebrar a cozinha)
  patch "cozinha/:id/cancelar", to: "cozinha#cancelar", as: "cancelar_pedido"

  get "vendas", to: "cozinha#vendas", as: "historico_vendas"

  # Perfil Usuario
  get "perfil", to: "profile#show", as: "perfil_usuario"

  # --- CORREÇÃO AQUI: Mudamos o nome para 'cancelar_pedido_cliente' ---
  patch "pedido/:id/cancelar", to: "profile#cancelar_pedido", as: "cancelar_pedido_cliente"

  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "products#index"
end
