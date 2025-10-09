# app/pdfs/transactions_pdf.rb
class TransactionsPdf < Prawn::Document
  def initialize(transactions, locality, type)
    super(top_margin: 60, bottom_margin: 50)
    @transactions = transactions
    @locality     = locality
    @circus       = locality.circus
    @type         = type

    build_header
    move_down 20
    table_content
    build_footer
  end

  def build_header
    icon_path = Rails.root.join("app/assets/images/icono.jpg")
    logo_path = Rails.root.join("app/assets/images/logo.jpg")

    elements = []
    elements << (File.exist?(icon_path) ? { image: icon_path.to_s, fit: [ 40, 40 ] } : "")

    center_text = I18n.t("pdfs.common.branding",
                         default: I18n.t("app.name", default: "CircAdmin"))
    elements << make_cell(content: "<b>#{center_text}</b>", inline_format: true, valign: :center, size: 12)

    elements << (File.exist?(logo_path) ? { image: logo_path.to_s, fit: [ 80, 40 ] } : "")

    table([ elements ], cell_style: { borders: [], padding: [ 0, 10, 0, 0 ] })

    move_down 12

    text I18n.t("transactions.export.title_pdf", default: "Resumen de Transacciones"),
         size: 22, style: :bold, align: :left, color: "336699"

    move_down 8
    stroke_color "CCCCCC"
    stroke_horizontal_rule
    move_down 10

    text "#{I18n.t('localities.name', default: 'Localidad')}: #{@locality.title}", size: 12
    text "#{I18n.t('circus.title',    default: 'Circo')}: #{@circus.name}", size: 12
    text "#{I18n.t("transactions.type.#{@type}", default: @type.to_s.titleize)}", size: 12

    if @transactions.any?
      min = @transactions.minimum(:date)
      max = @transactions.maximum(:date)
      if min && max
        range = "#{I18n.l(min, format: :short)} - #{I18n.l(max, format: :short)}"
        text "#{I18n.t('transactions.export.range', default: 'Rango')}: #{range}", size: 12
      end
    end
  end

  def table_content
    currency = currency_symbol(@circus.currency)

    headers = [
      I18n.t("transactions.fields.date",        default: "Fecha"),
      I18n.t("transactions.fields.title",       default: "Título"),
      I18n.t("transactions.fields.amount",      default: "Monto"),
      I18n.t("transactions.fields.category",    default: "Categoría"),
      I18n.t("transactions.fields.description", default: "Descripción"),
      I18n.t("transactions.fields.user",        default: "Registrado por")
    ]

    table_data = [ headers ]

    @transactions.each do |tx|
      table_data << [
        (tx.date ? I18n.l(tx.date, format: :short) : ""),
        tx.title,
        "#{currency}#{format('%.2f', tx.amount)}",
        I18n.t("transactions.categories.#{tx.category}", default: tx.category.to_s.titleize),
        tx.description.to_s.truncate(60),
        (tx.user.user_profile&.full_name || tx.user.email)
      ]
    end

    table(
      table_data,
      header: true,
      row_colors: [ "F0F8FF", "FFFFFF" ],
      cell_style: { borders: [ :bottom ], padding: [ 4, 6, 4, 6 ], size: 9 }
    ) do
      row(0).background_color = "336699"
      row(0).text_color       = "FFFFFF"
      row(0).font_style       = :bold
    end
  end

  def build_footer
    number_pages I18n.t("pdfs.common.page_x_of_y", default: "<page> / <total>"),
                 at: [ bounds.right - 50, 0 ], size: 9

    creation_note = "#{I18n.t('transactions.export.generated_by',
                              default: 'Documento generado por %{app_name}',
                              app_name: I18n.t('app.name', default: 'CircAdmin'))} — " \
                    "#{I18n.l(Time.current, format: :default)}"

    go_to_page page_count
    bounding_box([ bounds.left, bounds.bottom + 25 ], width: bounds.width) do
      stroke_horizontal_rule
      move_down 4
      text creation_note, size: 9, align: :center, color: "999999"
    end
  end

  # Helper embebido para evitar dependencias
  def currency_symbol(code)
    {
      "USD" => "$", "EUR" => "€", "CLP" => "$", "MXN" => "$",
      "ARS" => "$", "BRL" => "R$", "GBP" => "£"
    }[code] || code
  end
end
