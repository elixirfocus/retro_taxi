defmodule RetroTaxiWeb.BoardLive do
  @moduledoc false

  use RetroTaxiWeb, :live_view

  alias RetroTaxi.Boards

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    board = Boards.get_board!(id, [:columns])
    # IO.inspect(socket, label: "BoardLive")
    {:ok, assign(socket, board: board)}
  end

  @impl true
  def handle_event("test", _, socket) do
    IO.puts("test event")
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    # TODO: If we are going to own the layout structure of the card columns in
    # this file, we may want similar ownership of the header layout rules that
    # currently live in `BoardHeaderComponent`.
    ~L"""
    <%= live_component @socket, RetroTaxiWeb.BoardHeaderComponent, board: @board %>

    <div class="lg:grid lg:grid-cols-4 lg:gap-4">

    <%= for column <- @board.columns do %>
      <%= live_component @socket, RetroTaxiWeb.ColumnComponent, id: column.id, column: column %>
    <% end %>

    </div>

    """
  end
end
