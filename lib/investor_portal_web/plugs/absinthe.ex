defmodule InvestorPortalWeb.AbsintheContext do
  @moduledoc """
  Puts current_user into Absinthe context so resolvers can authorize.
  Requires that `InvestorPortalWeb.UserAuth.fetch_current_scope_for_user` has run.
  """
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_scope] && conn.assigns.current_scope.user

    Absinthe.Plug.put_options(conn, context: %{current_user: user})
  end
end
