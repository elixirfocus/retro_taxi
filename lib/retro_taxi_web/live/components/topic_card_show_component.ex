defmodule RetroTaxiWeb.TopicCardShowComponent do
  use RetroTaxiWeb, :live_component

  alias RetroTaxi.Boards

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(is_editing: false)

    {:ok, socket}
  end

  def handle_event("start-editing", _, socket) do
    socket =
      socket
      |> assign(is_editing: !socket.assigns.is_editing)
      |> assign(changeset: Boards.change_topic_card(socket.assigns.topic_card))

    {:noreply, socket}
  end

  def handle_event("cancel-editing", _, socket) do
    socket =
      socket
      |> assign(is_editing: false)
      |> assign(changeset: nil)

    {:noreply, socket}
  end

  def handle_event("delete", _, socket) do
    topic_card = socket.assigns.topic_card

    case Boards.delete_topic_card(topic_card) do
      {:ok, deleted_topic_card} ->
        socket = assign(socket, is_editing: false)
        socket = assign(socket, topic_card: deleted_topic_card)

        # alert via pub sub so column component can refresh it's list

        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, is_editing: true)
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("save", %{"topic_card" => %{"content" => content}}, socket) do
    topic_card = socket.assigns.topic_card

    case Boards.update_topic_card(topic_card, %{content: content}) do
      {:ok, updated_topic_card} ->
        socket = assign(socket, is_editing: false)
        socket = assign(socket, topic_card: updated_topic_card)
        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, is_editing: true)
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~L"""
      <div id="topic-card-<%= @topic_card.id %>">
        <%= if @is_editing do %>
          <div class="bg-yellow-100 p-0 my-2">
            <%= f = form_for @changeset, "#", phx_submit: "save", phx_target: @myself %>
              <%= textarea f, :content, class: "text-gray-900 mt-1 p-2 block w-full rounded-md bg-transparent border-transparent focus:border-transparent focus:ring-0 ring-0", rows: "3" %>

              <div class="flex justify-between items-end mt-2 p-2">
                <div>
                  <%= live_component @socket, RetroTaxiWeb.CloseButtonComponent, target: @myself, click_event: "cancel-editing" %>
                  <%= live_component @socket, RetroTaxiWeb.TrashButtonComponent, target: @myself, click_event: "delete" %>
                </div>
                <%= live_component @socket, RetroTaxiWeb.SubmitButtonComponent, title: "Save Card" %>
              </div>

            </form>
          </div>
        <% else %>

        <div class="bg-blue-500 p-2 my-2">
          <div class="text-gray-50 font-medium">
            <%= @topic_card.content %>
          </div>

          <div class="flex justify-between items-end mt-2">
            <%= if @can_edit do %>
              <%= live_component @socket, RetroTaxiWeb.EditButtonComponent, target: @myself, click_event: "start-editing" %>
            <% end %>

            <%= if @board_phase == :vote do %>
              <%= live_component @socket, RetroTaxiWeb.VoteButtonComponent %>
            <% end %>

          </div>
        </div>
        <% end %>
      </div>
    """
  end
end
