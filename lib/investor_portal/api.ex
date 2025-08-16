defmodule InvestorPortal.API do
  use Absinthe.Schema

  import_types(InvestorPortal.Api.Types)
  import_types(InvestorPortal.Api.Queries)
  import_types(InvestorPortal.Api.Mutations)

  query do
    import_fields(:investor_queries)
  end

  mutation do
    import_fields(:investor_mutations)
  end
end
