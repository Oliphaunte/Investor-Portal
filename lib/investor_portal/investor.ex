defmodule InvestorPortal.Investor do
  @moduledoc """
  Investor schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "investor_data" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :address, :string
    field :state, :string
    field :zip, :string
    field :uploads, :string
    belongs_to :user, InvestorPortal.Accounts.User, type: :binary_id

    timestamps()
  end

  def changeset(investor, attrs) do
    investor
    |> cast(attrs, [
      :first_name,
      :last_name,
      :phone,
      :address,
      :state,
      :zip,
      :uploads,
      :user_id
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :phone,
      :address,
      :state,
      :zip,
      :user_id
    ])
  end
end
