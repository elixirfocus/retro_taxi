defmodule RetroTaxi.Boards.Board do
  @moduledoc """
  An Ecto-based schema that defines the attributes of a `Board`.

  A `RetroTaxi.Boards.Board` will house the contents of a retrospective meeting.
  """

  use Ecto.Schema

  alias RetroTaxi.Boards.Column

  @typedoc """
  TODO
  """
  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          columns: [Column.t()],
          id: integer(),
          inserted_at: DateTime.t(),
          name: String.t(),
          updated_at: DateTime.t()
        }

  schema "boards" do
    field :name, :string

    has_many :columns, Column

    timestamps()
  end
end
