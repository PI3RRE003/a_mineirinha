json.extract! product, :id, :nome, :descricao, :preco, :disponivel, :created_at, :updated_at
json.url product_url(product, format: :json)
