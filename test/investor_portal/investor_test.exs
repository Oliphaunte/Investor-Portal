defmodule InvestorPortal.InvestorTest do
  use InvestorPortal.DataCase, async: true

  alias InvestorPortal.Repo
  alias InvestorPortal.Investors
  alias InvestorPortal.Investor
  import InvestorPortal.AccountsFixtures

  test "list_by/2 filters by user_id" do
    u1 = user_fixture()
    u2 = user_fixture()

    i1 =
      %Investor{
        first_name: "A",
        last_name: "A",
        phone: "+1 555 000 0001",
        address: "Addr 1",
        state: "CA",
        zip: "90001",
        user_id: u1.id
      }
      |> Repo.insert!()

    _i2 =
      %Investor{
        first_name: "B",
        last_name: "B",
        phone: "+1 555 000 0002",
        address: "Addr 2",
        state: "NY",
        zip: "10001",
        user_id: u2.id
      }
      |> Repo.insert!()

    results = Investors.list_by(user_id: u1.id)
    assert Enum.map(results, & &1.id) == [i1.id]
  end
end
