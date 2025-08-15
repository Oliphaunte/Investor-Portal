defmodule InvestorPortalWeb.Components.Header do
  use InvestorPortalWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <header class="p-4">
      <ul class="menu menu-horizontal w-full relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
        <%= if @current_scope do %>
          <li>
            {@current_scope.user.email}
          </li>
          <li>
            <.link href={~p"/users/log-out"} method="delete">Log out</.link>
          </li>
        <% else %>
          <li>
            <.link href={~p"/users/register"}>Register</.link>
          </li>
          <li>
            <.link href={~p"/users/log-in"}>Log in</.link>
          </li>
        <% end %>
      </ul>
    </header>
    """
  end
end
