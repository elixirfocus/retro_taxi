defmodule RetroTaxiWeb.BoardController do
  use RetroTaxiWeb, :controller

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

  def show(conn, %{"id" => id}) do
    board = Boards.get_board!(id)
    render(conn, "show.html", board: board)
  end
end
