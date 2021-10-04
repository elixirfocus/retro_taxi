defmodule RetroTaxiWeb.PhaseDisplayComponent do
  use RetroTaxiWeb, :live_component

  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board

  @impl true
  def handle_event("start_voting_phase", _, socket) do
    %Board{phase: :capture} = board = socket.assigns.board
    {:ok, updated_board} = Boards.update_board_phase(board)
    {:noreply, assign(socket, board: updated_board)}
  end

  def handle_event("start_discussion_phase", _, socket) do
    %Board{phase: :vote} = board = socket.assigns.board
    {:ok, updated_board} = Boards.update_board_phase(board)
    {:noreply, assign(socket, board: updated_board)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <section class="prose mb-4">

      <%= if @board.phase == :capture do %>
        <p>We are currently capturing our observations. Please compose topics for things you feel the team should <strong>Start Doing</strong>, <strong>Stop Doing</strong> or <strong>Continue to Do</strong>.</p>

        <%= if @show_facilitator_tools do %>
          <p>Facilitator: When you have confirmation people are done composing topics, move the board into the Voting phase.</p>

          <div>
            <button phx-click="start_voting_phase" phx-target="<%= @myself %>"
            class="bg-green-600 active:bg-green-700 hover:border-white border-transparent border flex items-center px-2 py-1 font-bold text-gray-100">
              <div class="ml-1">
                Start Voting Phase
              </div>
            </button>
          </div>
        <% end %>

      <% end %>

      <%= if @board.phase == :vote do %>
        <p>We are currently voting for which items we want to discuss. Each person gets six (6) votes but need not use every one.</p>

        <%= if @show_facilitator_tools do %>
          <p>Facilitator: When people are done voting, enter the discussion phase.</p>

          <div>
            <button phx-click="start_discussion_phase" phx-target="<%= @myself %>"
            class="bg-green-600 active:bg-green-700 hover:border-white border-transparent border flex items-center px-2 py-1 font-bold text-gray-100">
              <div class="ml-1">
                Start Discussion Phase
              </div>
            </button>
          </div>
        <% end %>
      <% end %>

      <%= if @board.phase == :discuss do %>
        <p>We are currently discussing topics. As action items for the team surface, please add them to the Actions column.</p>
      <% end %>

    </section>
    """
  end
end
