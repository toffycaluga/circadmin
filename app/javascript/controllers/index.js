// app/javascript/controllers/index.js
import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// esto carga TODO *.js bajo app/javascript/controllers
eagerLoadControllersFrom("controllers", application)
