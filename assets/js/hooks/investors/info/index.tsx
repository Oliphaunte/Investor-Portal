import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import InvestorInfoForm from './form'

export default {
  mounted() {
    this._root = createRoot(this.el as HTMLElement)

    this.render()
  },

  updated() {
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
        <InvestorInfoForm
          csrfToken={csrfToken}
          investorId={investorId}
          onCreated={(id: string) => this.pushEvent('investor_created', { id })}
          onOpenUpload={(id: string) => this.pushEvent('upload', { id })}
        />
      </StrictMode>
    )
  },
}
