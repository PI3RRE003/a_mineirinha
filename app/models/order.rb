class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  OPCOES_PAGAMENTO = [ "Pix", "Dinheiro", "Cartão de Crédito", "Cartão de Débito" ]

  validates :tipo_pagamento, inclusion: {
    in: [ "Pix", "Dinheiro", "Cartão de Crédito", "Cartão de Débito" ],
    message: "não é válido. Escolha entre Pix, Dinheiro ou Cartão."
  }, allow_nil: true
  # Valida se o pagamento é um dos permitidos, mas só quando o status for "Recebido"
  validates :tipo_pagamento, inclusion: { in: OPCOES_PAGAMENTO }, on: :update, if: -> { status == "Recebido" }


  # Método para calcular total (boa prática)
  def calculate_total
    order_items.sum { |item| item.preco_unitario * item.quantidade }
  end


def gerar_mensagem_whatsapp
    linha = "---------------------------"

    itens_texto = order_items.map do |item|
      "• #{item.quantidade}x #{item.product.nome}"
    end.join("\n")

    texto = <<~TEXTO
      *NOVO PEDIDO - A MINEIRINHA* 🧀
      #{linha}
      *Cliente:* #{user.nome}
      *Entrega:* #{user.endereco}
      #{linha}
      *PEDIDO:*
      #{itens_texto}
      #{linha}
      *TOTAL:* #{ActionController::Base.helpers.number_to_currency(total)}
      *FORMA DE PAGAMENTO:* #{tipo_pagamento}
      #{ "*TROCO PARA:* " + troco if tipo_pagamento == 'Dinheiro' && troco.present? }
      #{linha}
      _Obrigado pela preferência!_
    TEXTO

    ERB::Util.url_encode(texto)
  end

  private

  def entregar_pontos_fidelidade
      # 1. Normalização do Status (para aceitar 'Concluído', 'concluido', 'CONCLUÍDO')
      status_atual = self.status.to_s.downcase.strip
      status_alvo  = "concluído" # ou "concluido" dependendo de como salvou

      # Verifica se o status bate (com ou sem acento)
      if (status_atual == "concluído" || status_atual == "concluido") && !pontos_entregues? && user.present?

        pontos_totais = 0

        # 2. Loop Inteligente
        order_items.each do |item|
          nome_produto = item.product.nome.downcase

          # Apenas SOMA se for 1kg. Se não for, ele simplesmente passa para o próximo (não faz nada).
          if nome_produto.include?("1kg")
            pontos_totais += item.quantidade
          end
        end

        # 3. Entrega dos Pontos
        # Usamos update_column para ser mais rápido e pular validações
        if pontos_totais > 0
          ActiveRecord::Base.transaction do
            novos_pontos = (user.pontos || 0) + pontos_totais
            user.update_column(:pontos, novos_pontos) # update_column é mais seguro aqui
            self.update_column(:pontos_entregues, true)
          end
          puts "🎁 FIDELIDADE: +#{pontos_totais} pontos para #{user.nome || 'Cliente'}"
        else
          # Se ele comprou coisas, mas nada de 1kg, marcamos como entregue para não checar de novo
          self.update_column(:pontos_entregues, true)
        end
      end
  end
end
