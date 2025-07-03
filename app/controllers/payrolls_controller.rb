class PayrollsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_circus, only: [ :new, :create ]
  before_action :set_payroll, only: [ :show, :mark_as_paid, :register_expense ]
  layout "dashboard"

  # ✅ Muestra la vista para agregar ítems a la planilla existente

  def show
    @payroll_items = @payroll.payroll_items.order(:created_at)
    @payroll_item  = @payroll.payroll_items.new

    respond_to do |format|
      format.html  # render show.html.erb
      format.pdf do
        pdf = PayrollPdf.new(@payroll)
        send_data pdf.render,
                  filename:    "planilla_#{@payroll.id}.pdf",
                  type:        "application/pdf",
                  disposition: "inline"
      end
    end
  end
  # ✅ Crea una planilla para el circo actual (solo si no existe ya una)
  def create
    existing = @circus.payrolls.first

    if existing
      redirect_to payroll_path(existing), alert: "Ya existe una planilla para este circo"
    else
      @payroll = @circus.payrolls.create!(title: "Planilla", date: Date.today)
      redirect_to payroll_path(@payroll), notice: "Planilla creada. Ahora puedes agregar ítems."
    end
  end

  # 🧾 Vista para eventualmente soportar más lógica previa al crear (opcional en este flujo)
  def new
    @payroll = Payroll.new(
      circus_id: @circus.id,
      date: Date.today
    )
  end

  # 💸 Registra el gasto asociado a la planilla como transacción (cuando se marca como realizada)
  def register_expense
    transaction = Transaction.create!(
      title:            @payroll.title,
      amount:           @payroll.total_amount,
      transaction_type: "expense",
      category:         "payroll",
      date:             Date.today,
      circus:           @payroll.circus,
      user:             current_user,
      locality:         current_user.current_locality
    )
    redirect_to transaction_path(transaction),
      notice: t("payrolls.notice.registered_as_expense", default: "✅ Gasto registrado exitosamente")
  end


  # ☑️ Marca una planilla como pagada (si estás usando este campo)
  def mark_as_paid
    @payroll.update(paid: true)
    redirect_to payroll_path(@payroll), notice: t("payrolls.status.marked_paid", default: "Planilla marcada como pagada")
  end

  private

  # 🔐 Asegura que el circo pertenezca al usuario actual
  def set_circus
    @circus = current_user.circuses.find(
      params[:circus_id] || params.dig(:payroll, :circus_id)
    )
  end

  # 🔐 Carga solo planillas del usuario actual (evita acceso cruzado por ID)
  def set_payroll
    @payroll = Payroll.find_by!(
      id: params[:id],
      circus_id: current_user.circus_ids
    )
  end
  # 📦 Permite los parámetros esperados si se usa `form_with`
  def payroll_params
    params.require(:payroll).permit(:title, :date, :circus_id)
  end
end
