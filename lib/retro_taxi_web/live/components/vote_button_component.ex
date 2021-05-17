defmodule RetroTaxiWeb.VoteButtonComponent do
  use RetroTaxiWeb, :live_component

  def render(assigns) do
    ~L"""
    <button
      class="bg-blue-400 active:bg-blue-500 hover:border-white border-transparent border flex items-center px-2 py-1 font-bold text-gray-100">
      <svg class="w-8 h-8" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <div class="ml-1">
        VOTE
      </div>
    </button>
    """
  end
end
