defmodule InvestorPortal.Api.Mutations.Investors do
  use Absinthe.Schema.Notation

  alias InvestorPortal.Api.Resolvers
  alias InvestorPortal.Api.Middlewares.Authenticator

  object :investor_mutations do
    @desc "Create an investor record"
    field :create_investor, non_null(:investor) do
      arg(:input, non_null(:investor_input))

      middleware(Authenticator)
      resolve(&Resolvers.Investors.create_investor/3)
    end
  end
end
