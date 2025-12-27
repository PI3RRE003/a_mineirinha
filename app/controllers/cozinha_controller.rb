class CozinhaController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  # Tela Principal (Monitoramento)
  def show
    # Esconde Carrinho, Concluído e Cancelado da tela principal
    # Mostra apenas: Recebido, Preparando, Pronto (se houver esse status)
    @pedidos = Order.where.not(status: [ "Carrinho", "Concluído", "Cancelado" ])
                    .order(created_at: :asc) # Ordem de chegada (mais antigos primeiro)
  end

  # Histórico e Relatórios
  def vendas
    # 1. Base da busca: Concluídos e Cancelados (exclui carrinhos abertos)
    @vendas = Order.where(status: [ "Concluído", "Cancelado", "Entregue" ]).order(created_at: :desc)

    # 2. Filtro de Data Inicial
    if params[:data_inicio].present?
      @vendas = @vendas.where("created_at >= ?", Date.parse(params[:data_inicio]).beginning_of_day)
    end

    # 3. Filtro de Data Final
    if params[:data_final].present?
      @vendas = @vendas.where("created_at <= ?", Date.parse(params[:data_final]).end_of_day)
    end

    # 4. Faturamento: Soma apenas os Concluídos/Entregues DENTRO do filtro de data
    @faturamento_total = @vendas.where.not(status: "Cancelado").sum(:total)

    # 5. Lógica do Produto Campeão (Com proteção para produto deletado)
    # Filtramos apenas pedidos válidos para calcular o campeão
    vendas_validas = @vendas.where.not(status: "Cancelado")

    dados = OrderItem.where(order_id: vendas_validas.select(:id))
                     .group(:product_id)
                     .sum(:quantidade)
                     .max_by { |_, qtd| qtd }

    if dados
      @id_campeao = dados[0]
      @qtd_campea = dados[1]
      @produto_campeao = Product.find_by(id: @id_campeao)
    else
      @id_campeao = nil
      @qtd_campea = 0
      @produto_campeao = nil
    end

      # 6. Geração do PDF
      respond_to do |format|
      format.html # Renderiza vendas.html.erb

      format.pdf do
        render pdf: "Relatorio_Vendas_#{Date.today.strftime('%d-%m-%Y')}",
               template: "products/relatorio_pdf",
               formats: [ :html ],   # <--- ADICIONE ESTA LINHA OBRIGATORIAMENTE
               layout: "pdf",
               orientation: "Landscape",
               page_size: "A4"
        end
    end
  end

  # Ação de Finalizar Pedido (Mantida sua lógica de Pontos)
  def concluir
    @pedido = Order.find(params[:id])

    # 1. Evita clique duplo
    if @pedido.status == "Concluído"
      redirect_to cozinha_path, alert: "Este pedido já foi finalizado antes."
      return
    end

    # 2. Atualiza o status
    if @pedido.update(status: "Concluído")

      # --- LÓGICA DE PONTOS ---
      if @pedido.user.present? && !@pedido.pontos_entregues?
        pontos_totais = 0

        @pedido.order_items.each do |item|
          # Verifica se é o item de 1kg (Lógica específica da sua regra de negócio)
          # Sugestão: Use item.product.gera_pontos? se tiver criado essa coluna
          if item.product.nome.downcase.include?("1kg")
            pontos_totais += item.quantidade
          end
        end

        if pontos_totais > 0
          @pedido.user.increment!(:pontos, pontos_totais)
          @pedido.update_column(:pontos_entregues, true)
          flash[:notice] = "Pedido finalizado! Cliente ganhou #{pontos_totais} pontos."
        else
          flash[:notice] = "Pedido finalizado (sem itens de fidelidade)."
        end
      else
        flash[:notice] = "Pedido finalizado."
      end
      # ------------------------

      redirect_to cozinha_path
    else
      redirect_to cozinha_path, alert: "Erro ao atualizar status."
    end
  end

  # Ação de Cancelar
  def cancelar
    @pedido = Order.find(params[:id])
    @pedido.update(status: "Cancelado")
    redirect_to cozinha_path, alert: "Pedido ##{@pedido.id} foi cancelado."
  end

  private

  def check_admin
    # O 'try' evita erro se current_user for nil (não logado)
    unless current_user.try(:is_admin?)
      redirect_to root_path, alert: "Acesso restrito à equipe da cozinha!"
    end
  end
end
