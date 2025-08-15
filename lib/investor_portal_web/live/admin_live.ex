defmodule InvestorPortalWeb.AdminLive do
  use InvestorPortalWeb, :live_view

  alias InvestorPortal.Investors
  @impl true
  def mount(_params, _session, socket) do
    investor_datas = Investors.list_by(user_id: socket.assigns.current_scope.user.id)

    {:ok, socket |> assign(investor_datas: investor_datas)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>Investor Data</.header>
      <.button phx-click="new">New Investor</.button>
      <.table
        :if={@investor_datas != []}
        id="investor-data"
        rows={@investor_datas}
        row_id={fn investor_data -> "investor_data-#{investor_data.id}" end}
      >
        <:col :let={investor_data} label="First Name">{investor_data.first_name}</:col>
        <:col :let={investor_data} label="Last Name">{investor_data.last_name}</:col>
        <:col :let={investor_data} label="Phone">{investor_data.phone}</:col>
        <:col :let={investor_data} label="Address">{investor_data.address}</:col>
        <:col :let={investor_data} label="State">{investor_data.state}</:col>
        <:col :let={investor_data} label="Zip">{investor_data.zip}</:col>
        <:col :let={investor_data} label="Upload">
          <%= if investor_data.uploads do %>
            <.link href={investor_data.uploads} target="_blank" class="link">Download</.link>
          <% else %>
            -
          <% end %>
        </:col>
        <:col :let={investor_data} label="Actions">
          <button class="btn btn-primary" phx-click="edit" phx-value-id={investor_data.id}>
            Edit
          </button>
        </:col>
      </.table>
      <p :if={@investor_datas == []}>No investor data yet, add some!</p>

      <div class="max-w-2xl mx-auto py-8">
        <div
          id="investor-info-root"
          phx-hook="InvestorInfo"
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("new", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", %{"id" => _id}, socket) do
    {:noreply, socket}
  end
end
