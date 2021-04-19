defmodule RetroTaxi.Boards.Board do
  @moduledoc """
  An Ecto-based schema that defines the attributes of a `Board` which will house
  the contents of a retrospective meeting.
  """

  use Ecto.Schema

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer(),
          inserted_at: DateTime.t(),
          name: String.t(),
          updated_at: DateTime.t()
        }

  schema "boards" do
    field :name, :string

    timestamps()
  end
end
