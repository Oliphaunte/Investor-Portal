defmodule InvestorPortalWeb.AdminLive do
  use InvestorPortalWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}></Layouts.app>
    """
  end
end
