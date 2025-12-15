# db/seeds.rb

puts "🌱 Iniciando atualização do Admin..."

# Senha de fallback apenas para teste local, em produção usará a ENV
senha_secreta = ENV['ADMIN_PASSWORD']

# Localiza ou inicializa o usuário
admin = User.find_or_initialize_by(email: 'gisantos880@gmail.com')

# Define os dados
admin.nome = 'Chef Giovanna'
admin.password = senha_secreta
admin.password_confirmation = senha_secreta

# --- A CORREÇÃO ESTÁ AQUI EMBAIXO ---
# Trocamos admin.admin por admin.is_admin
admin.is_admin = true
# ------------------------------------

# Preenche dados obrigatórios (caso existam no seu model)
admin.telefone = '11999999999' if admin.respond_to?(:telefone)
admin.endereco = 'Cozinha Central - Rua do Pão de Queijo, 100' if admin.respond_to?(:endereco)

if admin.save
  puts "✅ SUCESSO! Admin 'Chef Giovanna' (gisantos880@gmail.com) criado/atualizado."
else
  puts "❌ ERRO FATAL: Não foi possível salvar o Admin."
  puts "MOTIVO: #{admin.errors.full_messages.join(', ')}"
end
