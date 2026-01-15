# app/controllers/payrolls_controller.rb
class PayrollsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_circus, only: [ :new, :create ]
  before_action :set_payroll, only: [ :show, :confirm_expense, :register_expense, :mark_as_paid ]

  # 🚧 Gate de suscripción (requiere el servicio "core")
  before_action -> { require_subscription!("core") }, only: [ :show, :new, :create, :confirm_expense, :register_expense, :mark_as_paid ]

  layout "dashboard"

  # GET /payrolls/:id
  def show
    @payroll_items = @payroll.payroll_items.order(:created_at)
    @payroll_item  = @payroll.payroll_items.new

    respond_to do |format|
      format.html
      format.pdf do
        pdf = PayrollPdf.new(@payroll)
        send_data pdf.render,
                  filename:    "planilla_#{@payroll.id}.pdf",
                  type:        "application/pdf",
                  disposition: "inline"
      end
    end
  end

  # POST /circuses/:circus_id/payrolls
  def create
    if @circus.payrolls.exists?
      redirect_to payroll_path(@circus.payrolls.first),
                  alert: t("flash.payrolls.create.already_exists")
    else
      @payroll = @circus.payrolls.create!(title: "Planilla", date: Date.today)
      redirect_to payroll_path(@payroll),
                  notice: t("flash.payrolls.create.success")
    end
  end

  # GET /payrolls/new
  def new
    @payroll = Payroll.new(circus: @circus, date: Date.today)
  end

  # GET /payrolls/:id/confirm_expense
  def confirm_expense
    @localities = Locality.where(circus_id: @payroll.circus_id, active: true)

    render turbo_stream: turbo_stream.update(
      "modal_frame",
      partial:  "payrolls/confirm_expense",
      locals:   { payroll: @payroll, localities: @localities }
    )
  end

  # POST /payrolls/:id/register_expense
  def register_expense
    @payroll     = Payroll.find(params[:id])
    expense_date = params[:date].presence || Date.today
    locality     = Locality.where(circus_id: @payroll.circus_id, active: true)
                           .find(params[:locality_id])

    begin
      tx = Transaction.create!(
        title:            @payroll.title,
        amount:           @payroll.total_amount,
        transaction_type: "expense",
        category:         "payroll",
        date:             expense_date,
        circus:           @payroll.circus,
        user:             current_user,
        locality:         locality,
        payroll:          @payroll
      )
      tx.receipt.attach(
        io:           StringIO.new(PayrollPdf.new(@payroll).render),
        filename:     "nomina_#{@payroll.circus.name}_#{expense_date}.pdf",
        content_type: "application/pdf"
      )
      flash[:notice] = t("flash.payrolls.register_expense.success")
    rescue => e
      flash[:alert] = t("flash.payrolls.register_expense.failure", error: e.message)
    end

    respond_to do |format|
      format.turbo_stream { head :see_other, location: admin_circus_path(@payroll.circus) }
      format.html          { redirect_to admin_circus_path(@payroll.circus) }
    end
  end

  # POST /payrolls/:id/mark_as_paid
  def mark_as_paid
    @payroll.update!(paid: true)
    redirect_to payroll_path(@payroll),
                notice: t("flash.payrolls.mark_as_paid.success")
  end

  private

  def set_circus
    @circus = current_user.circuses.find(params[:circus_id] || params.dig(:payroll, :circus_id))
  end

  def set_payroll
    @payroll = Payroll.find_by!(
      id:        params[:id],
      circus_id: current_user.circus_ids
    )
    @circus ||= @payroll.circus
  end

  def payroll_params
    params.require(:payroll).permit(:title, :date, :circus_id)
  end

  # ============== SUSCRIPTION GUARD ==============

  def require_subscription!(required_service = nil)
    circus = @circus || @payroll&.circus || current_user.circuses.find_by(id: params[:circus_id])

    unless circus
      return redirect_to(dashboard_index_path, alert: t("flash.payrolls.subscription.select_circus"))
    end

    sub = current_active_subscription_for(circus)

    unless sub
      return redirect_to(
        new_circus_subscription_path(circus),
        alert: t("flash.payrolls.subscription.required")
      )
    end

    if required_service.present? && !subscription_allows_service?(sub, required_service)
      redirect_to(
        new_circus_subscription_path(circus),
        alert: t("flash.payrolls.subscription.missing_service", service: required_service)
      )
    end
  end

  def current_active_subscription_for(circus)
    sub = circus.subscriptions.where(active: true)
                              .order(current_period_end: :desc)
                              .first
    return nil unless sub
    return nil unless %w[active trialing].include?(sub.status.to_s)
    return nil if sub.current_period_end.present? && sub.current_period_end < Time.current

    sub
  end

  def subscription_allows_service?(subscription, service_key)
    subscription.subscription_items.where(active: true, service_key: service_key).exists?
  end
end
