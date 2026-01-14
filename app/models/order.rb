class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  OPCOES_PAGAMENTO = [ "Pix", "Dinheiro", "Cartão de Crédito", "Cartão de Débito" ]

  # Callback para processar fidelidade após salvar
  after_save :entregar_pontos_fidelidade

  # Remova as duas validações anteriores e use esta:
  validates :tipo_pagamento, inclusion: {
    in: OPCOES_PAGAMENTO,
    message: "%{value} não é uma opção válida"
  }, if: -> { status == "Recebido" }

  # Método para calcular o total base (sem taxas da maquininha)
  # Útil para o Controller saber o valor original antes de aplicar os 2% ou 5%
  def calculate_base_total
    order_items.sum { |item| item.preco_unitario * item.quantidade }
  end

  def gerar_mensagem_whatsapp
    linha = "---------------------------"

    itens_texto = order_items.map do |item|
      "• #{item.quantidade}x #{item.product.nome}"
    end.join("\n")

    # Usamos self.total (o valor salvo no banco que já inclui a taxa calculada no controller)
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
    # Normalização do Status
    status_atual = self.status.to_s.downcase.strip

    # Verifica se o status é concluído e se os pontos ainda não foram entregues
    if (status_atual == "concluído" || status_atual == "concluido") && !pontos_entregues? && user.present?
      pontos_totais = 0

      order_items.each do |item|
        nome_produto = item.product.nome.downcase
        # Regra: Produtos de 1kg valem pontos
        if nome_produto.include?("1kg")
          pontos_totais += item.quantidade
        end
      end

      if pontos_totais > 0
        ActiveRecord::Base.transaction do
          novos_pontos = (user.pontos || 0) + pontos_totais
          user.update_column(:pontos, novos_pontos)
          self.update_column(:pontos_entregues, true)
        end
      else
        self.update_column(:pontos_entregues, true)
      end
    end
  end
end
