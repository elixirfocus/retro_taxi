defmodule RetroTaxiWeb.BoardLive do
  @moduledoc false

  use RetroTaxiWeb, :live_view

  alias RetroTaxi.Boards
  alias RetroTaxiWeb.Presence

  defp presence_topic(board_id), do: "board-presence:#{board_id}"

  @impl true
  def mount(:not_mounted_at_router, session, socket) do
    if connected?(socket), do: Boards.subscribe()
    board = Boards.get_board!(session["board_id"], [:facilitator])
    current_user = session["current_user"]
    columns = Boards.list_columns(board.id, [:topic_cards])

    Presence.track(
      self(),
      presence_topic(board.id),
      current_user.id,
      %{
        display_name: current_user.display_name,
        user_id: current_user.id
      }
    )

    # Subscribe to the presence endpoint.
    if connected?(socket), do: RetroTaxiWeb.Endpoint.subscribe(presence_topic(board.id))

    users =
      Presence.list(presence_topic(board.id))
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)

    {:ok,
     assign(socket, board: board, columns: columns, users: users, current_user: current_user)}
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_info({:board_phase_updated, board}, socket)
      when socket.assigns.board.id == board.id do
    {:noreply, update(socket, :board, fn _current_board -> board end)}
  end

  def handle_info({:topic_card_created, topic_card}, socket) do
    IO.inspect("topic_card_created")
    # FIXME: For now we are using a generic `boards` topic name so we'll need to
    # filter here to make sure we only react to topic cards that are present on
    # this board.

    column_ids = Enum.map(socket.assigns.columns, & &1.id)
    IO.inspect(column_ids, label: "column_ids")
    IO.inspect(topic_card.column_id, label: "topic_card.column_id")

    if topic_card.column_id in column_ids do
      # If a topic card of this board, reload the board.

      # I feel like I need to maybe update a collection of columns on the liveview and have the columns be preloaded with the topic cards so I can properly kick the liveview change tracking with this call.
      {:noreply,
       update(socket, :columns, fn _current_columns ->
         Boards.list_columns(socket.assigns.board.id, [:topic_cards])
       end)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: _payload},
        socket = %{assigns: %{board: board}}
      ) do
    users =
      Presence.list(presence_topic(board.id))
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
    <div id="board-<%= @board.id %>">

      <%= live_component @socket, RetroTaxiWeb.BoardHeaderComponent, board: @board, users: @users %>
      <%= live_component @socket, RetroTaxiWeb.PhaseDisplayComponent, id: @board.id, board: @board %>

      <div class="lg:grid lg:grid-cols-4 lg:gap-4">

      <%= for column <- @columns do %>
        <%= live_component @socket, RetroTaxiWeb.ColumnComponent, id: column.id, column: column %>
      <% end %>

      </div>
    </div>
    """
  end
end
