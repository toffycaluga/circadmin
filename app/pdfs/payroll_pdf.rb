# app/pdfs/payroll_pdf.rb
class PayrollPdf < Prawn::Document
  def initialize(payroll)
    super(top_margin: 60, bottom_margin: 50)
    @payroll = payroll
    @circus  = payroll.circus

    build_header
    move_down 20
    table_content
    move_down 10
    build_footer
  end

  def build_header
    icon_path = Rails.root.join("app/assets/images/icono.jpg")
    logo_path = Rails.root.join("app/assets/images/logo.jpg")

    # Celdas: icono, título y logo
    header_cells = []
    header_cells << (File.exist?(icon_path) ? { image: icon_path.to_s, fit: [ 40, 40 ] } : "")

    header_title = I18n.t(
      "pdfs.payroll.header_full",
      app_name: I18n.t("app.name", default: "CircAdmin"),
      title:    I18n.t("pdfs.payroll.header_title")
    )

    header_cells << make_cell(
      content: "<b>#{header_title}</b>",
      inline_format: true,
      valign: :center,
      size: 14,
      align: :center
    )

    header_cells << (File.exist?(logo_path) ? { image: logo_path.to_s, fit: [ 80, 40 ], position: :right } : "")

    table([ header_cells ],
      width: bounds.width,
      column_widths: [ 50, bounds.width - (50 + 90), 90 ],
      cell_style: { borders: [], padding: [ 0, 5, 0, 0 ] }
    )

    move_down 12
    text I18n.t("pdfs.payroll.detail_title"), size: 22, style: :bold, color: "336699"
    stroke_horizontal_rule
    move_down 8

    text "#{I18n.t('pdfs.payroll.labels.circus')}: #{@circus.name}", size: 12
    text "#{I18n.t('pdfs.payroll.labels.payroll_date')}: #{I18n.l(@payroll.created_at, format: :date_only)}", size: 12
  end

  def table_content
    currency = currency_symbol(@circus.currency)

    headers = [
      I18n.t("pdfs.payroll.table.name"),
      I18n.t("pdfs.payroll.table.job_role"),
      I18n.t("pdfs.payroll.table.amount"),
      I18n.t("pdfs.payroll.table.notes")
    ]

    data = [ headers ]

    @payroll.payroll_items.order(:created_at).each do |item|
      data << [
        item.name,
        item.job_role,
        "#{currency}#{format('%.2f', item.amount)}",
        item.notes.to_s.truncate(40)
      ]
    end

    data << [
      { content: I18n.t("pdfs.payroll.table.total"), colspan: 2, align: :right, font_style: :bold },
      { content: "#{currency}#{format('%.2f', @payroll.total)}", font_style: :bold },
      ""
    ]

    table(
      data,
      header: true,
      width: bounds.width,
      row_colors: [ "F0F8FF", "FFFFFF" ],
      cell_style: { padding: [ 6, 8, 6, 8 ], borders: [ :bottom ] }
    ) do
      row(0).background_color = "336699"
      row(0).text_color       = "FFFFFF"
      row(0).font_style       = :bold
    end
  end

  def build_footer
    # 1) Número de página
    number_pages I18n.t("pdfs.payroll.footer.page_x_of_y"),
                 at: [ bounds.right - 100, 0 ],
                 size: 9,
                 align: :right

    # 2) Regla y texto
    bounding_box([ bounds.left, bounds.bottom + 15 ], width: bounds.width) do
      stroke_horizontal_rule
      move_down 4
      text I18n.t("pdfs.payroll.footer.generated_by", app_name: I18n.t("app.name", default: "CircAdmin")),
           size: 9, align: :center, color: "999999"
    end
  end

  private

  def currency_symbol(code)
    {
      "USD" => "$", "EUR" => "€", "CLP" => "$", "MXN" => "$",
      "ARS" => "$", "BRL" => "R$", "GBP" => "£"
    }[code] || code
  end
end
