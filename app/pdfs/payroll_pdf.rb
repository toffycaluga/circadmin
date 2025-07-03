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

        # Construimos las celdas: icono, título y logo
        header_cells = []
        header_cells << (
        File.exist?(icon_path) ?
            { image: icon_path.to_s, fit: [ 40, 40 ] } :
            ""
        )
        header_cells << make_cell(
        content: "<b>CircAdmin — Nómina</b>",
        inline_format: true,
        valign: :center,
        size: 14,
        align: :center
        )
        header_cells << (
        File.exist?(logo_path) ?
            { image: logo_path.to_s, fit: [ 80, 40 ], position: :right } :
            ""
        )

        # Table con ancho completo y columnas fijas para icono y logo
        table([ header_cells ],
        width: bounds.width,
        column_widths: [
            50,               # icono
            bounds.width - (50 + 90),  # título (resto)
            90                # logo
        ],
        cell_style: { borders: [], padding: [ 0, 5, 0, 0 ] }
        )

        move_down 12
        text "Detalle de Nómina", size: 22, style: :bold, color: "336699"
        stroke_horizontal_rule
        move_down 8

        text "Circo: #{@circus.name}", size: 12
        text "Fecha de nómina: #{Time.current.strftime('%d/%m/%Y')}", size: 12
    end


  def table_content
    currency = currency_symbol(@circus.currency)

    data = [ [ "Nombre", "Cargo", "Monto", "Notas" ] ]
    @payroll.payroll_items.order(:created_at).each do |item|
      data << [
        item.name,
        item.role,
        "#{currency}#{'%.2f' % item.amount}",
        item.notes.to_s.truncate(40)
      ]
    end
    data << [
      { content: "Total", colspan: 2, align: :right, font_style: :bold },
      { content: "#{currency}#{'%.2f' % @payroll.total}", font_style: :bold },
      ""
    ]

    table(data,
          header: true,
          width: bounds.width,
          row_colors: [ "F0F8FF", "FFFFFF" ],
          cell_style: { padding: [ 6, 8, 6, 8 ], borders: [ :bottom ] }) do
      row(0).background_color = "336699"
      row(0).text_color       = "FFFFFF"
      row(0).font_style       = :bold
    end
  end

  def build_footer
    # 1) Número de página en la línea más baja
    number_pages "Página <page> de <total>",
                 at: [ bounds.right - 100, 0 ],
                 size: 9,
                 align: :right

    # 2) Rule y texto un poco arriba para no solaparse
    bounding_box([ bounds.left, bounds.bottom + 15 ], width: bounds.width) do
      stroke_horizontal_rule
      move_down 4
      text "Documento generado por CircAdmin", size: 9, align: :center, color: "999999"
    end
  end

  private

  def currency_symbol(code)
    {
      "USD" => "$",
      "EUR" => "€",
      "CLP" => "$",
      "MXN" => "$",
      "ARS" => "$",
      "BRL" => "R$",
      "GBP" => "£"
    }[code] || code
  end
end
