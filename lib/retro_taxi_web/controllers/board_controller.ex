defmodule RetroTaxiWeb.BoardController do
  use RetroTaxiWeb, :controller

  import Phoenix.LiveView.Controller

  alias RetroTaxi.BoardCreation
  alias RetroTaxi.BoardCreation.Request, as: BoardCreationRequest
  alias RetroTaxi.Boards
  alias RetroTaxi.Users
  alias RetroTaxi.JoinBoard
  alias RetroTaxi.JoinBoard.Request, as: JoinBoardRequest

  plug RetroTaxiWeb.Plugs.CurrentUserAssignment when action in [:show, :join, :post_join]

  def new(conn, _params) do
    changeset =
      BoardCreation.change_request(
        %BoardCreationRequest{},
        %{
          facilitator_name: user_name_from_session(conn)
        }
      )

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{
        "request" => %{
          "board_name" => board_name,
          "facilitator_name" => facilitator_name
        }
      }) do
    request = %BoardCreationRequest{board_name: board_name, facilitator_name: facilitator_name}

    # TODO: Need to add lookup for user_id
    user_id = Plug.Conn.get_session(conn, :user_id)

    case BoardCreation.process_request(request, user_id) do
      {:ok, board, user} ->
        # update the user_id in the session, since `process_request/2` may have created or updated the user.
        conn
        |> Plug.Conn.put_session(:user_id, user.id)
        |> redirect(to: Routes.board_path(conn, :show, board.id))

      {:error, :user_not_found} ->
        changeset =
          BoardCreation.change_request(%BoardCreationRequest{}, %{
            board_name: board_name,
            facilitator_name: facilitator_name
          })

        conn
        |> put_flash(:error, "Internal error: Expected to find user but none found.")
        |> render("new.html", changeset: changeset)

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => board_id}) do
    user_id = Plug.Conn.get_session(conn, :user_id)

    if JoinBoard.should_prompt_user_for_identity_confirmation?(user_id, board_id) do
      redirect(conn, to: Routes.board_path(conn, :join, board_id))
    else
      live_render(conn, RetroTaxiWeb.BoardLive, session: %{"board_id" => board_id})
    end
  end

  def join(conn, %{"id" => board_id}) do
    board = Boards.get_board!(board_id)
    user_id = Plug.Conn.get_session(conn, :user_id)

    if JoinBoard.should_prompt_user_for_identity_confirmation?(user_id, board_id) do
      request = %JoinBoardRequest{display_name: user_name_from_session(conn)}
      changeset = JoinBoard.change_request(request, %{})

      render(conn, "join.html", board: board, changeset: changeset)
    else
      redirect(conn, to: Routes.board_path(conn, :show, board_id))
    end
  end

  def post_join(conn, %{"id" => board_id, "request" => %{"display_name" => display_name}}) do
    board = Boards.get_board!(board_id)
    user_id = Plug.Conn.get_session(conn, :user_id)
    request = %JoinBoardRequest{display_name: display_name}

    case JoinBoard.process_request(request, user_id, board_id) do
      {:error, :user_not_found} ->
        conn
        |> put_flash(:error, "Internal error: Expected to find user but none found.")
        |> redirect(to: Routes.board_path(conn, :join, board_id))

      {:error, changeset} ->
        render(conn, "join.html", board: board, changeset: changeset)

      {:ok, user, _event} ->
        conn
        |> Plug.Conn.put_session(:user_id, user.id)
        |> redirect(to: Routes.board_path(conn, :show, board.id))
    end
  end

  defp user_name_from_session(conn) do
    user_name_from_user_id(Plug.Conn.get_session(conn, :user_id))
  end

  defp user_name_from_user_id(nil), do: nil

  defp user_name_from_user_id(user_id) do
    case Users.get_user(user_id) do
      nil -> nil
      user -> user.display_name
    end
  end
end
