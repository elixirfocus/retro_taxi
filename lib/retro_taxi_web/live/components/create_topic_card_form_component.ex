defmodule RetroTaxiWeb.CreateTopicCardFormComponent do
  use RetroTaxiWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-yellow-100 p-0 my-2">

      <form>
        <textarea
          class="text-gray-900 mt-1 p-2 block w-full rounded-md bg-transparent border-transparent focus:border-transparent focus:ring-0 ring-0"
          rows="3"></textarea>
      </form>

      <div class="flex justify-between items-end mt-2 p-2">
        <button class="w-6 h-6">
          <svg xmlns="http://www.w3.org/2000/svg" class="text-gray-700 hover:text-gray-800" fill="none"
            viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
        <button
          class="bg-yellow-300 active:bg-yellow-400 hover:border-white border-transparent border flex items-center px-2 py-1 font-bold text-gray-900">
          <div class="ml-1">
            Add Card
          </div>
        </button>
      </div>

    </div>
    """
  end
end
