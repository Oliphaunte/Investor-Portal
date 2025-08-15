defmodule InvestorPortalWeb.LandingLive do
  use InvestorPortalWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col justify-center min-h-[70vh]">
        <section class="flex items-center">
          <div class="max-w-5xl mx-auto px-4 py-8 text-center">
            <h1 class="text-3xl sm:text-4xl font-semibold">
              Welcome to your Investor Portal
            </h1>
            <p class="mt-3 text-base-content/70 max-w-2xl mx-auto">
              A simple, secure way to manage investor information and documents.
              Stay organized with streamlined onboarding and real-time updates.
            </p>

            <div class="mt-6 flex justify-center gap-3">
              <.button variant="primary" navigate={~p"/users/register"}>
                Get Started
              </.button>
              <.button navigate={~p"/users/log-in"}>
                Log in
              </.button>
            </div>
          </div>
        </section>

        <section class="max-w-5xl mx-auto px-4 py-12">
          <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            <div class="rounded-box p-5 bg-base-100 border border-base-300">
              <div class="flex items-center gap-3">
                <.icon name="hero-user-plus" class="size-6 text-primary" />
                <h3 class="font-semibold">Easy onboarding</h3>
              </div>
              <p class="mt-2 text-sm text-base-content/70">
                Capture investor info fast with validation and clear guidance.
              </p>
            </div>

            <div class="rounded-box p-5 bg-base-100 border border-base-300">
              <div class="flex items-center gap-3">
                <.icon name="hero-cloud-arrow-up" class="size-6 text-primary" />
                <h3 class="font-semibold">Document uploads</h3>
              </div>
              <p class="mt-2 text-sm text-base-content/70">
                Collect, download, and manage investor documents in one place.
              </p>
            </div>

            <div class="rounded-box p-5 bg-base-100 border border-base-300">
              <div class="flex items-center gap-3">
                <.icon name="hero-bolt" class="size-6 text-primary" />
                <h3 class="font-semibold">Real-time updates</h3>
              </div>
              <p class="mt-2 text-sm text-base-content/70">
                Changes sync instantly with Phoenix LiveView and PubSub.
              </p>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
