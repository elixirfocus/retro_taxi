defmodule RetroTaxiWeb.BoardLive do
  @moduledoc false

  use RetroTaxiWeb, :live_view

  alias RetroTaxi.Boards

  @impl true
  def mount(:not_mounted_at_router, session, socket) do
    board = Boards.get_board!(session["board_id"], [:facilitator, :columns])
    {:ok, assign(socket, board: board, display_name: board.facilitator.display_name)}
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
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
    <%= live_component @socket, RetroTaxiWeb.BoardHeaderComponent, board: @board, display_name: @display_name %>

    <div class="lg:grid lg:grid-cols-4 lg:gap-4">

    <%= for column <- @board.columns do %>
      <%= live_component @socket, RetroTaxiWeb.ColumnComponent, id: column.id, column: column %>
    <% end %>

    </div>

    """
  end
end
