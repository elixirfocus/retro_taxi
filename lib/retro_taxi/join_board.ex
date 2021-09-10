defmodule RetroTaxi.JoinBoard do
  @moduledoc """
  Functions related to the task of a user joining a board.
  """

  alias Ecto.Changeset
  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.JoinBoard.UserIdentityPromptEvent
  alias RetroTaxi.Repo
  alias RetroTaxi.Users.User

  @doc """
  Given a `RetroTaxi.Boards.Board` id and a `RetroTaxi.Users.User` id, returns a
  boolean indicating if a user should be prompted to confirm their identity and
  agree to join the board.

  This prompt should only be presented to a user once per board, hence why we
  check and persist their confirmation with a
  `RetroTaxi.JoinBoard.UserIdentityPromptEvent` entity.
  """
  @spec should_prompt_user_for_identity_confirmation?(User.id(), Board.id()) :: boolean()
  def should_prompt_user_for_identity_confirmation?(user_id, board_id) do
    case Boards.fetch_board(board_id) do
      :not_found ->
        :board_not_found

      {:ok, board} ->
        user_id == nil || get_user_identity_prompt_event(user_id, board.id) == nil
    end
  end

  @doc """
  Returns a `RetroTaxi.JoinBoard.UserIdentityPromptEvent` entity for the given
  `RetroTaxi.Users.User` id and `RetroTaxi.Boards.Board` id.
  """
  @spec get_user_identity_prompt_event(User.id(), Board.id()) :: UserIdentityPromptEvent.t() | nil
  def get_user_identity_prompt_event(user_id, board_id) do
    Repo.get_by(UserIdentityPromptEvent, user_id: user_id, board_id: board_id)
  end

  @doc """
  Creates a `RetroTaxi.JoinBoard.UserIdentityPromptEvent` entity with the given
  `RetroTaxi.Users.User` id and `RetroTaxi.Boards.Board` id.

  Returns `{:ok, board}` when the entity has been successfully created or
  `{:error, changeset}` if their was a failure.
  """
  @spec create_user_identity_prompt_event(User.id(), Board.id(), DateTime.t() | nil) ::
          {:ok, UserIdentityPromptEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_user_identity_prompt_event(user_id, board_id, confirmed_at \\ nil) do
    confirmed_at = confirmed_at || DateTime.utc_now()

    %UserIdentityPromptEvent{}
    |> change_user_identity_prompt_event(%{
      user_id: user_id,
      board_id: board_id,
      confirmed_at: confirmed_at
    })
    |> Repo.insert()
  end

  @doc """
  Returns an `Ecto.Changeset` to track changes for the passed in
  `RetroTaxi.JoinBoard.UserIdentityPromptEvent` and accompanying map of attributes.
  """
  @spec change_user_identity_prompt_event(%UserIdentityPromptEvent{}, map()) :: Changeset.t()
  def change_user_identity_prompt_event(%UserIdentityPromptEvent{} = event, attrs \\ %{}) do
    fields = [:user_id, :board_id, :confirmed_at]

    event
    |> Changeset.cast(attrs, fields)
    |> Changeset.validate_required(fields)
  end
end
