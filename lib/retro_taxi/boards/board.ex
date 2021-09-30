defmodule RetroTaxi.Boards.Board do
  @moduledoc """
  An Ecto-based schema that defines the attributes of a `Board`.

  A `RetroTaxi.Boards.Board` will house the contents of a retrospective meeting.
  """

  use Ecto.Schema

  alias RetroTaxi.Boards.Column
  alias RetroTaxi.Users.User

  @type id :: integer()

  @typedoc """
  TODO
  """
  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          columns: [Column.t()],
          id: id(),
          facilitator_id: User.id(),
          inserted_at: DateTime.t(),
          name: String.t(),
          phase: :capture | :vote | :discuss,
          updated_at: DateTime.t()
        }

  schema "boards" do
    field :name, :string
    field :phase, Ecto.Enum, values: [:capture, :vote, :discuss], default: :capture

    belongs_to :facilitator, User, type: :binary_id
    has_many :columns, Column
    timestamps(type: :utc_datetime)
  end
end
