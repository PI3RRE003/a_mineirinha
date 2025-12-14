class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  OPCOES_PAGAMENTO = [ "Pix", "Cartão de Crédito", "Dinheiro / Espécie" ]

  # Valida se o pagamento é um dos permitidos, mas só quando o status for "Recebido"
  validates :tipo_pagamento, inclusion: { in: OPCOES_PAGAMENTO }, on: :update, if: -> { status == "Recebido" }

  # Método para calcular total (boa prática)
  def calculate_total
    order_items.sum { |item| item.preco_unitario * item.quantidade }
  end
end
