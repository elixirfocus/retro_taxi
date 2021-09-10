defmodule RetroTaxi.JoinBoard.UserIdentityPromptEvent do
  @moduledoc """
  A persisted entity that helps keep track if a user was presented with and
  agreed to an identity confirmation prompt before joining a board.
  """

  use Ecto.Schema

  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}

  @type id :: Ecto.UUID.t()

  @typedoc """
  TODO
  """
  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          board_id: Board.id(),
          confirmed_at: DateTime.t(),
          id: id(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          user_id: User.id()
        }

  schema "user_identity_prompt_events" do
    field :confirmed_at, :utc_datetime

    belongs_to :user, User, type: :binary_id
    belongs_to :board, Board

    timestamps(type: :utc_datetime)
  end
end
