class PayrollItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payroll
  before_action :set_payroll_item, only: [ :edit, :update, :destroy ]

  def create
    @payroll_item = @payroll.payroll_items.new(payroll_item_params)

    if @payroll_item.save
      @payroll.recalculate_total!
      @payroll_item = PayrollItem.new(payroll: @payroll)
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
        # Si tienes un contenedor de flash en la vista:
        # turbo_stream.update("flash", partial: "shared/flash")
      ]
    else
      flash.now[:alert] = t("flash.payroll_items.create.failure")
      render turbo_stream: turbo_stream.replace(
        "payroll-items",
        partial: "payrolls/rows",
        locals: { payroll: @payroll, payroll_item: @payroll_item }
      )
    end
  end

  def edit
    render turbo_stream: turbo_stream.update(
      "payroll_item_modal",
      partial: "payroll_items/modal",
      locals: { payroll: @payroll, payroll_item: @payroll_item }
    )
  end

  def update
    if @payroll_item.update(payroll_item_params)
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
        # turbo_stream.update("flash", partial: "shared/flash")
      ]
    else
      flash.now[:alert] = t("flash.payroll_items.update.failure")
      render turbo_stream: turbo_stream.update(
        "payroll_item_modal",
        partial: "payroll_items/modal",
        locals: { payroll: @payroll, payroll_item: @payroll_item }
      )
    end
  end

  def destroy
    @payroll_item.destroy
    @payroll.recalculate_total!
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
      # turbo_stream.update("flash", partial: "shared/flash")
    ]
  end

  private

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

  def payroll_item_params
    params.require(:payroll_item).permit(:name, :role, :amount, :notes)
  end
end
