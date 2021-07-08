defmodule RetroTaxiWeb.BoardController do
  use RetroTaxiWeb, :controller

  import Phoenix.LiveView.Controller

  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board

  def new(conn, _params) do
    changeset = Boards.change_board(%Board{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"board" => %{"name" => name}}) do
    case Boards.create_board(name: name) do
      {:ok, board} ->
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

  defp populate_empty_identity_id(conn) do
    if is_nil(Plug.Conn.get_session(conn, :identity_id)) do
      Plug.Conn.put_session(conn, :identity_id, Ecto.UUID.generate())
    else
      conn
    end
  end
end
