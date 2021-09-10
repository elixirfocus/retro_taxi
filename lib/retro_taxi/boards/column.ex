defmodule RetroTaxi.Boards.Column do
  @moduledoc """
  An Ecto-based schema that defines the attributes of a `Column`.

  A `RetroTaxi.Boards.Board` contains an ordered collection of
  `RetroTaxi.Boards.Column` entities. A `RetroTaxi.Boards.Column` contains an
  ordered collection of `RetroTaxi.Boards.TopicCard` entities.

  `RetroTaxi.Boards.Column` entities are titled collections of ordered `RetroTaxi.Boards.TopicCard` entities.
  """

  use Ecto.Schema

  alias RetroTaxi.Boards.Board

  @type id :: integer()

  @typedoc """
  TODO
  """
  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          board: Board.t(),
          id: id(),
          inserted_at: DateTime.t(),
          sort_order: integer(),
          title: String.t(),
          updated_at: DateTime.t()
        }

  schema "columns" do
    field :sort_order, :integer
    field :title, :string

    belongs_to :board, RetroTaxi.Boards.Board

    has_many :topic_cards, RetroTaxi.Boards.TopicCard

    timestamps(type: :utc_datetime)
  end
end
