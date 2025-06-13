module ApplicationHelper
    def load_template_scripts(type = :plugins)
      path = case type
      when :plugins then "assets/js/plugins"
      when :pages   then "assets/js/pages"
      when :base    then "assets/js"
      else "js"
      end

      script_list = case type
      when :plugins
                    [
                        "apexcharts.min.js",
                        "bootstrap-maxlength.js",
                        "bootstrap-notify.min.js",
                        "bootstrap-slider.min.js",
                        "bootstrap-tagsinput.min.js",
                        "bootstrap.min.js",
                        "buttons.bootstrap4.min.js",
                        "buttons.colVis.min.js",
                        "buttons.html5.min.js",
                        "buttons.print.min.js",
                        "Chart.min.js",
                        "ckeditor.js",
                        "clipboard.min.js",
                        "cropper.min.js",
                        "dataTables.bootstrap4.min.js",
                        "dataTables.buttons.min.js",
                        "dataTables.colReorder.min.js",
                        "dataTables.fixedColumns.min.js",
                        "dataTables.fixedHeader.min.js",
                        "dataTables.keyTable.min.js",
                        "dataTables.responsive.min.js",
                        "dataTables.select.min.js",
                        "daterangepicker.js",
                        "dropzone-amd-module.min.js",
                        "ekko-lightbox.min.js",
                        "flipclock.min.js",
                        "fullcalendar.min.js",
                        "gmaps.min.js",
                        "highcharts-3d.js",
                        "highcharts.js",
                        "isotope.pkgd.min.js",
                        "jquery-ui.min.js",
                        "jquery.barrating.min.js",
                        "jquery.bootstrap.wizard.min.js",
                        "jquery.dataTables.min.js",
                        "jquery.knob.min.js",
                        "jquery.mask.min.js",
                        "jquery.minicolors.min.js",
                        "jquery.peity.min.js",
                        "jquery.validate.min.js",
                        "jszip.min.js",
                        "lightbox.min.js",
                        "moment.js",
                        "moment.min.js",
                        "pdfmake.min.js",
                        "perfect-scrollbar.min.js",
                        "PNotify.js",
                        "PNotifyButtons.js",
                        "PNotifyCallbacks.js",
                        "PNotifyConfirm.js",
                        "PNotifyDesktop.js",
                        "prism.js",
                        "select.bootstrap4.min.js",
                        "select2.full.min.js",
                        "sweetalert.min.js",
                        "trumbowyg.min.js"
                    ]

      when :pages
                      [
                        "ac-alert.js",
                        "ac-datepicker.js",
                        "ac-lightbox.js",
                        "ac-notification.js",
                        "ac-rangeslider.js",
                        "ac-rating.js",
                        "chart-apex.js",
                        "chart-chart-custom.js",
                        "chart-highchart-custom.js",
                        "chart-morris-custom.js",
                        "chart-peity-custom.js",
                        "charts.js",
                        "dashboard-analytics.js",
                        "dashboard-crm.js",
                        "dashboard-help.js",
                        "dashboard-main.js",
                        "dashboard-project.js",
                        "dashboard-sale.js",
                        "data-advance-custom.js",
                        "data-api-custom.js",
                        "data-autofill-custom.js",
                        "data-basic-custom.js",
                        "data-buttons-custom.js",
                        "data-column-custom.js",
                        "data-export-custom.js",
                        "data-header-custom.js",
                        "data-key-custom.js",
                        "data-plugin-custom.js",
                        "data-reorder-custom.js",
                        "data-responsive-custom.js",
                        "data-row-custom.js",
                        "data-scroller-custom.js",
                        "data-select-custom.js",
                        "data-source-custom.js",
                        "data-styling-custom.js",
                        "data-table-custom.js",
                        "editable-custom.js",
                        "form-advance-custom.js",
                        "form-masking-custom.js",
                        "form-picker-custom.js",
                        "form-select-custom.js",
                        "form-validation.js",
                        "google-maps.js",
                        "invoice-list.js",
                        "jquery.knob-custom.min.js",
                        "jquery.wavify.js",
                        "map-api.js",
                        "notify-event.js",
                        "page-croper.js",
                        "task-board.js",
                        "todo.js",
                        "TweenMax.min.js",
                        "widget-data.js"
                      ]
      when :base
                      [
                        "waves.min.js",
                        "ripple.js",
                        "analytics.min.js",
                        "horizonal-menu.js",
                        "menu-setting.min.js",
                        "pcoded.min.js",
                        "ripple.js",
                        "uikit.min.js",
                        "vendor-all.min.js"

                      ]
      else
                      []
      end

      script_list.map { |file| javascript_include_tag "/#{path}/#{file}" }.join("\n").html_safe
    end


    def country_options
      ISO3166::Country.all.map do |country|
        localized_name = country.translations[I18n.locale.to_s] || country.translations["en"] || country.common_name
        [ localized_name, country.alpha2 ] # puedes usar alpha2 como valor si luego lo necesitas para lógica
      end.sort_by(&:first)
    end

    def currency_options
      # Monedas únicas extraídas de todos los países
      ISO3166::Country.all.map(&:currency_code).uniq.compact.map do |code|
        [ "#{code}", code ]
      end.sort_by(&:first)
    end
    def country_options_with_flags
      ISO3166::Country.all.map do |country|
        flag = country.emoji_flag rescue ""
        localized_name = country.translations[I18n.locale.to_s] || country.translations["en"] || country.common_name
        [ "#{localized_name} #{flag}", country.alpha2 ]
      end.sort_by(&:first)
    end
    def clean_currency(amount)
      decimals = amount.to_f == amount.to_i ? 0 : 2
      number_with_precision(amount,
        precision: decimals,
        delimiter: ".",  # separador de miles
        separator: ","   # separador decimal
      )
    end


    # def currency_options_with_flags(selected_country_code = nil)
    #   require "money"
    #   countries = ISO3166::Country.all

    #   country_code = SPECIAL_CURRENCY_COUNTRIES[code] || alpha2


    #   currency_map = {}

    #   countries.each do |country|
    #     next unless country.currency_code && country.translations.present?

    #     currency_code = country.currency_code
    #     currency_name = country.currency["name"] rescue currency_code
    #     alpha2 = country.alpha2

    #     unless currency_map[currency_code]
    #       currency_map[currency_code] = {
    #         name: currency_name,
    #         country_code: SPECIAL_CURRENCY_COUNTRIES[currency_code] || alpha2
    #       }
    #     end
    #   end

    #   # Moneda preferida según país seleccionado
    #   preferred_currency_code = nil
    #   if selected_country_code.present?
    #     selected_country = countries.find { |c| c.alpha2 == selected_country_code }
    #     preferred_currency_code = selected_country&.currency_code
    #   end

    #   # Construcción de las opciones del select (¡ahora con data-country-code!)
    #   options = currency_map.map do |code, info|
    #     flag = info[:country_code] == "EU" ? "🇪🇺" : ISO3166::Country[info[:country_code]]&.emoji_flag || ""
    #     label = "#{flag} #{code} - #{info[:name]}"
    #     [ label, code, { 'data-country-code': info[:country_code] } ]
    #   end

    #   # Ordenar con preferida al principio
    #   if preferred_currency_code
    #     options.sort_by! { |(_, code, _)| code == preferred_currency_code ? 0 : 1 }
    #   end

    #   options
    # end
    def country_options_with_flags
      ISO3166::Country.all.map do |country|
        name = country.translations[I18n.locale.to_s] || country.translations["en"] || country.name
        flag = country.emoji_flag rescue ""
        currency_code = country.currency_code

        [
          "#{name} #{flag}",
          country.alpha2,
          { 'data-currency-code': currency_code }
        ]
      end.sort_by(&:first)
    end


    def currency_options_data
      require "money"
      currencies = Money::Currency.table

      currencies.map do |code_sym, data|
        code = code_sym.to_s.upcase
        name = data[:name]

        # Obtener código de país representativo desde el hash o por búsqueda
        country_code =
          SPECIAL_CURRENCY_COUNTRIES[code] ||
          ISO3166::Country.all.find { |c| c.currency_code == code }&.alpha2

        flag = country_code == "EU" ? "🇪🇺" : ISO3166::Country[country_code]&.emoji_flag || ""

        [
          "#{code} - #{name} #{flag}", # label visible
          code,                        # value
          { 'data-country-code': country_code }
        ]
      end.sort_by(&:first)
    end
end
