defmodule RetroTaxiWeb.ColumnComponent do
  use RetroTaxiWeb, :live_component

  import RetroTaxiWeb.CloseButtonComponent, only: [close_button: 1]
  import RetroTaxiWeb.SubmitButtonComponent, only: [submit_button: 1]

  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.TopicCard
  alias RetroTaxi.Users.User

  def mount(socket) do
    {:ok, assign(socket, show_compose_form: false, compose_changeset: nil)}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(topic_card_ids: Boards.list_topic_card_ids(assigns.id))

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

    # The `create_topic_card/1` function will broadcast the needed PubSub event
    # to notify all LiveView clients looking at this board that `topic_card_ids`
    # need to be updated.
    {:ok, _topic_card} =
      Boards.create_topic_card(%{
        author_id: author_id,
        content: content,
        column_id: socket.assigns.column.id
      })

    # Hide the compose form.
    socket =
      socket
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
                <.close_button target={@myself} click_event="hide-compose-form" />
              </div>
              <.submit_button title="Add Card" />
            </div>

            </.form>
        </div>
      <% else %>
        <button phx-click="show-compose-form" phx-target={@myself}
        class="bg-yellow-300 hover:bg-yellow-400 active:bg-yellow-300 font-bold w-full text-gray-900 p-2 ">
          Add +
        </button>
      <% end %>

      <%= for topic_card_id <- @topic_card_ids do %>
        <%= live_component RetroTaxiWeb.TopicCardShowComponent, id: topic_card_id, board_phase: @board_phase, current_user_id: @current_user.id %>
      <% end %>

    </div>
    """
  end
end
