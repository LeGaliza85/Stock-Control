// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Global Spinner functionality for Turbo forms
document.addEventListener("turbo:submit-start", (event) => {
  const submitter = event.detail.formSubmission.submitter
  if (!submitter) return

  // Preserve original content and width
  submitter.dataset.originalHtml = submitter.innerHTML || submitter.value || "..."
  const width = submitter.offsetWidth
  if (width > 0) submitter.style.width = width + "px"

  const isInput = submitter.tagName === "INPUT"
  const spinner = `<svg class="animate-spin h-5 w-5 mx-auto text-current" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>`
  
  if (isInput) {
    submitter.value = "..."
  } else {
    // If the button has a specific width, we replace content, otherwise append
    submitter.innerHTML = spinner
  }
})

document.addEventListener("turbo:submit-end", (event) => {
  const submitters = event.target.querySelectorAll("button[type='submit'], input[type='submit']")
  submitters.forEach(btn => {
    if (btn.dataset.originalHtml) {
      if (btn.tagName === "INPUT") {
        btn.value = btn.dataset.originalHtml
      } else {
        btn.innerHTML = btn.dataset.originalHtml
      }
      delete btn.dataset.originalHtml
      btn.style.width = ""
    }
  })
})
