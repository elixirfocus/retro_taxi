defmodule RetroTaxiWeb.BoardLive do
  @moduledoc false

  use RetroTaxiWeb, :live_view

  alias RetroTaxi.Boards

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    board = Boards.get_board!(id)
    {:ok, assign(socket, board: board)}
  end

  @impl true
  def handle_event("add", _, socket) do
    IO.puts("add event")
    {:noreply, socket}
  end
end
