# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
# Pines para tus scripts personalizados
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/controllers/plugins", under: "plugins"
pin_all_from "app/javascript/controllers/pages", under: "pages"
pin_all_from "app/javascript", under: "javascript"
