// Streams the Velora data generator feed into the terminal window.
//
// All events come from the server (/velora/feed), computed there from the
// clock, so every browser shows the identical stream. This controller only
// renders: it backfills the events embedded in the page, then polls for new
// slots and appends them at the generator's natural pace.
import { Controller } from "@hotwired/stimulus"

const KIND_STYLES = {
  visitor: "text-sky-400",
  crawler: "text-pink-400",
  order:   "text-emerald-400",
  stock:   "text-amber-300",
  pricing: "text-purple-300",
  content: "text-fuchsia-300",
  pixel:   "text-teal-300",
  model:   "text-indigo-300"
}

const MAX_LINES = 250

export default class extends Controller {
  static targets = ["log", "cursor"]
  static values = { url: String, last: Number, initial: Array }

  connect() {
    this.initialValue.forEach(event => this.append(event))
    this.scrollToBottom()
    this.timer = setInterval(() => this.poll(), 5000)
    this.onVisible = () => { if (!document.hidden) this.poll() }
    document.addEventListener("visibilitychange", this.onVisible)
  }

  disconnect() {
    clearInterval(this.timer)
    document.removeEventListener("visibilitychange", this.onVisible)
  }

  async poll() {
    if (document.hidden) return
    try {
      const response = await fetch(`${this.urlValue}?after=${this.lastValue}`, { headers: { Accept: "application/json" } })
      if (!response.ok) return
      const data = await response.json()
      const stick = this.nearBottom()
      data.events.forEach(event => this.append(event))
      if (data.last_slot > this.lastValue) this.lastValue = data.last_slot
      if (stick && data.events.length) this.scrollToBottom()
    } catch {
      // Network hiccup: the next poll catches up via the `after` cursor.
    }
  }

  append(event) {
    const row = document.createElement("div")
    row.className = "flex gap-x-3"
    row.innerHTML = `
      <span class="shrink-0 text-gray-500">${event.time}</span>
      <span class="w-16 shrink-0 ${KIND_STYLES[event.kind] || "text-gray-400"}">${event.kind}</span>
      <span class="min-w-0 text-gray-300">${this.escape(event.line)}</span>`
    this.logTarget.insertBefore(row, this.cursorTarget)
    if (event.slot > this.lastValue) this.lastValue = event.slot
    while (this.logTarget.children.length > MAX_LINES) this.logTarget.firstElementChild.remove()
  }

  escape(text) {
    const span = document.createElement("span")
    span.textContent = text
    return span.innerHTML
  }

  nearBottom() {
    const el = this.logTarget
    return el.scrollHeight - el.scrollTop - el.clientHeight < 60
  }

  scrollToBottom() {
    this.logTarget.scrollTop = this.logTarget.scrollHeight
  }
}
