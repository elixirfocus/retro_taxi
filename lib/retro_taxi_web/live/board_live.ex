defmodule RetroTaxiWeb.BoardLive do
  @moduledoc false

  use RetroTaxiWeb, :live_view

  alias RetroTaxi.Boards
  alias RetroTaxiWeb.Presence

  defp topic(board_id), do: "board:#{board_id}"

  @impl true
  def mount(:not_mounted_at_router, session, socket) do
    board = Boards.get_board!(session["board_id"], [:facilitator, :columns])
    current_user = session["current_user"]

    Presence.track(
      self(),
      topic(board.id),
      current_user.id,
      %{
        display_name: current_user.display_name,
        user_id: current_user.id
      }
    )

    RetroTaxiWeb.Endpoint.subscribe(topic(board.id))

    users =
      Presence.list(topic(board.id))
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)

    {:ok, assign(socket, board: board, users: users, current_user: current_user)}
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
  def handle_info(
        %{event: "presence_diff", payload: _payload},
        socket = %{assigns: %{board: board}}
      ) do
    users =
      Presence.list(topic(board.id))
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)

    {:noreply, assign(socket, users: users)}
  end

  @impl true
  def render(assigns) do
    # TODO: If we are going to own the layout structure of the card columns in
    # this file, we may want similar ownership of the header layout rules that
    # currently live in `BoardHeaderComponent`.
    ~L"""
    <%= live_component @socket, RetroTaxiWeb.BoardHeaderComponent, board: @board, users: @users %>

    <div class="lg:grid lg:grid-cols-4 lg:gap-4">

    <%= for column <- @board.columns do %>
      <%= live_component @socket, RetroTaxiWeb.ColumnComponent, id: column.id, column: column %>
    <% end %>

    </div>

    """
  end
end
