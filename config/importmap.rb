# config/importmap.rb
# -------------------

# Módulo raíz de tu app
pin "application", to: "application.js"

# Hotwire (Turbo + Stimulus)
pin "@hotwired/turbo-rails",      to: "turbo.min.js",          preload: true
pin "@hotwired/stimulus",         to: "stimulus.min.js",       preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js",   preload: true

# Bootstrap 5 ES Modules  (incluye todos los componentes JS)
pin "bootstrap",     to: "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.esm.js", preload: true
pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/esm/index.js", preload: true
pin "perfect-scrollbar", to: "https://cdn.jsdelivr.net/npm/perfect-scrollbar@1.5.5/dist/perfect-scrollbar.esm.js"
pin "scrollreveal", to: "https://cdn.skypack.dev/scrollreveal?dts"
pin "animejs",     to: "https://cdn.skypack.dev/animejs?dts"
# agrega justo debajo de tu pin de Stimulus



# Auto-pin de controladores Stimulus
pin_all_from "app/javascript/controllers", under: "controllers"

# Auto-pin de tus propios módulos (si quieres seguir organizando JS aquí)
pin_all_from "app/javascript/js", under: "js"
