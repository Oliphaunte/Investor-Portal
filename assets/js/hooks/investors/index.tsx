import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

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
    this._root.render(
      <StrictMode>
        <p>hello world</p>
      </StrictMode>
    )
  },
}
