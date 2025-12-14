class CartController < ApplicationController
  before_action :authenticate_user!

  # 1. MOSTRAR CARRINHO
  def show
    # 1. O Carrinho Atual (o que ele vai pagar agora)
    @order = current_user.orders.find_by(status: "carrinho")
    @order ||= Order.new(order_items: [])

    # 2. O Histórico (tudo que ele já pediu)
    # Pegamos tudo que NÃO é 'carrinho', ordenando do mais recente para o antigo
    @historico = current_user.orders
                             .where.not(status: "carrinho")
                             .order(created_at: :desc)
  end
  # 2. ADICIONAR ITEM
  def add
    @order = current_user.orders.find_or_create_by(status: "carrinho")

    product = Product.find(params[:product_id])
    order_item = @order.order_items.find_or_initialize_by(product: product)

    if order_item.new_record?
      order_item.preco_unitario = product.preco
      order_item.quantidade = 1
    else
      order_item.quantidade += 1
    end

    order_item.save
    atualizar_total
    redirect_to root_path, notice: "😋 #{product.nome} adicionado!"
  end

  # 3. REMOVER ITEM
  def remove
    order_item = OrderItem.find(params[:id])
    order_item.destroy
    atualizar_total
    redirect_to carrinho_path, notice: "Item removido."
  end

  # 4. FINALIZAR PEDIDO (AQUI ESTAVA O PROBLEMA)
  def finalizar
    @order = current_user.orders.find_by(status: "carrinho")

    # --- CORREÇÃO: Captura o pagamento do formulário ---
    pagamento = params[:tipo_pagamento]

    # Validação: Se não escolheu, manda voltar
    if pagamento.blank?
      redirect_to carrinho_path, alert: "⚠️ Por favor, selecione uma forma de pagamento (Pix, Cartão ou Dinheiro)."
      return
    end

    if @order
      # Atualiza com TODOS os dados necessários para a cozinha
      @order.update(
        status: "Recebido", # Mudei para "Recebido" para combinar com a cor Laranja da cozinha
        tipo_pagamento: pagamento, # <--- SALVA O PAGAMENTO AGORA!
        endereco: current_user.endereco, # Salva o endereço atual do cliente
        total: @order.order_items.sum { |item| item.preco_unitario * item.quantidade } # Garante o total certo
      )

      # Pontos de fidelidade
      current_user.increment!(:pontos)

      redirect_to root_path, notice: "Pedido Enviado! Forma de pagamento: #{pagamento}. (+1 ponto 🧀)"
    else
      redirect_to root_path, alert: "Erro ao processar o carrinho."
    end
  end

  private

  def atualizar_total
    @order = current_user.orders.find_by(status: "carrinho")
    return unless @order # Evita erro se não tiver ordem

    total = @order.order_items.sum { |item| item.preco_unitario * item.quantidade }
    @order.update(total: total)
  end
end
