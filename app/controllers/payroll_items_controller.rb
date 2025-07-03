class PayrollItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payroll
  before_action :set_payroll_item, only: [ :edit, :update, :destroy ]

  def create
    @payroll_item = @payroll.payroll_items.new(payroll_item_params)

    if @payroll_item.save
      @payroll.recalculate_total!
      @payroll_item = PayrollItem.new(payroll: @payroll)

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
  end

  private

  def set_payroll
    @payroll = Payroll.find_by!(
      id: params[:payroll_id],
      circus_id: current_user.circus_ids
    )
  end

  def set_payroll_item
    @payroll_item = @payroll.payroll_items.find(params[:id])
  end

  def payroll_item_params
    params.require(:payroll_item).permit(:name, :role, :amount, :notes)
  end
end
