defmodule InvestorPortal.Api.Types do
  use Absinthe.Schema.Notation

  import_types(Absinthe.Type.Custom)
  import_types(InvestorPortal.Api.Types.Investor)
end
