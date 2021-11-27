defmodule RetroTaxiWeb.BoardLive do
  @moduledoc false

  use RetroTaxiWeb, :live_view

  import RetroTaxiWeb.BoardHeaderComponent, only: [header: 1]

  alias RetroTaxi.Boards
  alias RetroTaxiWeb.Presence

  defp presence_topic(board_id), do: "board-presence:#{board_id}"

  @impl true
  def mount(:not_mounted_at_router, session, socket) do
    board = Boards.get_board!(session["board_id"], [:facilitator])
    current_user = session["current_user"]
    columns = Boards.list_columns(board.id)

    if connected?(socket), do: Boards.subscribe(board.id)

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

  def handle_info({:board_phase_updated, board}, socket) do
    {:noreply,
     update(socket, :board, fn current_board ->
       %{current_board | phase: board.phase}
     end)}
  end

  def handle_info({:topic_card_created, topic_card}, socket) do
    send_update(RetroTaxiWeb.ColumnComponent,
      id: topic_card.column_id,
      board_phase: socket.assigns.board.phase,
      column: Enum.find(socket.assigns.columns, fn c -> c.id == topic_card.column_id end),
      current_user: socket.assigns.current_user
    )

    {:noreply, socket}
  end

  def handle_info({:topic_card_updated, topic_card}, socket) do
    send_update(RetroTaxiWeb.TopicCardShowComponent,
      id: topic_card.id,
      board_phase: socket.assigns.board.phase,
      current_user_id: socket.assigns.current_user.id
    )

    {:noreply, socket}
  end

  def handle_info({:topic_card_deleted, topic_card}, socket) do
    send_update(RetroTaxiWeb.ColumnComponent,
      id: topic_card.column_id,
      board_phase: socket.assigns.board.phase,
      column: Enum.find(socket.assigns.columns, fn c -> c.id == topic_card.column_id end),
      current_user: socket.assigns.current_user
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: _payload},
        %{assigns: %{board: board}} = socket
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
    ~H"""
    <div id={"board-" <> @board.id}>

      <.header board={@board} users={@users} />
      <%= live_component RetroTaxiWeb.PhaseDisplayComponent, id: @board.id, board: @board, show_facilitator_tools: @current_user.id == @board.facilitator_id %>

      <div class="lg:grid lg:grid-cols-4 lg:gap-4">

      <%= for column <- @columns do %>
        <%= live_component RetroTaxiWeb.ColumnComponent, id: column.id, column: column, board_phase: @board.phase, current_user: @current_user %>
      <% end %>

      </div>
    </div>
    """
  end
end
