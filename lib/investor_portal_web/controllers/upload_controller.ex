defmodule InvestorPortalWeb.UploadController do
  @moduledoc """
  Handles file uploads for investors

  We can upload a max size of 50MB and one file at a time
  """
  use InvestorPortalWeb, :controller

  alias InvestorPortal.Investors
  alias InvestorPortal.Investor

  @dev_routes Application.compile_env(:investor_portal, :dev_routes)
  @priv Path.join([:code.priv_dir(:investor_portal) |> to_string(), "static"])

  def create(conn, %{"id" => investor_id} = params) do
    user = current_user(conn)

    with %Investor{} = investor <- Investors.get_by(%{id: investor_id, user_id: user.id}) do
      sleep_if_dev()

      case get_upload(params) do
        nil ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: "no files provided"})

        %Plug.Upload{} = upload ->
          case save_upload(investor.id, upload) do
            {:ok, file_map} ->
              persist_upload_url(investor, file_map.url)

              conn
              |> put_status(:created)
              |> json(%{investor_id: investor.id, files: [file_map], errors: []})

            {:error, err_map} ->
              conn
              |> put_status(:multi_status)
              |> json(%{investor_id: investor.id, files: [], errors: [err_map]})
          end
      end
    else
      _ -> send_resp(conn, :not_found, "not found")
    end
  end

  def delete(conn, %{"id" => investor_id}) do
    user = current_user(conn)

    with %Investor{} = investor <- Investors.get_by(%{id: investor_id, user_id: user.id}),
         true <- investor.user_id == user.id do
      delete_upload_file(investor.uploads)

      case investor |> Investors.update(%{uploads: nil}) do
        {:ok, updated} ->
          Phoenix.PubSub.broadcast(
            InvestorPortal.PubSub,
            "investor_data",
            {:investor_updated, updated}
          )

          conn |> put_status(:ok) |> json(%{investor_id: updated.id, deleted: true})

        {:error, cs} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(cs.errors)})
      end
    else
      _ -> send_resp(conn, :not_found, "not found")
    end
  end

  defp current_user(conn), do: conn.assigns.current_scope && conn.assigns.current_scope.user

  # Just to simulate a network delay in dev
  defp sleep_if_dev, do: if(@dev_routes, do: Process.sleep(2000))

  defp get_upload(params) do
    case Map.get(params, "file") do
      %Plug.Upload{} = u -> u
      _ -> nil
    end
  end

  defp persist_upload_url(%Investor{} = investor, url) when is_binary(url) do
    investor
    |> Investors.update(%{uploads: url})
    |> case do
      {:ok, updated} ->
        Phoenix.PubSub.broadcast(
          InvestorPortal.PubSub,
          "investor_data",
          {:investor_updated, updated}
        )

        :ok

      _ ->
        :ok
    end
  end

  defp delete_upload_file(nil), do: :ok
  defp delete_upload_file(""), do: :ok

  defp delete_upload_file(url) when is_binary(url) do
    path = Path.join([@priv | String.split(url, "/", trim: true)])
    _ = File.rm(path)
    :ok
  end

  defp save_upload(investor_id, %Plug.Upload{filename: name, path: tmp}) do
    base_dir = Path.join([@priv, "uploads", investor_id])
    :ok = File.mkdir_p(base_dir)
    dest = Path.join(base_dir, name)

    case File.cp(tmp, dest) do
      :ok ->
        url = Path.join(["/uploads", investor_id, name])
        size = File.stat!(dest).size
        {:ok, %{filename: name, url: url, size: size}}

      {:error, reason} ->
        {:error, %{filename: name, error: inspect(reason)}}
    end
  end
end
