defmodule InvestorPortal.Repo do
  use Ecto.Repo,
    otp_app: :investor_portal,
    adapter: Ecto.Adapters.Postgres
end
