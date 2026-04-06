import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  switch(e) {
    const btn = e.currentTarget
    const userId = btn.dataset.userId
    const userName = btn.dataset.userName
    const isVisitante = btn.dataset.visitante === "true"
    
    let password = ""
    if (!isVisitante) {
      password = prompt("Ingresa la contraseña de " + userName + ":")
      if (password === null || password === "") return
    }
    
    const originalText = btn.textContent
    btn.disabled = true
    btn.textContent = "Cambiando..."
    
    const token = document.querySelector('meta[name="csrf-token"]').content
    
    fetch('/usuarios/switch.json', {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": token,
        "Accept": "application/json"
      },
      body: new URLSearchParams({ id: userId, password: password }).toString()
    })
    .then(resp => {
      if (!resp.ok) throw new Error("HTTP " + resp.status)
      return resp.json()
    })
    .then(data => {
      if (data && data.success) {
        window.location.reload()
      } else {
        btn.disabled = false
        btn.textContent = originalText
        alert(data.error || "Error cambiando usuario")
      }
    })
    .catch(err => {
      btn.disabled = false
      btn.textContent = originalText
      console.error("Switch error:", err)
      alert("Error de red: " + err.message)
    })
  }
}
