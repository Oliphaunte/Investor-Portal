import React, { useEffect, useMemo, useRef, useState } from 'react'

type Props = {
  investorId: string
  csrfToken: string
}

export default function UploadsForm({ investorId, csrfToken }: Props) {
  const [files, setFiles] = useState<File[]>([])
  const [progress, setProgress] = useState<number>(0)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState(null)
  const progressTimer = useRef<number | null>(null)

  const uploadUrl = useMemo(() => `${'/api/investor_data'}/${encodeURIComponent(investorId)}/uploads`, [investorId])

  const onPick = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    setFiles(file ? [file] : [])
  }

  const onDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault()
    if (e.dataTransfer?.files?.length) {
      const file = e.dataTransfer.files[0]
      setFiles(file ? [file] : [])
    }
  }

  const preventDefault = (e: React.DragEvent) => e.preventDefault()

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!investorId) {
      setError('Missing investor id')
      return
    }

    setSubmitting(true)
    setError(null)
    setResult(null)
    setProgress(0)

    // Start a simulated progress ramp while waiting for server response
    if (progressTimer.current) {
      window.clearInterval(progressTimer.current)
      progressTimer.current = null
    }
    progressTimer.current = window.setInterval(() => {
      setProgress(prev => {
        // Fast at first, then slower, cap at 95 until completion
        const inc = prev < 70 ? 5 : prev < 90 ? 2 : 0.5
        return Math.min(prev + inc, 95)
      })
    }, 120)

    const fd = new FormData()
    if (files[0]) fd.append('file', files[0])

    try {
      const res = await fetch(uploadUrl, {
        method: 'POST',
        headers: { 'x-csrf-token': csrfToken },
        body: fd,
      })

      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Upload failed')
      setResult({ files: data.files || [], errors: data.errors || [] })
    } catch (err: any) {
      setError(err.message || 'Network error')
    } finally {
      if (progressTimer.current) {
        window.clearInterval(progressTimer.current)
        progressTimer.current = null
      }
      setSubmitting(false)
      setProgress(100)
      setTimeout(() => setProgress(0), 1200)
    }
  }

  useEffect(() => {
    return () => {
      if (progressTimer.current) {
        window.clearInterval(progressTimer.current)
        progressTimer.current = null
      }
    }
  }, [])

  return (
    <form onSubmit={submit} className="space-y-4">
      <div
        className="border border-dashed rounded-lg p-6 text-center"
        onDrop={onDrop}
        onDragOver={preventDefault}
        onDragEnter={preventDefault}
        onDragLeave={preventDefault}>
        <p className="mb-3">Drag and drop a file here, or click to select</p>
        <input type="file" onChange={onPick} className="file-input w-full max-w-xs" />
        {files.length > 0 && (
          <ul className="mt-3 text-sm text-base-content/70 list-disc list-inside">
            {files.map(f => (
              <li key={f.name + f.size}>
                {f.name} ({Math.round(f.size / 1024)} KB)
              </li>
            ))}
          </ul>
        )}
      </div>

      {progress > 0 && progress < 100 && (
        <progress className="progress progress-primary w-full" value={progress} max={100} />
      )}

      {error && <div className="alert alert-error">{error}</div>}

      {result && (
        <div className="space-y-2">
          {result.files.length > 0 && (
            <div className="alert alert-success">
              Uploaded {result.files.length} file{result.files.length > 1 ? 's' : ''}
            </div>
          )}
          {result.errors.length > 0 && (
            <div className="alert alert-warning">
              {result.errors.length} file{result.errors.length > 1 ? 's' : ''} failed to upload
            </div>
          )}
          {result.files.length > 0 && (
            <ul className="list-disc list-inside text-sm">
              {result.files.map(f => (
                <li key={f.url}>
                  <a className="link" href={f.url} target="_blank" rel="noreferrer">
                    {f.filename}
                  </a>{' '}
                  <span className="opacity-60">({Math.round(f.size / 1024)} KB)</span>
                </li>
              ))}
            </ul>
          )}
        </div>
      )}

      <div className="flex gap-2">
        <button className="btn btn-primary" type="submit" disabled={submitting || files.length === 0}>
          {submitting ? 'Uploading...' : 'Upload'}
        </button>
        <button className="btn" type="button" onClick={() => setFiles([])} disabled={submitting}>
          Clear
        </button>
      </div>
    </form>
  )
}
