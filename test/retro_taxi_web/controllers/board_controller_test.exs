defmodule RetroTaxiWeb.BoardControllerTest do
  use RetroTaxiWeb.ConnCase

  # alias RetroTaxiWeb.ShortLinks.ShortLink

  # GET /
  describe "new/2" do
    test "renders form as expected", %{conn: conn} do
      {:ok, html} =
        conn
        |> get(Routes.board_path(conn, :new))
        |> html_response(200)
        |> Floki.parse_document()

      assert [{"input", _, _}] = Floki.find(html, "#board_name")
      assert html |> Floki.find("button[type=submit]") |> Floki.text() == "Create Board"
    end
  end

  # POST /
  describe "create/2" do
    test "works when valid name is submitted", %{conn: conn} do
      params = %{"board" => params_for(:board)}
      conn = post(conn, Routes.board_path(conn, :new), params)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.board_path(conn, :show, id)
    end
  end
end
