defmodule RetroTaxiWeb.EditButtonComponent do
  use Phoenix.Component

  def edit_button(assigns) do
    ~H"""
    <button class="w-6 h-6" phx-click={@click_event} phx-target={@target}>
      <svg class="text-gray-300 hover:text-gray-200" xmlns="http://www.w3.org/2000/svg" fill="none"
            viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
      </svg>
    </button>
    """
  end
end
