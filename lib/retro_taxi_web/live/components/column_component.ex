defmodule RetroTaxiWeb.ColumnComponent do
  use RetroTaxiWeb, :live_component

  alias RetroTaxi.Boards

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(topic_cards: Boards.list_topic_cards(column_id: assigns.column.id))

    {:ok, socket}
  end

  def handle_event("add", _params, socket) do
    {:ok, topic_card} =
      Boards.create_topic_card(
        content: Faker.Lorem.sentence(),
        column_id: socket.assigns.column.id
      )

    new_list = socket.assigns.topic_cards ++ [topic_card]
    socket = assign(socket, topic_cards: new_list)

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="bg-gray-200 p-2 my-2">

      <h2 class="text-2xl font-bold">
        <%= @column.title %>
      </h2>

      <button phx-click="add" phx-target="<%= @myself %>"
        class="bg-yellow-300 hover:bg-yellow-400 active:bg-yellow-300 font-bold w-full text-gray-900 p-2 ">
        Add +
      </button>

      <%= for topic_card <- @topic_cards do %>
        <%= live_component @socket, RetroTaxiWeb.TopicCardShowComponent, id: topic_card.id, topic_card: topic_card %>
      <% end %>

      <%# live_component @socket, RetroTaxiWeb.CreateTopicCardFormComponent %>

    </div>
    """
  end
end
