defmodule RetroTaxi.Factory do
  @moduledoc """
  Defines a collection of `ExMachina` fixtures that are used in testing.
  """

  use ExMachina.Ecto, repo: RetroTaxi.Repo
  alias RetroTaxi.Boards.Board

  def board_factory do
    %Board{
      name: Faker.Lorem.word()
    }
  end
end
