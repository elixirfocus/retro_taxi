defmodule RetroTaxiWeb.CloseButtonComponent do
  use RetroTaxiWeb, :live_component

  def render(assigns) do
    ~L"""
    <button type="button" data-confirm="Are you sure you want to cancel?" class="w-6 h-6" phx-click="<%= @click_event %>" phx-target=<%= @target %>>
      <svg xmlns="http://www.w3.org/2000/svg" class="text-gray-700 hover:text-gray-800" fill="none"
        viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>
    </button>
    """
  end
end
