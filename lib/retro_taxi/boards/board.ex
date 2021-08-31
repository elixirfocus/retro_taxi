defmodule RetroTaxi.Boards.Board do
  @moduledoc """
  An Ecto-based schema that defines the attributes of a `Board`.

  A `RetroTaxi.Boards.Board` will house the contents of a retrospective meeting.
  """

  use Ecto.Schema

  alias RetroTaxi.Users.User
  alias RetroTaxi.Boards.Column

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
          updated_at: DateTime.t()
        }

  schema "boards" do
    field :name, :string
    belongs_to :facilitator, User, type: :binary_id
    has_many :columns, Column
    timestamps()
  end
end
