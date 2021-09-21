defmodule RetroTaxiWeb.BoardControllerTest do
  use RetroTaxiWeb.ConnCase

  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.BoardCreation
  alias RetroTaxi.BoardCreation.Request

  # GET /
  describe "new/2" do
    test "renders form as expected", %{conn: conn} do
      {:ok, html} =
        conn
        |> get(Routes.board_path(conn, :new))
        |> html_response(200)
        |> Floki.parse_document()

      assert [{"input", _, _}] = Floki.find(html, "#request_board_name")
      assert html |> Floki.find("button[type=submit]") |> Floki.text() == "Create Board"
    end
  end

  # POST /
  describe "create/2" do
    test "works when valid name is submitted", %{conn: conn} do
      params = %{
        "request" => %{
          "board_name" => "TestBoard",
          "facilitator_name" => "TestFacilitator"
        }
      }

      conn = post(conn, Routes.board_path(conn, :new), params)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.board_path(conn, :show, id)

      assert %Board{name: "TestBoard"} = Boards.get_board!(id)
      # TODO: Add assertion that user was updated with new name.
    end
  end

  describe "show/2" do
    test "should render the board with no identity prompt when being loaded by the facilitator after creation",
         %{conn: conn} do
      # It is important to actually use the `create/2` path so that the user_id
      # is properly set in the session.
      conn =
        post(conn, Routes.board_path(conn, :new), %{
          "request" => %{
            "board_name" => "TestBoard",
            "facilitator_name" => "TestFacilitator"
          }
        })

      %{id: board_id} = redirected_params(conn)

      {:ok, html} =
        conn
        |> get(Routes.board_path(conn, :show, board_id))
        |> html_response(200)
        |> Floki.parse_document()

      assert [{"h1", _, _}] = Floki.find(html, "#board-name")
    end

    test "should redirect to the identity prompt when being requested by an unknown user", %{
      conn: conn
    } do
      {:ok, board, _user} =
        BoardCreation.process_request(
          %Request{board_name: "Test Board", facilitator_name: "Test Facilitator"},
          nil
        )

      conn = get(conn, Routes.board_path(conn, :show, board.id))
      assert redirected_to(conn) == Routes.board_path(conn, :join, board.id)
    end

    test "should redirect to the identity prompt when being requested by a known, but new participant for this specific board",
         %{conn: conn} do
      {:ok, board, _facilitator_user} =
        BoardCreation.process_request(
          %Request{board_name: "Test Board", facilitator_name: "Test Facilitator"},
          nil
        )

      participant_user = insert(:user)

      conn = Plug.Test.init_test_session(conn, user_id: participant_user.id)
      conn = get(conn, Routes.board_path(conn, :show, board.id))
      assert redirected_to(conn) == Routes.board_path(conn, :join, board.id)
    end

    test "should render the board with no identity prompt when being loaded by a user who has previously accepted the identity prompt",
         %{conn: conn} do
      {:ok, board, _facilitator_user} =
        BoardCreation.process_request(
          %Request{board_name: "Test Board", facilitator_name: "Test Facilitator"},
          nil
        )

      participant_user = insert(:user)
      _event = insert(:user_identity_prompt_event, user: participant_user, board: board)

      conn = Plug.Test.init_test_session(conn, user_id: participant_user.id)

      {:ok, html} =
        conn
        |> get(Routes.board_path(conn, :show, board.id))
        |> html_response(200)
        |> Floki.parse_document()

      assert [{"h1", _, _}] = Floki.find(html, "#board-name")
    end
  end

  describe "join/2" do
    test "renders identity prompt for a user who is new to a board" do
      {:ok, board, _facilitator_user} =
        BoardCreation.process_request(
          %Request{board_name: "Test Board", facilitator_name: "Test Facilitator"},
          nil
        )

      {:ok, html} =
        conn
        |> get(conn, Routes.board_path(conn, :join, board.id))
        |> html_response(200)
        |> Floki.parse_document()

      assert [{"input", _, _}] = Floki.find(html, "#request_board_name")
      assert html |> Floki.find("button[type=submit]") |> Floki.text() == "Join Board"
    end

    test "redirects to show the board for a user who has already seen the prompt" do
    end

    test "renders a 404 when no board for the given id is passed in" do
    end
  end
end
