defmodule InvestorPortalWeb.UploadControllerTest do
  use InvestorPortalWeb.ConnCase, async: true

  alias InvestorPortal.Repo
  alias InvestorPortal.Investor
  import InvestorPortal.AccountsFixtures

  setup :register_and_log_in_user

  defp create_investor!(user_id) do
    %Investor{
      first_name: "First",
      last_name: "Last",
      phone: "+1 555 111 2222",
      address: "123 St",
      state: "CA",
      zip: "90001",
      user_id: user_id
    }
    |> Repo.insert!()
  end

  test "POST /api/investor_data/:id/uploads without files returns 422", %{conn: conn, user: user} do
    investor = create_investor!(user.id)

    token = Plug.CSRFProtection.get_csrf_token()

    conn =
      conn
      |> Plug.Conn.put_req_header("x-csrf-token", token)

    resp =
      post(conn, ~p"/api/investor_data/#{investor.id}/uploads", %{})
      |> json_response(422)

    assert resp["error"] == "no files provided"
  end

  test "POST /api/investor_data/:id/uploads attaches file and broadcasts", %{
    conn: conn,
    user: user
  } do
    investor = create_investor!(user.id)

    tmp_path = Path.join(System.tmp_dir!(), "upload_test.txt")
    File.write!(tmp_path, "hello")

    upload = %Plug.Upload{filename: "upload_test.txt", path: tmp_path, content_type: "text/plain"}

    Phoenix.PubSub.subscribe(InvestorPortal.PubSub, "investor_data")

    token = Plug.CSRFProtection.get_csrf_token()

    conn =
      conn
      |> Plug.Conn.put_req_header("x-csrf-token", token)

    resp =
      post(conn, ~p"/api/investor_data/#{investor.id}/uploads", %{file: upload})
      |> json_response(201)

    assert resp["investor_id"] == investor.id
    assert is_list(resp["files"]) and length(resp["files"]) == 1

    updated = Repo.get!(Investor, investor.id)
    assert is_binary(updated.uploads) and String.contains?(updated.uploads, "/uploads/")

    id = investor.id
    assert_receive {:investor_updated, %Investor{id: ^id}}
  end
end
