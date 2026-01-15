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
          # El total se recalcula en el modelo (after_commit)
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
          # El total se recalcula en el modelo (after_commit)
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
        # El total se recalcula en el modelo (after_commit)
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
      circus_id: current_user.circus_ids
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

  # ✅ Filtro estricto + casting + sanitizado
  def safe_payroll_item_params
    raw = params.require(:payroll_item).permit(:name, :job_role, :amount, :notes)

    raw[:amount] = begin
      BigDecimal(raw[:amount].to_s)
    rescue ArgumentError, TypeError
      0
    end

    raw[:notes] = ActionController::Base.helpers.sanitize(raw[:notes])

    raw.slice(:name, :job_role, :amount, :notes)
  end
end
