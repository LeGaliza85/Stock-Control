import { Controller } from "@hotwired/stimulus"

const CORRECTIONS = {
  // Acentos comunes
  "tambien": "también", "ademas": "además", "asi": "así", "aqui": "aquí", "ahi": "ahí",
  "alla": "allá", "aca": "acá", "dia": "día", "paises": "países", "musica": "música",
  "numero": "número", "telefono": "teléfono", "sabado": "sábado", "miercoles": "miércoles",
  "habitacion": "habitación", "comunicacion": "comunicación", "atencion": "atención",
  "razon": "razón", "informacion": "información", "edicion": "edición",
  "condicion": "condición", "produccion": "producción", "educacion": "educación",
  "situacion": "situación", "funcion": "función", "opinion": "opinión",
  "descripcion": "descripción", "publicacion": "publicación", "restauracion": "restauración",
  "marmol": "mármol", "clasico": "clásico", "clasica": "clásica", "unico": "único",
  "unica": "única", "pequeno": "pequeño", "pequena": "pequeña", "tamano": "tamaño",
  "exposicion": "exposición", "senal": "señal", "diseno": "diseño", "regimen": "régimen",
  "caracteristicas": "características", "diametro": "diámetro", "accion": "acción",
  "cancion": "canción", "lección": "lección", "pasión": "pasión", "corazón": "corazón",
  "lógicamente": "lógicamente", "prácticamente": "prácticamente", "automáticamente": "automáticamente",
  "sincronización": "sincronización", "organización": "organización", "clasificación": "clasificación",
  "reparación": "reparación", "pintura": "pintura", "escultura": "escultura",
  "grabado": "grabado", "marco": "marco", "base": "base", "pie": "pie",
  "cajón": "cajón", "tirador": "tirador", "bisagra": "bisagra", "cerradura": "cerradura",
  "manija": "manija", "repujado": "repujado", "tallado": "tallado", "dorado": "dorado",
  "plateado": "plateado", "pátina": "pátina", "esmalte": "esmalte",
  "tamaño": "tamaño", "peso": "peso", "altura": "altura", "ancho": "ancho",
  "largo": "largo", "profundidad": "profundidad", "grosor": "grosor",
  "aproximadamente": "aproximadamente", "aproximado": "aproximado",

  // Errores ortográficos comunes
  "haber": "a ver", "aver": "a ver", "ahber": "a ver",
  "haiga": "haya", "huviera": "hubiera", "huviese": "hubiese",
  "nadien": "nadie", "muncho": "mucho", "munco": "mucho",
  "cocreta": "croqueta", "setiembre": "septiembre",
  "prostumo": "perfume", "almóndiga": "albóndiga",
  "murciégalo": "murciélago", "expreso": "exprés",
  "conducir": "conducir", "conclusion": "conclusión",

  // Confusiones comunes
  "hechar": "echar", "echo": "hecho", "asta": "hasta",
  "hacia": "hacia", "halla": "haya", "hay": "hay",
  "bien": "bien", "bueno": "bueno",

  // Mayúsculas después de punto
  ". a": ". A", ". b": ". B", ". c": ". C", ". d": ". D",
  ". e": ". E", ". f": ". F", ". g": ". G", ". h": ". H",
  ". i": ". I", ". j": ". J", ". l": ". L", ". m": ". M",
  ". n": ". N", ". o": ". O", ". p": ". P", ". q": ". Q",
  ". r": ". R", ". s": ". S", ". t": ". T", ". u": ". U",
  ". v": ". V", ". y": ". Y",

  // Tildes en interrogativos/exclamativos
  "que ": "¿qué ", "como ": "¿cómo ", "donde ": "¿dónde ",
  "cuando ": "¿cuándo ", "quien ": "¿quién ", "cual": "¿cuál",
  "cuanto ": "¿cuánto "
}

export default class extends Controller {
  correct() {
    const textarea = this.element
    const text = textarea.value
    let corrected = text

    // Corregir palabras del diccionario
    Object.keys(CORRECTIONS).forEach(wrong => {
      const right = CORRECTIONS[wrong]
      const regex = new RegExp("\\b" + wrong + "\\b", "gi")
      corrected = corrected.replace(regex, (match) => {
        if (match[0] === match[0].toUpperCase()) {
          return right[0].toUpperCase() + right.slice(1)
        }
        return right
      })
    })

    // Corregir doble espacio
    corrected = corrected.replace(/  +/g, " ")

    // Corregir espacios antes de punto/coma
    corrected = corrected.replace(/ +\./g, ".")
    corrected = corrected.replace(/ +,/g, ",")

    // Corregir espacios después de abrir paréntesis
    corrected = corrected.replace(/\( +/g, "(")

    // Corregir espacios antes de cerrar paréntesis
    corrected = corrected.replace(/ +\)/g, ")")

    // Corregir doble punto
    corrected = corrected.replace(/\.\./g, ".")

    // Punto final si no tiene
    if (corrected.length > 10 && !corrected.match(/[.!?"\)]$/)) {
      corrected = corrected.trim() + "."
    }

    // Primera letra mayúscula
    if (corrected.length > 0) {
      corrected = corrected[0].toUpperCase() + corrected.slice(1)
    }

    if (corrected !== text) {
      const pos = textarea.selectionStart
      textarea.value = corrected
      textarea.setSelectionRange(pos, pos)
    }
  }
}
