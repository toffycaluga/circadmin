# frozen_string_literal: true

# == Schema Information
#
# Table name: payroll_items
#
#  id         :integer          not null, primary key
#  payroll_id :integer          not null
#  name       :string
#  role       :string
#  amount     :decimal(12, 2)   # <- recomendable fijar precision/scale en la migración
#  notes      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payroll_items_on_payroll_id  (payroll_id)
#
class PayrollItem < ApplicationRecord
  belongs_to :payroll, inverse_of: :payroll_items, touch: true

  # No permitir cambiar la FK vía updates masivos
  attr_readonly :payroll_id

  # --- Normalizaciones / limpieza de datos ---
  before_validation :strip_strings
  before_validation :cast_amount
  before_validation :sanitize_notes

  # --- Validaciones ---
  validates :name, presence: true, length: { maximum: 200 }
  validates :role, presence: true, length: { maximum: 100 }
  validates :amount,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 1_000_000_000 # evita números absurdos
            }
  validates :notes, length: { maximum: 5000 }, allow_blank: true

  # --- Callbacks de consistencia contable ---
  # Centraliza el recálculo aquí. Si lo dejas, elimina las llamadas en el controlador.
  after_commit :update_payroll_total, on: %i[create update destroy]

  # --- Scopes útiles ---
  scope :ordered, -> { order(created_at: :asc) }

  private

  def strip_strings
    self.name = name.to_s.strip.presence
    self.role = role.to_s.strip.presence
    # notes puede ser texto largo; sólo quita espacios extremos
    self.notes = notes.to_s.strip.presence if notes.present?
  end

  def cast_amount
    # Convierte strings a BigDecimal de forma segura
    return if amount.is_a?(Numeric) || amount.is_a?(BigDecimal)

    self.amount = begin
      BigDecimal(amount.to_s)
    rescue ArgumentError, TypeError
      nil
    end
  end

  def sanitize_notes
    return unless notes.present?

    # Evita XSS si en alguna vista se renderiza como HTML
    self.notes = ActionController::Base.helpers.sanitize(notes)
  end

  def update_payroll_total
    payroll.recalculate_total!
  rescue StandardError => e
    Rails.logger.error("[PayrollItem#update_payroll_total] #{e.class}: #{e.message}")
  end
end
