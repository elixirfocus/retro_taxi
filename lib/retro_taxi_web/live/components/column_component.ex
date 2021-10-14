defmodule RetroTaxiWeb.ColumnComponent do
  use RetroTaxiWeb, :live_component

  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.TopicCard
  alias RetroTaxi.Users.User

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(show_compose_form: false)
      |> assign(topic_cards: Boards.list_topic_cards(column_id: assigns.column.id))
      |> assign(compose_changeset: nil)

    {:ok, socket}
  end

  def handle_event("show-compose-form", _params, socket) do
    socket =
      socket
      |> assign(show_compose_form: true)
      |> assign(compose_changeset: Boards.change_topic_card(%TopicCard{}))

    {:noreply, socket}
  end

  def handle_event("add-topic", %{"topic_card" => %{"content" => content}}, socket) do
    %User{id: author_id} = socket.assigns.current_user

    {:ok, topic_card} =
      Boards.create_topic_card(%{
        author_id: author_id,
        content: content,
        column_id: socket.assigns.column.id
      })

    # FIXME: We need to be more explicit about sort order here but need to
    # understand how everyone will see the cards during the compose phase before
    # we lay down too many rules.
    new_list = socket.assigns.topic_cards ++ [topic_card]

    socket =
      socket
      |> assign(topic_cards: new_list)
      |> assign(show_compose_form: false)
      |> assign(compose_changeset: nil)

    {:noreply, socket}
  end

  def handle_event("hide-compose-form", _, socket) do
    socket =
      socket
      |> assign(show_compose_form: false)
      |> assign(compose_changeset: nil)

    {:noreply, socket}
  end

  def handle_info({:topic_card_created, topic_card}, socket)
      when socket.assigns.column_id == topic_card.column_id do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div id={"column-#{@column.id}"} class="bg-gray-200 p-2 my-2">

      <h2 class="text-2xl font-bold">
        <%= @column.title %>
      </h2>

      <%= if @show_compose_form do %>
        <div class="bg-yellow-100 p-0 my-2">
          <.form let={f} for={@compose_changeset} phx_submit={"add-topic"} phx_target={@myself}>
            <%= textarea f, :content, class: "text-gray-900 mt-1 p-2 block w-full rounded-md bg-transparent border-transparent focus:border-transparent focus:ring-0 ring-0", rows: "3" %>

            <div class="flex justify-between items-end mt-2 p-2">
              <div>
                <%= live_component @socket, RetroTaxiWeb.CloseButtonComponent, target: @myself, click_event: "hide-compose-form" %>
              </div>
              <%= live_component @socket, RetroTaxiWeb.SubmitButtonComponent, title: "Add Card" %>
            </div>

            </.form>
        </div>
      <% else %>
        <button phx-click="show-compose-form" phx-target={@myself}
        class="bg-yellow-300 hover:bg-yellow-400 active:bg-yellow-300 font-bold w-full text-gray-900 p-2 ">
          Add +
        </button>
      <% end %>

      <%= for topic_card <- @topic_cards do %>
        <%= live_component @socket, RetroTaxiWeb.TopicCardShowComponent, id: topic_card.id, topic_card: topic_card, board_phase: @board_phase, can_edit: topic_card.author_id == @current_user.id %>
      <% end %>

      <%# live_component @socket, RetroTaxiWeb.CreateTopicCardFormComponent %>

    </div>
    """
  end
end
