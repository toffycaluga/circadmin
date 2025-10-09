# frozen_string_literal: true

class PayrollItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payroll
  before_action :set_payroll_item, only: %i[edit update destroy]

  # POST /payrolls/:payroll_id/items
  def create
    @payroll_item = @payroll.payroll_items.new
    @payroll.with_lock do
      @payroll_item.assign_attributes(safe_payroll_item_params)

      ActiveRecord::Base.transaction do
        if @payroll_item.save
          @payroll.recalculate_total!
          @payroll_item = PayrollItem.new(payroll: @payroll) # limpia el form
          flash.now[:notice] = t("flash.payroll_items.create.success")

          render turbo_stream: [
            turbo_stream.update(
              "payroll-items",
              partial: "payrolls/rows",
              locals: { payroll: @payroll, payroll_item: @payroll_item }
            ),
            turbo_stream.update(
              "payroll-total",
              partial: "payrolls/total",
              locals: { payroll: @payroll }
            )
          ]
        else
          flash.now[:alert] = t("flash.payroll_items.create.failure")
          render turbo_stream: turbo_stream.replace(
            "payroll-items",
            partial: "payrolls/rows",
            locals: { payroll: @payroll, payroll_item: @payroll_item }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  # GET /payrolls/:payroll_id/items/:id/edit
  def edit
    render turbo_stream: turbo_stream.update(
      "payroll_item_modal",
      partial: "payroll_items/modal",
      locals: { payroll: @payroll, payroll_item: @payroll_item }
    )
  end

  # PATCH/PUT /payrolls/:payroll_id/items/:id
  def update
    @payroll.with_lock do
      ActiveRecord::Base.transaction do
        if @payroll_item.update(safe_payroll_item_params)
          @payroll.recalculate_total!
          @payroll_item = PayrollItem.new(payroll: @payroll)
          flash.now[:notice] = t("flash.payroll_items.update.success")

          render turbo_stream: [
            turbo_stream.update(
              "payroll-items",
              partial: "payrolls/rows",
              locals: { payroll: @payroll, payroll_item: @payroll_item }
            ),
            turbo_stream.update(
              "payroll-total",
              partial: "payrolls/total",
              locals: { payroll: @payroll }
            ),
            turbo_stream.update("payroll_item_modal", "")
          ]
        else
          flash.now[:alert] = t("flash.payroll_items.update.failure")
          render turbo_stream: turbo_stream.update(
            "payroll_item_modal",
            partial: "payroll_items/modal",
            locals: { payroll: @payroll, payroll_item: @payroll_item }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /payrolls/:payroll_id/items/:id
  def destroy
    @payroll.with_lock do
      ActiveRecord::Base.transaction do
        @payroll_item.destroy!
        @payroll.recalculate_total!
      end
    end

    @payroll_item = PayrollItem.new(payroll: @payroll)
    flash.now[:notice] = t("flash.payroll_items.destroy.success")

    render turbo_stream: [
      turbo_stream.update(
        "payroll-items",
        partial: "payrolls/rows",
        locals: { payroll: @payroll, payroll_item: @payroll_item }
      ),
      turbo_stream.update(
        "payroll-total",
        partial: "payrolls/total",
        locals: { payroll: @payroll }
      ),
      turbo_stream.update("payroll_item_modal", "")
    ]
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
    Rails.logger.warn("[PayrollItemsController#destroy] #{e.class}: #{e.message}")
    flash[:alert] = t("flash.payroll_items.destroy.failure")
    redirect_back fallback_location: root_path
  end

  private

  # 🔒 Nunca aceptes payroll_id/circus_id del cliente; se resuelve por asociación y contexto.
  def set_payroll
    @payroll = Payroll.find_by!(
      id: params[:payroll_id],
      circus_id: current_user.circus_ids # garantiza pertenencia del usuario
    )
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t("flash.payroll_items.payroll_not_found")
    redirect_back fallback_location: root_path
  end

  def set_payroll_item
    @payroll_item = @payroll.payroll_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t("flash.payroll_items.not_found")
    redirect_back fallback_location: root_path
  end

  # ✅ Filtro estricto + casting + sanitizado = menos falsos positivos y más seguridad.
  def safe_payroll_item_params
    raw = params.require(:payroll_item).permit(:name, :role, :amount, :notes)

    # Casting seguro de monto (evita inyecciones tipo "1e309" o strings raros)
    raw[:amount] = begin
      BigDecimal(raw[:amount].to_s)
    rescue ArgumentError, TypeError
      0
    end

    # Sanitiza notas para prevenir XSS si luego se renderiza como HTML
    raw[:notes] = ActionController::Base.helpers.sanitize(raw[:notes])

    # Asegura que no haya llaves extra (defensa-in-profundidad)
    raw.slice(:name, :role, :amount, :notes)
  end
end
