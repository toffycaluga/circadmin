# config/importmap.rb

pin "application", to: "application.js"

# Hotwire
pin "@hotwired/turbo-rails",      to: "turbo.min.js",        preload: true
pin "@hotwired/stimulus",         to: "stimulus.min.js",     preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Bootstrap + Popper (esto está ok en jsDelivr)
pin "bootstrap",       to: "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.esm.js", preload: true
pin "@popperjs/core",  to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/esm/index.js",  preload: true

# ScrollReveal con bundle (resuelve rematrix/tealight interno con CORS/MIME correctos)
pin "scrollreveal", to: "https://esm.sh/scrollreveal@4.0.9?bundle"


# Stimulus controllers / módulos de tu app
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/js",          under: "js"
