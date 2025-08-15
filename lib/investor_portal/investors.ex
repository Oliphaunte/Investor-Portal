defmodule InvestorPortal.Investors do
  @moduledoc """
  Context for Investors
  """

  alias InvestorPortal.Repo
  alias InvestorPortal.Investor
  import Ecto.Query

  @doc """
  Creates an investor
  """
  def create(attrs \\ %{}, opts \\ []) do
    %Investor{}
    |> Investor.changeset(attrs)
    |> Repo.insert(opts)
    |> case do
      {:ok, investor} -> {:ok, maybe_preload(investor, opts[:preload])}
      error -> error
    end
  end

  @doc """
  Updates an investor
  """
  def update(%Investor{} = investor, attrs \\ %{}, opts \\ []) do
    investor
    |> Investor.changeset(attrs)
    |> Repo.update(opts)
    |> case do
      {:ok, updated_investor} -> {:ok, maybe_preload(updated_investor, opts[:preload])}
      error -> error
    end
  end

  @doc """
  Deletes an investor
  """
  def delete(%Investor{} = investor, opts \\ []) do
    Repo.delete(investor, opts)
    |> case do
      {:ok, _deleted} = ok ->
        ok

      error ->
        error
    end
  end

  @doc """
  Lists all investors
  """
  def list(opts \\ []) do
    Investor
    |> Repo.all(opts)
    |> maybe_preload(opts[:preload])
  end

  @doc """
  Lists investor by query
  """
  def list_by(params, opts \\ []) do
    Investor
    |> where(^params)
    |> Repo.all(opts)
    |> maybe_preload(opts[:preload])
  end

  @doc """
  Get investor by id
  """
  def get(id, opts \\ []) do
    Repo.get(Investor, id, opts)
    |> maybe_preload(opts[:preload])
  end

  @doc """
  Get investor by parameters
  """
  def get_by(params \\ %{}, opts \\ []) do
    Repo.get_by(Investor, params, opts)
    |> maybe_preload(opts[:preload])
  end

  defp maybe_preload(set, nil), do: set
  defp maybe_preload(set, preload), do: Repo.preload(set, preload)
end
