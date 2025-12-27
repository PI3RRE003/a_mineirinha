class Product < ApplicationRecord
  has_many :order_items
  has_one_attached :imagem

  validates :descricao, length: {
    maximum: 100,
    message: "é muito longa (máximo de 200 caracteres)"
  }

  validate :imagem_formato_e_tamanho
  private

  def imagem_formato_e_tamanho
    return unless imagem.attached?

    # Valida Tamanho (5MB)
    if imagem.byte_size > 5.megabytes
      errors.add(:imagem, "é muito pesada (máximo 5MB)")
    end

    # Valida Formato
    if !imagem.content_type.in?(%w[image/jpeg image/png])
      errors.add(:imagem, "deve ser do formato JPG ou PNG")
    end
  end
end
