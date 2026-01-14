class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  OPCOES_PAGAMENTO = [ "Pix", "Dinheiro", "Cartão de Crédito", "Cartão de Débito" ]

  after_save :entregar_pontos_fidelidade

  validates :tipo_pagamento, inclusion: {
    in: OPCOES_PAGAMENTO,
    message: "%{value} não é uma opção válida"
  }, if: -> { status == "Recebido" }

  def calculate_base_total
    order_items.sum { |item| item.preco_unitario * item.quantidade }
  end

  def gerar_mensagem_whatsapp
    h = ActionController::Base.helpers

    msg = "*🧀 NOVO PEDIDO - PÃO DE QUEIJO*\n"
    msg += "--------------------------------\n"
    msg += "*Cliente:* #{user.nome}\n"
    msg += "*Endereço:* #{user.endereco}\n"
    msg += "--------------------------------\n"

    order_items.each do |item|
      msg += "• #{item.quantidade}x #{item.product.nome} (#{h.number_to_currency(item.preco_unitario)})\n"
    end

    msg += "--------------------------------\n"
    msg += "*Forma de Pagamento:* #{tipo_pagamento}\n"

    if troco.present?
      msg += "*Troco para:* #{troco}\n"
    end

    # Alterado para usar o método dinâmico pix_copia_e_cola
    if tipo_pagamento == "Pix" || status == "carrinho"
      msg += "\n*PIX COPIA E COLA (Valor: #{h.number_to_currency(total)}):*\n"
      msg += "```#{pix_copia_e_cola}```\n\n"
      msg += "_Toque no código acima para copiar, cole no seu banco na opção 'Pix Copia e Cola' e confirme o valor._\n"
      msg += "_Após pagar, favor enviar o comprovante!_\n"
    end

    msg += "--------------------------------\n"
    msg += "*TOTAL: #{h.number_to_currency(total)}*"

    ERB::Util.url_encode(msg)
  end

  # Gerador Dinâmico de Código Pix (Padrão EMV BC)
  def pix_copia_e_cola
    return "" if total.blank?

    # Configurações - Use apenas números na chave e letras simples no nome
    chave  = "+5587981334781"
    nome   = "A MINEIRINHA"
    cidade = "CANAPI"
    valor  = sprintf("%.2f", total)
    txt_id = "PEDIDO#{id}"

    # Helper para montar os blocos ID + Tamanho + Conteúdo
    def b(id, conteudo)
      "#{id}#{conteudo.length.to_s.rjust(2, '0')}#{conteudo}"
    end

    # Montagem do corpo do Payload
    corpo = "000201" # Payload Format
    corpo += b("26", "0014br.gov.bcb.pix01#{chave.length.to_s.rjust(2, '0')}#{chave}")
    corpo += "52040000" # MCC
    corpo += "5303986"  # Moeda (BRL)
    corpo += b("54", valor)
    corpo += "5802BR"   # País
    corpo += b("59", nome)
    corpo += b("60", cidade)
    corpo += b("62", b("05", txt_id))
    corpo += "6304"     # CRC16 Placeholder

    corpo + calcular_crc16(corpo)
  end

  private

  # Algoritmo CRC16 CCITT-FALSE (O padrão exigido pelos bancos)
  def calcular_crc16(payload)
    crc = 0xFFFF
    payload.each_byte do |b|
      crc ^= (b << 8)
      8.times do
        if (crc & 0x8000) != 0
          crc = (crc << 1) ^ 0x1021
        else
          crc <<= 1
        end
      end
    end
    (crc & 0xFFFF).to_s(16).upcase.rjust(4, "0")
  end

  def entregar_pontos_fidelidade
    status_atual = self.status.to_s.downcase.strip
    if (status_atual == "concluído" || status_atual == "concluido") && !pontos_entregues? && user.present?
      pontos_totais = 0
      order_items.each do |item|
        nome_produto = item.product.nome.downcase
        pontos_totais += item.quantidade if nome_produto.include?("1kg")
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
