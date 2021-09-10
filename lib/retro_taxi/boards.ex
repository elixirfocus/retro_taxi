defmodule RetroTaxi.Boards do
  @moduledoc """
  Provides functions related to managing `RetroTaxi.Boards.Board` entities and
  their internal contents.
  """

  import Ecto.Changeset
  import Ecto.Query

  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Boards.Column
  alias RetroTaxi.Boards.TopicCard
  alias RetroTaxi.Repo
  alias RetroTaxi.Users.User

  @doc """
  Creates a `RetroTaxi.Boards.Board` entity with the given name and default columns.

  Returns `{:ok, board}` when the entity has been successfully created or
  `{:error, changeset}` if their was a failure.
  """
  @spec create_board(String.t(), User.id()) :: {:ok, Board.t()} | {:error, Ecto.Changeset.t()}
  def create_board(name, facilitator_id) do
    %Board{}
    |> change_board(%{name: name, facilitator_id: facilitator_id})
    |> Ecto.Changeset.put_assoc(:columns, default_columns())
    |> Repo.insert()
  end

  @doc """
  Returns a single `RetroTaxi.Boards.Board` entity from the repo where the
  primary key matches the given id.

  Raises `Ecto.NoResultsError` if no entity was found.

  ## Examples

    iex> board = RetroTaxi.Boards.get_board!(1, [:columns])
  """
  @spec get_board!(integer(), keyword() | nil) :: Board.t()
  def get_board!(id, preloads \\ []) do
    Board
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Fetches a single `RetroTaxi.Boards.Board` entity from the repo where the
  primary key matches the given id.

  Returns `:not_found` if entity is not present in Repo.

  ## Examples

    iex> {:ok, board} = RetroTaxi.Boards.fetch_board(1, [:columns])
  """
  @spec fetch_board(integer(), keyword() | nil) :: {:ok, Board.t()} | :not_found
  def fetch_board(id, preloads \\ []) do
    case Repo.get(Board, id) do
      nil -> :not_found
      board -> {:ok, Repo.preload(board, preloads)}
    end
  end

  @doc """
  Returns an `Ecto.Changeset` to track changes for the passed in
  `RetroTaxi.Boards.Board` and accompanying map of attributes.
  """
  @spec change_board(%Board{}, map()) :: Ecto.Changeset.t()
  def change_board(%Board{} = board, attrs \\ %{}) do
    board
    |> cast(attrs, [:name, :facilitator_id])
    |> validate_required([:name, :facilitator_id])
  end

  @doc """
  Creates a `RetroTaxi.Boards.TopicCard` entity with for the given column the
  given content.

  The new topic card will have a `sort_order` value of 1 more than the
  `count_topic_cards` given the `column_id` at the time of creation.

  Returns `{:ok, topic_card}` when the entity has been successfully created or
  `{:error, changeset}` if their was a failure.
  """
  @spec create_topic_card(content: String.t(), column_id: Column.id()) ::
          {:ok, TopicCard.t()} | {:error, Ecto.Changeset.t()}
  def create_topic_card(content: content, column_id: column_id) do
    sort_order_value = count_topic_cards(column_id: column_id) + 1

    topic_card_attr = %{
      content: content,
      column_id: column_id,
      sort_order: sort_order_value
    }

    %TopicCard{}
    |> change_topic_card(topic_card_attr)
    |> Repo.insert()
  end

  def update_topic_card(topic_card, attrs) do
    topic_card
    |> change_topic_card(attrs)
    |> Repo.update()
  end

  def delete_topic_card(topic_card) do
    Repo.delete(topic_card)
  end

  @doc """
  Returns an `Ecto.Changeset` for tracking changes for the passed in
  `RetroTaxis.Boards.TopicCard` struct or entity.
  """
  @spec change_topic_card(%TopicCard{}, map()) :: Ecto.Changeset.t()
  def change_topic_card(%TopicCard{} = topic_card, attrs \\ %{}) do
    topic_card
    |> cast(attrs, [:content, :column_id, :sort_order])
    |> validate_required([:content, :column_id, :sort_order])
  end

  @doc """
  Returns a list of `RetroTaxis.Boards.TopicCard` entities for the given column id.
  """
  @spec list_topic_cards(column_id: Column.id()) :: list(TopicCard.t())
  def list_topic_cards(column_id: column_id) do
    Repo.all(query_topic_cards_for_column_id(column_id))
  end

  @doc """
  Returns the count of `RetroTaxis.Boards.TopicCard` entities for the given column id.
  """
  @spec count_topic_cards(column_id: Column.id()) :: non_neg_integer()
  def count_topic_cards(column_id: column_id) do
    Repo.aggregate(query_topic_cards_for_column_id(column_id), :count)
  end

  @spec query_topic_cards_for_column_id(Column.id()) :: Ecto.Query.t()
  defp query_topic_cards_for_column_id(column_id) do
    from tc in TopicCard, where: tc.column_id == ^column_id, order_by: tc.sort_order
  end

  @spec default_columns() :: list(%{title: String.t(), sort_order: non_neg_integer()})
  defp default_columns do
    [
      %{title: "Start", sort_order: 1},
      %{title: "Stop", sort_order: 2},
      %{title: "Continue", sort_order: 3},
      %{title: "Actions", sort_order: 4}
    ]
  end
end
