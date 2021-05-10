defmodule RetroTaxi.Boards.TopicCard do
  @moduledoc """
  An Ecto-based schema that defines the attributes of a `TopicCard`.

  A `RetroTaxi.Boards.Board` contains an ordered collection of
  `RetroTaxi.Boards.Column` entities. A `RetroTaxi.Boards.Column` contains an
  ordered collection of ``RetroTaxi.Boards.TopicCars` entities.

  `RetroTaxi.Boards.TopicCard` entities contain the content members of the
  retrospective are sharing with their participating team members.
  """

  use Ecto.Schema

  alias RetroTaxi.Boards.Column

  @type id :: integer()

  @typedoc """
  TODO
  """
  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          content: String.t(),
          id: id(),
          inserted_at: DateTime.t(),
          sort_order: integer(),
          updated_at: DateTime.t()
        }

  schema "topic_cards" do
    field :content, :string
    field :sort_order, :integer

    belongs_to :column, Column

    timestamps()
  end
end
