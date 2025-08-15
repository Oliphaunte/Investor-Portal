defmodule InvestorPortal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      InvestorPortalWeb.Telemetry,
      InvestorPortal.Repo,
      {DNSCluster, query: Application.get_env(:investor_portal, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: InvestorPortal.PubSub},
      # Start a worker by calling: InvestorPortal.Worker.start_link(arg)
      # {InvestorPortal.Worker, arg},
      # Start to serve requests, typically the last entry
      InvestorPortalWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InvestorPortal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InvestorPortalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
