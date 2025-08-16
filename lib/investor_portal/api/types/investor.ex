defmodule InvestorPortal.Api.Types.Investor do
  use Absinthe.Schema.Notation

  @desc "Investor data object"
  object :investor do
    field :id, non_null(:id)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone, non_null(:string)
    field :address, non_null(:string)
    field :state, non_null(:string)
    field :zip, non_null(:string)
    field :uploads, :string
    field :user_id, non_null(:id)
    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)
  end

  @desc "Input for creating investor data"
  input_object :investor_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone, non_null(:string)
    field :address, non_null(:string)
    field :state, non_null(:string)
    field :zip, non_null(:string)
    field :uploads, :string
  end
end
