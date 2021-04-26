defmodule RetroTaxi.Boards do
  @moduledoc """
  Provides functions related to managing `RetroTaxi.Boards.Board` entities.
  """

  import Ecto.Changeset

  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Boards.TopicCard
  alias RetroTaxi.Repo

  @doc """
  Creates a `RetroTaxi.Boards.Board` entity with the given name and default columns.

  Returns `{:ok, board}` if the entity has been successfully inserted or
  `{:error, changeset}` if there was a validation or constraint error.
  """
  @spec create_board(name: String.t()) :: {:ok, Board.t()} | {:error, Ecto.Changeset.t()}
  def create_board(name: name) do
    %Board{}
    |> change_board(%{name: name})
    |> Ecto.Changeset.put_assoc(:columns, default_columns())
    |> Repo.insert()
  end

  @doc """
  Fetches a single `RetroTaxi.Boards.Board` entity from the repo where the
  primary key matches the given id.

  Raises `Ecto.NoResultsError` if no entity was found.
  """
  @spec get_board!(integer()) :: Board.t()
  def get_board!(id) do
    Repo.get!(Board, id)
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

  def create_topic_card(content: content, column_id: column_id) do
    %TopicCard{}
    |> change_topic_card(%{content: content, column_id: column_id})
    |> Repo.insert()
  end

  @spec change_topic_card(%TopicCard{}, map()) :: Ecto.Changeset.t()
  def change_topic_card(%TopicCard{} = topic_card, attrs \\ %{}) do
    topic_card
    |> cast(attrs, [:content, :column_id])
    |> validate_required([:content, :column_id])
  end

  defp default_columns() do
    [
      %{title: "Start", sort_order: 1},
      %{title: "Stop", sort_order: 2},
      %{title: "Continue", sort_order: 3},
      %{title: "Actions", sort_order: 4}
    ]
  end
end
