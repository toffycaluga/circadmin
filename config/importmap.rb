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
pin "scrollreveal", to: "https://cdn.jsdelivr.net/npm/scrollreveal@4.0.9/dist/scrollreveal.es.js"
pin "animejs",    to: "https://cdn.jsdelivr.net/npm/animejs@3.2.1/lib/anime.es.js"
# config/importmap.rb
pin "@stripe/stripe-js", to: "https://ga.jspm.io/npm:@stripe/stripe-js@1.48.0/dist/stripe.esm.js"


# Si usas tealight en animation_controller:
pin "tealight", to: "https://cdn.jsdelivr.net/npm/tealight@0.3.6/dist/tealight.esm.js"
# agrega justo debajo de tu pin de Stimulus



# Auto-pin de controladores Stimulus
pin_all_from "app/javascript/controllers", under: "controllers"

# Auto-pin de tus propios módulos (si quieres seguir organizando JS aquí)
pin_all_from "app/javascript/js", under: "js"
