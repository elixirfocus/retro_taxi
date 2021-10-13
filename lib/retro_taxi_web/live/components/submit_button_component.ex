defmodule RetroTaxiWeb.SubmitButtonComponent do
  use RetroTaxiWeb, :live_component

  def render(assigns) do
    ~H"""
    <button
      type="submit"
      class="bg-yellow-300 active:bg-yellow-400 hover:border-white border-transparent border flex items-center px-2 py-1 font-bold text-gray-900">
      <div class="ml-1">
        <%= @title %>
      </div>
    </button>
    """
  end
end
