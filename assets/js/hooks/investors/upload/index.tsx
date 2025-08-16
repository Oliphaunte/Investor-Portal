import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import UploadsForm from './form'

export default {
  mounted() {
    const rootEl = document.getElementById(this.el.id)
    this._root = createRoot(rootEl!)

    this.render()
  },

  destroyed() {
    if (!this._root) return
    this._root.unmount()
  },

  render() {
    const el = this.el as HTMLElement
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute('content') || ''
    const investorId = el.dataset.investorId || ''

    this._root.render(
      <StrictMode>
        <UploadsForm investorId={investorId} csrfToken={csrfToken} />
      </StrictMode>
    )
  },
}
