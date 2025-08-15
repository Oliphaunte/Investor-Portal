defmodule InvestorPortal.Repo.Migrations.CreateInvestorData do
  use Ecto.Migration

  def change do
    create table(:investor_data, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :phone, :string
      add :address, :string
      add :state, :string
      add :zip, :string
      add :uploads, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:investor_data, [:first_name, :last_name, :user_id])
    create index(:investor_data, [:user_id])
  end
end
