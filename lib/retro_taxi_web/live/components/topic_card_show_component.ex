defmodule RetroTaxiWeb.TopicCardShowComponent do
  use RetroTaxiWeb, :live_component

  def render(assigns) do
    ~L"""
    TopicCard <%= @topic_card.inserted_at %>
    """
  end
end
