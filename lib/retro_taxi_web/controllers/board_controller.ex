defmodule RetroTaxiWeb.BoardController do
  use RetroTaxiWeb, :controller

  import Phoenix.LiveView.Controller

  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Boards.BoardCreationRequest
  alias RetroTaxi.Users

  def new(conn, _params) do
    changeset =
      Boards.change_board_creation_request(
        %BoardCreationRequest{},
        %{
          facilitator_name: user_name_from_session(conn)
        }
      )

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{
        "board_creation_request" => %{"board_name" => board_name},
        "facilitator_name" => facilitator_name
      }) do
    # validate the board creation request, if it looks good, make the board, update/create the session identity, redirect to board.

    changeset =
      Boards.change_board_creation_request(
        %BoardCreationRequest{},
        %{
          board_name: board_name,
          facilitator_name: facilitator_name
        }
      )

    case Boards.create_board(name: name) do
      {:ok, board} ->
        # Hardcode a identity name for facilitator

        redirect(conn, to: Routes.board_path(conn, :show, board.id))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => board_id}) do
    conn
    |> populate_empty_identity_id()
    |> live_render(RetroTaxiWeb.BoardLive, session: %{"board_id" => board_id})
  end

  defp user_name_from_session(conn) do
    user_name_from_user_id(Plug.Conn.get_session(conn, :user_id))
  end

  defp user_name_from_user_id(nil), do: nil

  defp user_name_from_user_id(user_id) do
    case Users.get_user(user_id) do
      nil -> nil
      user -> user.name
    end
  end

  defp populate_empty_identity_id(conn) do
    if is_nil(Plug.Conn.get_session(conn, :identity_id)) do
      Plug.Conn.put_session(conn, :identity_id, Ecto.UUID.generate())
    else
      conn
    end
  end
end
