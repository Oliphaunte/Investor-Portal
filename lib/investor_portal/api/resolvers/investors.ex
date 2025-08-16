defmodule InvestorPortal.Api.Resolvers.Investors do
  @moduledoc false

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
