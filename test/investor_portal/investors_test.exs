defmodule InvestorPortal.InvestorsTest do
  use InvestorPortal.DataCase

  alias InvestorPortal.Investors
  alias InvestorPortal.Investor

  import InvestorPortal.AccountsFixtures

  defp valid_attrs(user, overrides \\ %{}) do
    base = %{
      first_name: "Jane",
      last_name: "Doe",
      phone: "555-555-1234",
      address: "123 Main St",
      state: "CA",
      zip: "94105",
      uploads: "[]",
      user_id: user.id
    }

    Map.merge(base, overrides)
  end

  describe "create/2" do
    test "creates investor with valid attrs" do
      user = user_fixture()
      assert {:ok, %Investor{} = investor} = Investors.create(valid_attrs(user))
      assert investor.first_name == "Jane"
      assert investor.user_id == user.id
    end

    test "returns error changeset with invalid attrs" do
      user = user_fixture()
      assert {:error, changeset} = Investors.create(valid_attrs(user) |> Map.delete(:first_name))
      assert %{first_name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "list/1" do
    test "lists all investors" do
      user = user_fixture()
      {:ok, inv} = Investors.create(valid_attrs(user))
      assert [got] = Investors.list()
      assert got.id == inv.id
    end

    test "preloads associations when requested" do
      user = user_fixture()
      _ = Investors.create(valid_attrs(user))
      [preloaded] = Investors.list(preload: [:user])
      assert preloaded.user.id == user.id
    end
  end

  describe "list_by/2" do
    test "filters by params" do
      user = user_fixture()
      {:ok, inv1} = Investors.create(valid_attrs(user, %{first_name: "Alice"}))
      _ = Investors.create(valid_attrs(user, %{first_name: "Bob"}))

      results = Investors.list_by([first_name: "Alice"]) 
      assert Enum.map(results, & &1.id) == [inv1.id]
    end
  end

  describe "get/2 and get_by/2" do
    test "get/2 returns the investor by id" do
      user = user_fixture()
      {:ok, inv} = Investors.create(valid_attrs(user))
      result = Investors.get(inv.id)
      assert %Investor{} = result
      assert result.id == inv.id
    end

    test "get/2 supports preload" do
      user = user_fixture()
      {:ok, inv} = Investors.create(valid_attrs(user))
      pre = Investors.get(inv.id, preload: [:user])
      assert pre.user.id == user.id
    end

    test "get_by/2 returns investor by fields or nil" do
      user = user_fixture()
      {:ok, inv} = Investors.create(valid_attrs(user, %{first_name: "Eve"}))
      result = Investors.get_by(first_name: "Eve")
      assert %Investor{} = result
      assert result.id == inv.id
      assert is_nil(Investors.get_by(first_name: "Nope"))
    end
  end

  describe "update/3" do
    test "updates investor attributes" do
      user = user_fixture()
      {:ok, inv} = Investors.create(valid_attrs(user))
      assert {:ok, updated} = Investors.update(inv, %{state: "NY"})
      assert updated.state == "NY"
    end

    test "update/3 supports preload" do
      user = user_fixture()
      {:ok, inv} = Investors.create(valid_attrs(user))
      assert {:ok, updated} = Investors.update(inv, %{state: "TX"}, preload: [:user])
      assert updated.user.id == user.id
    end
  end

  describe "delete/2" do
    test "deletes investor" do
      user = user_fixture()
      {:ok, inv} = Investors.create(valid_attrs(user))
      assert {:ok, %Investor{}} = Investors.delete(inv)
      assert is_nil(Investors.get(inv.id))
    end
  end
end
