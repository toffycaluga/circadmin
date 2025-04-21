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
end
