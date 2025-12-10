// app/javascript/controllers/dashboard_tabs_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dashboard-tabs"
export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.show("inbox")
  }

  show(target) {
    // Panels: show only the active one
    this.panelTargets.forEach(panel => {
      const isActive = panel.dataset.dashboardTabPanel === target
      panel.classList.toggle("hidden", !isActive)
    })

    // Tabs: animate active vs inactive state
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.dashboardTabTarget === target

      // base animation classes (ensure these exist in the markup too)
      tab.classList.add("transition-all", "duration-200", "ease-out", "transform")

      if (isActive) {
        tab.classList.add(
          "bg-slate-900/70",
          "border",
          "border-slate-800",
          "text-slate-100",
          "scale-100",
          "shadow-md",
          "shadow-red-500/20"
        )
        tab.classList.remove(
          "text-slate-400",
          "hover:text-slate-100",
          "hover:bg-slate-900/60",
          "scale-95"
        )
      } else {
        tab.classList.remove(
          "bg-slate-900/70",
          "border",
          "border-slate-800",
          "text-slate-100",
          "scale-100",
          "shadow-md",
          "shadow-red-500/20"
        )
        tab.classList.add(
          "text-slate-400",
          "hover:text-slate-100",
          "hover:bg-slate-900/60",
          "scale-95"
        )
      }
    })
  }

  select(event) {
    event.preventDefault()
    const target = event.currentTarget.dataset.dashboardTabTarget
    if (target) this.show(target)
  }
}
