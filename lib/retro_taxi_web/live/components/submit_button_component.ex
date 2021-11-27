defmodule RetroTaxiWeb.SubmitButtonComponent do
  use Phoenix.Component

  def submit_button(assigns) do
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
