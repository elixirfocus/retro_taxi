defmodule RetroTaxi.Factory do
  @moduledoc """
  Defines a collection of `ExMachina` fixtures that are used in testing.
  """

  use ExMachina.Ecto, repo: RetroTaxi.Repo

  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Boards.Column
  alias RetroTaxi.Boards.TopicCard
  alias RetroTaxi.JoinBoard.UserIdentityPromptEvent
  alias RetroTaxi.Users.User

  def user_factory do
    %User{
      display_name: Faker.Pokemon.name()
    }
  end

  def board_factory do
    %Board{
      name: Faker.Lorem.word(),
      facilitator: insert(:user),
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
    # FIXME: The use of this factory does not currently match the behaviors
    # built into `create_topic_card/2` making it use questionable.
    %TopicCard{
      content: Faker.Lorem.sentence()
    }
  end

  def user_identity_prompt_event_factory do
    %UserIdentityPromptEvent{
      board: insert(:board),
      user: insert(:user),
      confirmed_at: DateTime.utc_now()
    }
  end
end
