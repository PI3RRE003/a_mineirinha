class CartController < ApplicationController
  before_action :authenticate_user!

  # 1. MOSTRAR CARRINHO
  def show
    # Busca o pedido que está em aberto (status "carrinho")
    @order = current_user.orders.find_by(status: "carrinho")

    # Se não existir, cria um objeto vazio na memória só para não quebrar a tela
    @order ||= Order.new(order_items: [])

    # Para a lista de itens, ordenamos por ID para não ficarem "pulando" quando atualiza
    @itens = @order.order_items.order(:id)

    # O Histórico (tudo que ele já pediu)
    @historico = current_user.orders
                             .where.not(status: "carrinho")
                             .order(created_at: :desc)
  end

  # 2. ADICIONAR ITEM (Vem da Home ou Menu)
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

    # Redireciona de volta para onde o usuário estava
    redirect_back fallback_location: root_path, notice: "😋 #{product.nome} adicionado!"
  end

  # 3. AUMENTAR QUANTIDADE (Botão +)
  def increase_quantity
    order_item = OrderItem.find(params[:id])
    order_item.increment!(:quantidade) # Aumenta 1 direto no banco

    atualizar_total
    redirect_to carrinho_path
  end

  # 4. DIMINUIR QUANTIDADE (Botão -)
  def decrease_quantity
    order_item = OrderItem.find(params[:id])

    if order_item.quantidade > 1
      order_item.decrement!(:quantidade) # Diminui 1
    else
      order_item.destroy # Se for 1, remove do carrinho
    end

    atualizar_total
    redirect_to carrinho_path
  end

  # 5. REMOVER ITEM (Botão Excluir/Lixeira)
  def remove
    order_item = OrderItem.find(params[:id])
    order_item.destroy

    atualizar_total
    redirect_to carrinho_path, notice: "Item removido."
  end

# 6. FINALIZAR PEDIDO
def finalizar
    puts ">>> INICIANDO FINALIZAR PEDIDO <<<"

    @order = current_user.orders.find_by(status: "carrinho")

    unless @order
      puts ">>> ERRO: Carrinho vazio ou não encontrado."
      redirect_to root_path, alert: "Carrinho vazio."
      return
    end

    puts ">>> PEDIDO ENCONTRADO ID: #{@order.id}"
    puts ">>> PARAMS RECEBIDOS: #{params.inspect}"

    # Recupera ou define o endereço
    endereco_final = params[:endereco].presence || current_user.endereco
    puts ">>> ENDEREÇO FINAL: #{endereco_final}"

    # Tenta atualizar
    sucesso = @order.update(
      status: "Recebido",
      tipo_pagamento: params[:tipo_pagamento],
      troco: params[:troco],
      endereco: endereco_final, # Garante que está salvando o endereço
      total: @order.order_items.sum { |i| i.preco_unitario * i.quantidade }
    )

    if sucesso
      puts ">>> SUCESSO: Pedido atualizado para Recebido!"
      redirect_to perfil_usuario_path, notice: "Pedido realizado!"
    else
      puts ">>> FALHA AO SALVAR! ERROS DO MODEL: <<<"
      puts @order.errors.full_messages
      redirect_to carrinho_path, alert: "Erro: #{@order.errors.full_messages.to_sentence}"
    end
end


  private

  # Método auxiliar para manter o total sempre correto no banco
  def atualizar_total
    @order = current_user.orders.find_by(status: "carrinho")
    return unless @order

    total = @order.order_items.sum { |item| item.preco_unitario * item.quantidade }
    @order.update(total: total)
  end
end
