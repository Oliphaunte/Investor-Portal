defmodule InvestorPortal.Api.Resolvers.Investors do
  @moduledoc false

  alias InvestorPortal.Investor
  alias InvestorPortal.Investors

  @doc false
  def create_investor(_parent, %{input: input}, %{context: %{current_user: user}})
      when not is_nil(user) do
    attrs = Map.put(input, :user_id, user.id)

    case Investors.create(attrs) do
      {:ok, investor} ->
        {:ok, investor}

      {:error, %Ecto.Changeset{} = cs} ->
        {:error, humanize_errors(cs)}

      other ->
        other
    end
  end

  @doc false
  def get_investor(_parent, %{id: id}, %{context: %{current_user: user}})
      when not is_nil(user) do
    {:ok, Investors.get_by(%{id: id, user_id: user.id})}
  end

  def update_investor(_parent, %{id: id, input: input}, %{context: %{current_user: user}})
      when not is_nil(user) do
    attrs = Map.put(input, :user_id, user.id)

    with %Investor{} = investor <- Investors.get_by(%{id: id, user_id: user.id}),
         {:ok, updated} <- Investors.update(investor, attrs) do
      Phoenix.PubSub.broadcast(
        InvestorPortal.PubSub,
        "investor_data",
        {:investor_updated, updated}
      )

      {:ok, updated}
    else
      {:error, %Ecto.Changeset{} = cs} ->
        {:error, humanize_errors(cs)}

      {:error, :not_found} ->
        {:error, "Investor not found"}

      other ->
        other
    end
  end

  def delete_investor(_parent, %{id: id}, %{context: %{current_user: user}})
      when not is_nil(user) do
    with %Investor{} = investor <- Investors.get_by(%{id: id, user_id: user.id}) do
      case Investors.delete(investor) do
        {:ok, _deleted} ->
          Phoenix.PubSub.broadcast(
            InvestorPortal.PubSub,
            "investor_data",
            {:investor_deleted, investor}
          )

          {:ok, true}

        {:error, %Ecto.Changeset{} = cs} ->
          {:error, humanize_errors(cs)}

        other ->
          other
      end
    end
  end

  defp humanize_errors(%Ecto.Changeset{} = changeset) do
    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    errors
    |> Enum.map(fn {_field, msgs} ->
      "#{Enum.join(msgs, ", ")}"
    end)
    |> Enum.join("; ")
  end
end
