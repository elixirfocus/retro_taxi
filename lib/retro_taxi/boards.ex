defmodule RetroTaxi.Boards do
  @moduledoc """
  Provides functions related to managing `RetroTaxi.Boards.Board` entities and
  their internal contents.
  """

  import Ecto.Changeset
  import Ecto.Query

  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Boards.BoardCreationRequest
  alias RetroTaxi.Boards.Column
  alias RetroTaxi.Boards.TopicCard
  alias RetroTaxi.Repo

  @doc """
  Creates a `RetroTaxi.Boards.Board` entity with the given name and default columns.

  Returns `{:ok, board}` when the entity has been successfully created or
  `{:error, changeset}` if their was a failure.
  """
  @spec create_board(name: String.t()) :: {:ok, Board.t()} | {:error, Ecto.Changeset.t()}
  def create_board(name: name) do
    %Board{}
    |> change_board(%{name: name})
    |> Ecto.Changeset.put_assoc(:columns, default_columns())
    |> Repo.insert()
  end

  @doc """
  Creates the requested `RetroTaxi.Boards.Board` entity and updates/creates the related facilitator `RetroTaxi.Users.User` entity which has admin control over said board.

  If the request is invalid or there is an internal problem applying the request a changeset with the related errors will be returned.
  """
  @spec process_board_creation_request(BoardCreationRequest.t()) ::
          {:ok, Board.t(), User.t()} | {:error, String.t()}
  def process_board_creation_request(request) do
    # sanity check that the request is valid
    case change_board_creation_request(request).valid? do
      false ->
        {:error, "given request was not valid"}

      true ->
        # FIXME: Should be more forgiving/informative of possible errors here. Maybe wrap in transaction?
        {:ok, board} = create_board(request.board_name)
        user = Users.get_user(request.facilitator_id)
        {:ok, updated_user} = Users.update_user_display_name(user, request.facilitator_name)

        {:ok, board, updated_user}
    end
  end

  def change_board_creation_request(%BoardCreationRequest{} = request, attrs \\ %{}) do
    types = %{
      board_name: :string,
      facilitator_name: :string,
      facilitator_id: :uuid
    }

    required = [:board_name, :facilitator_name, :facilitator_id]

    # TODO: Kind of sucks to duplicate validation logic here and the other entities.

    changeset =
      {request, types}
      |> Ecto.Changeset.cast(attrs, Map.keys(types))
      |> Ecto.Changeset.validate_required(required)
      |> Ecto.Changeset.validate_length(:board_name, min: 1, max: 255)
      |> Ecto.Changeset.validate_length(:facilitator_name, min: 1, max: 255)
  end

  @doc """
  Fetches a single `RetroTaxi.Boards.Board` entity from the repo where the
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
  Returns an `Ecto.Changeset` to track changes for the passed in
  `RetroTaxi.Boards.Board` and accompanying map of attributes.
  """
  @spec change_board(%Board{}, map()) :: Ecto.Changeset.t()
  def change_board(%Board{} = board, attrs \\ %{}) do
    board
    |> cast(attrs, [:name])
    |> validate_required([:name])
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
  defp default_columns() do
    [
      %{title: "Start", sort_order: 1},
      %{title: "Stop", sort_order: 2},
      %{title: "Continue", sort_order: 3},
      %{title: "Actions", sort_order: 4}
    ]
  end
end
