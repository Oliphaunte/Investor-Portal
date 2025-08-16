defmodule InvestorPortal.Api.Queries.Investors do
  use Absinthe.Schema.Notation

  alias InvestorPortal.Api.Resolvers

  object :investor_queries do
    @desc "Get an investor data record"
    field :get_investor, non_null(:investor) do
      arg(:id, non_null(:id))

      middleware(Authenticator)
      resolve(&Resolvers.Investors.get_investor/3)
    end
  end
end
