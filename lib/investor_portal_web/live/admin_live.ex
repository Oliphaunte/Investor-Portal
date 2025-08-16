defmodule InvestorPortalWeb.AdminLive do
  use InvestorPortalWeb, :live_view

  alias InvestorPortal.Investors
  @impl true
  def mount(_params, _session, socket) do
    investor_datas = Investors.list_by(user_id: socket.assigns.current_scope.user.id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(InvestorPortal.PubSub, "investor_data")
    end

    {:ok,
     socket
     |> assign(step: :info)
     |> assign(current_investor: nil)
     |> assign(investor_datas: investor_datas)}
  end

  @impl true
  def handle_info({:investor_updated, investor}, socket) do
    list = Investors.list_by(user_id: socket.assigns.current_scope.user.id)

    socket =
      if socket.assigns.current_investor && socket.assigns.current_investor.id == investor.id do
        socket
        |> assign(investor_datas: list)
        |> assign(current_investor: investor)
        |> put_flash(:info, "Investor updated successfully")
      else
        socket |> assign(investor_datas: list)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:investor_deleted, investor}, socket) do
    list = Investors.list_by(user_id: socket.assigns.current_scope.user.id)

    socket =
      if socket.assigns.current_investor && socket.assigns.current_investor.id == investor.id do
        socket
        |> assign(step: :info)
        |> assign(investor_datas: list)
        |> assign(current_investor: nil)
        |> put_flash(:info, "Investor deleted successfully")
      else
        socket |> assign(investor_datas: list)
      end

    {:noreply, socket}
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
          :if={@step == :info}
          id="investor-info-root"
          phx-hook="InvestorInfo"
          phx-update="ignore"
          data-investor-id={@current_investor && @current_investor.id}
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("new", _params, socket) do
    {:noreply, socket |> assign(step: :info) |> assign(current_investor: nil)}
  end

  @impl true
  def handle_event("investor_created", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(investor_datas: Investors.list_by(user_id: socket.assigns.current_scope.user.id))
     |> assign(current_investor: Investors.get(id))
     |> put_flash(:info, "Investor created successfully")}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, socket |> assign(step: :info) |> assign(current_investor: Investors.get(id))}
  end
end
