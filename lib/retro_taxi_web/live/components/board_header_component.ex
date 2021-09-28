defmodule RetroTaxiWeb.BoardHeaderComponent do
  use RetroTaxiWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="lg:grid lg:grid-cols-2 lg:gap-4 mb-4">

      <div class="mb-4">
        <h1 class="text-3xl font-bold" id="board-name">
          <%= @board.name %>
        </h1>
        <p>Facilitator: <%= @board.facilitator.display_name %></p>
      </div>

      <div class="lg:text-right">
       <%= for user <- @users do %>
          <div class="inline-flex items-center px-3 py-2 rounded-full   text-sm font-medium bg-gray-300 text-gray-800 mb-2">
            <%= user.display_name %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
