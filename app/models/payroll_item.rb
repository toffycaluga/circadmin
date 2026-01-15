# frozen_string_literal: true

# == Schema Information
#
# Table name: payroll_items
#
#  id         :integer          not null, primary key
#  payroll_id :integer          not null
#  name       :string
#  job_role   :string
#  amount     :decimal(, )
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

  # Evita cambiar la FK vía updates masivos
  attr_readonly :payroll_id

  # --- Normalizaciones / limpieza de datos ---
  before_validation :strip_strings
  before_validation :cast_amount
  before_validation :sanitize_notes

  # --- Validaciones ---
  validates :name, presence: true, length: { maximum: 200 }
  validates :job_role, presence: true, length: { maximum: 100 }
  validates :amount,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 1_000_000_000
            }
  validates :notes, length: { maximum: 5000 }, allow_blank: true

  # --- Consistencia contable (centralizado en el modelo) ---
  after_commit :update_payroll_total, on: %i[create update destroy]

  # --- Scopes útiles ---
  scope :ordered, -> { order(created_at: :asc) }

  private

  def strip_strings
    self.name = name.to_s.strip.presence
    self.job_role = job_role.to_s.strip.presence
    self.notes = notes.to_s.strip.presence if notes.present?
  end

  def cast_amount
    return if amount.is_a?(Numeric) || amount.is_a?(BigDecimal)

    self.amount = begin
      BigDecimal(amount.to_s)
    rescue ArgumentError, TypeError
      nil
    end
  end

  def sanitize_notes
    return unless notes.present?

    self.notes = ActionController::Base.helpers.sanitize(notes)
  end

  def update_payroll_total
    payroll.recalculate_total!
  rescue StandardError => e
    Rails.logger.error("[PayrollItem#update_payroll_total] #{e.class}: #{e.message}")
  end
end
