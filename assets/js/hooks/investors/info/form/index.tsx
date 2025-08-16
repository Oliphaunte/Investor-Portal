import { useEffect, useState } from 'react'
import { useForm, Controller } from 'react-hook-form'
import PhoneInput, { isValidPhoneNumber } from 'react-phone-number-input'
import * as yup from 'yup'
import { US_STATES, STATE_ABBRS } from '../../../../constants/usStates'

type Props = {
  csrfToken: string
  investorId?: string
  onCreated?: (id: string) => void
  onOpenUpload?: (id: string) => void
}

const defaultValues = {
  first_name: '',
  last_name: '',
  phone: '',
  address: '',
  state: '',
  zip: '',
}
const schema = yup.object({
  first_name: yup.string().required('First name is required'),
  last_name: yup.string().required('Last name is required'),
  phone: yup
    .string()
    .required('Phone is required')
    .test('is-valid-phone', 'Invalid phone number', value => !!value && isValidPhoneNumber(value)),
  address: yup.string().required('Address is required'),
  state: yup
    .string()
    .transform(v => (v || '').toUpperCase())
    .oneOf(STATE_ABBRS, 'Select a valid state')
    .required('State is required'),
  zip: yup
    .string()
    .matches(/^\d{5}(-\d{4})?$/, 'Invalid ZIP code format')
    .required('ZIP code is required'),
})

export default ({ csrfToken, onCreated, onOpenUpload, investorId }: Props) => {
  const {
    register,
    handleSubmit,
    reset,
    setError: setFieldError,
    control,
    formState: { errors },
  } = useForm({ defaultValues })
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [uploadsUrl, setUploadsUrl] = useState<string | null>(null)

  useEffect(() => {
    const load = async () => {
      if (!investorId) {
        reset({ first_name: '', last_name: '', phone: '', address: '', state: '', zip: '' })
        setUploadsUrl(null)
        setError(null)
        return
      }

      try {
        setError(null)
        const query = `query($id: ID!){ get_investor_data(id: $id){ id first_name last_name phone address state zip uploads } }`
        const res = await fetch('/api/graphql', {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
            'x-csrf-token': csrfToken,
          },
          body: JSON.stringify({ query, variables: { id: investorId } }),
        })
        const data = await res.json()

        if (!res.ok || data.errors) {
          const msg = data.errors?.map((e: any) => e.message).join(', ') || 'Request failed'
          throw new Error(msg)
        }
        const inv = data.data?.get_investor_data || {}

        reset({
          first_name: inv.first_name || '',
          last_name: inv.last_name || '',
          phone: inv.phone || '',
          address: inv.address || '',
          state: (inv.state || '').toUpperCase(),
          zip: inv.zip || '',
        })
        setUploadsUrl(inv.uploads ?? null)
      } catch (err: any) {
        setError(err.message || 'Failed to load investor')
      }
    }

    load()
  }, [investorId])

  const submit = handleSubmit(async values => {
    setSubmitting(true)
    setError(null)

    try {
      await schema.validate(values, { abortEarly: false })
    } catch (ve: any) {
      if (ve.inner && Array.isArray(ve.inner)) {
        ve.inner.forEach((issue: any) => {
          if (issue.path) {
            setFieldError(issue.path, { type: 'manual', message: issue.message })
          }
        })
      } else if (ve.path) {
        setFieldError(ve.path, { type: 'manual', message: ve.message })
      }
      setSubmitting(false)
      return
    }

    const isEdit = !!investorId
    const query = isEdit
      ? `mutation($id: ID!, $input: InvestorInput!) { update_investor(id: $id, input: $input) { id } }`
      : `mutation($input: InvestorInput!) { create_investor(input: $input) { id } }`
    const variables = isEdit ? { id: investorId, input: values } : { input: values }

    try {
      const res = await fetch('/api/graphql', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-csrf-token': csrfToken,
        },
        body: JSON.stringify({ query, variables }),
      })

      const data = await res.json()
      if (!res.ok || data.errors) {
        const msg = data.errors?.map((e: any) => e.message).join(', ') || 'Request failed'
        throw new Error(msg)
      }

      if (isEdit) {
      } else {
        const id = data.data?.create_investor?.id
        if (id && onCreated) onCreated(id)
      }
    } catch (err: any) {
      setError(err.message || 'Network error')
    } finally {
      setSubmitting(false)
    }
  })

  return (
    <form onSubmit={submit} className="space-y-4">
      {error && <div className="alert alert-error">{error}</div>}

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <label className="label">First name</label>
          <input className="input w-full" {...register('first_name')} maxLength={50} />
          {errors.first_name && <p className="text-error text-sm">{String(errors.first_name.message)}</p>}
        </div>
        <div>
          <label className="label">Last name</label>
          <input className="input w-full" {...register('last_name')} maxLength={50} />
          {errors.last_name && <p className="text-error text-sm">{String(errors.last_name.message)}</p>}
        </div>
      </div>

      <div>
        <label className="label">Phone</label>
        <Controller
          name="phone"
          control={control}
          render={({ field: { value, onChange, onBlur } }) => (
            <PhoneInput
              value={value}
              onChange={onChange}
              onBlur={onBlur}
              defaultCountry="US"
              className="PhoneInput input w-full"
              placeholder="(555) 123-4567"
            />
          )}
        />
        {errors.phone && <p className="text-error text-sm">{String(errors.phone.message)}</p>}
      </div>

      <div>
        <label className="label">Address</label>
        <input className="input w-full" {...register('address')} maxLength={100} />
        {errors.address && <p className="text-error text-sm">{String(errors.address.message)}</p>}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div>
          <label className="label">State</label>
          <select className="select w-full" {...register('state')}>
            <option value="">Select a state</option>
            {US_STATES.map(s => (
              <option key={s.value} value={s.value}>
                {s.label}
              </option>
            ))}
          </select>
          {errors.state && <p className="text-error text-sm">{String(errors.state.message)}</p>}
        </div>
        <div>
          <label className="label">ZIP</label>
          <input className="input w-full" {...register('zip')} maxLength={5} />
          {errors.zip && <p className="text-error text-sm">{String(errors.zip.message)}</p>}
        </div>
      </div>

      <div className="flex items-center gap-3">
        <button className="btn btn-primary" type="submit" disabled={submitting}>
          {submitting ? 'Saving...' : 'Save'}
        </button>
      </div>
    </form>
  )
}
