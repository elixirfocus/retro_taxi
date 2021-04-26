defmodule RetroTaxi.Factory do
  @moduledoc """
  Defines a collection of `ExMachina` fixtures that are used in testing.
  """

  use ExMachina.Ecto, repo: RetroTaxi.Repo
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Boards.Column
  alias RetroTaxi.Boards.TopicCard

  def board_factory do
    %Board{
      name: Faker.Lorem.word(),
      columns: [
        build(:column, title: "Start", sort_order: 1),
        build(:column, title: "Stop", sort_order: 2),
        build(:column, title: "Continue", sort_order: 3),
        build(:column, title: "Actions", sort_order: 4)
      ]
    }
  end

  def column_factory do
    %Column{
      title: Faker.Lorem.word(),
      sort_order: System.unique_integer()
    }
  end

  def topic_card_factory do
    %TopicCard{
      content: Faker.Lorem.sentences()
    }
  end
end
