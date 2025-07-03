// app/javascript/controllers/application.js

import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Opcional: quita esto en producción si no quieres ver mensajes en consola
application.debug = false
window.Stimulus = application

//
// ——————  AQUÍ EMPIEZA LO NUEVO  ——————
//

/**
 * Importa *todas* las exportaciones por defecto que tengas en
 * app/javascript/pages/index.js (o usa require.context
 * si prefieres detección automática) y registra cada uno
 * bajo su nombre de fichero.
 */


//
// ————— FIN DE LO NUEVO —————
//

export { application }
