class User < ApplicationRecord
  attr_accessor :login
  has_one :cart, dependent: :destroy
  has_many :orders

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # --- CORREÇÃO: 'minimum' escreve com m no final ---
  validates :nome, presence: { message: "é obrigatório" }, length: { minimum: 4, maximum: 60, message: "Deve ter de 4 a 60 caracteres" }

  validates :email, presence: { message: "é obrigatório" }, length: { minimum: 3, maximum: 60, message: "Deve ter de 4 a 60 caracteres" }

  # --- AJUSTE TELEFONE: Coloquei minimum também, senão aceita 1 número ---
  validates :telefone, presence: { message: "é obrigatório" }, length: { minimum: 10, maximum: 15, message: "Deve conter DDD + Número (apenas números)" }
  validates :telefone, presence: true, uniqueness: { case_sensitive: false }

  validates :endereco, presence: { message: "é obrigatório" }, length: { maximum: 200, message: "Endereço muito longo!" }

  # --- CORREÇÃO PRINCIPAL: on: :update ---
  # Isso impede o erro na hora de criar a conta
  validate :nova_senha_diferente_da_atual, on: :update

  before_validation :limpar_dados

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where([ "lower(telefone) = :value OR lower(email) = :value", { value: login.downcase } ]).first
    elsif conditions.has_key?(:telefone) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def cart_item_count
    # 1. Procura um pedido do usuário que tenha o status 'carrinho'
    pedido_atual = orders.find_by(status: "carrinho")

    # 2. Se achou o pedido, soma a quantidade dos itens. Se não, retorna 0.
    if pedido_atual
      pedido_atual.order_items.sum(:quantidade)
    else
      0
    end
  end

  private

  def limpar_dados
    self.nome = nome&.strip&.titleize
    # Remove tudo que não for número do telefone antes de salvar
    self.telefone = telefone&.gsub(/\D/, "")
  end

  def nova_senha_diferente_da_atual
    return if password.blank? # Se não preencheu senha, pula

    # Verifica se a senha nova bate com a hash salva no banco
    if password.present? && valid_password?(password)
      errors.add(:password, "não pode ser igual à atual, escolha uma nova")
    end
  end
end
