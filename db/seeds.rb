# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

# db/seeds.rb

puts "🌱 Criando Admin..."

# ENV['ADMIN_PASSWORD'] vai buscar a senha no cofre do Render
senha_secreta = ENV['ADMIN_PASSWORD']

if senha_secreta.blank?
  puts "⚠️  AVISO: Senha de admin não configurada. Pulei a criação."
else
  User.find_or_create_by!(email: 'gisantos880@gmail.com') do |user|
    user.nome = 'Chef Giovanna'
    user.password = senha_secreta
    user.password_confirmation = senha_secreta
    user.admin = true
    user.endereco = 'Rua da Matriz' # Se for obrigatório no seu model
    user.telefone = '999999999'     # Se for obrigatório
  end
  puts "✅ Admin criado com sucesso!"
end
