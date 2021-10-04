defmodule RetroTaxi.JoinBoard do
  @moduledoc """
  Functions related to the task of a user joining a board.
  """

  alias Ecto.Changeset
  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.JoinBoard.Request
  alias RetroTaxi.JoinBoard.UserIdentityPromptEvent
  alias RetroTaxi.Repo
  alias RetroTaxi.Users
  alias RetroTaxi.Users.User

  @doc """
  Returns an `%Ecto.Changeset{}` for the given `RetroTaxi.JoinBoard.Request`
  value, useful for validating input.
  """
  @spec change_request(Request.t(), map() | nil) :: Changeset.t(Request.t())
  def change_request(%Request{} = request, attrs \\ %{}) do
    schema = %{
      display_name: :string
    }

    {request, schema}
    |> Changeset.cast(attrs, Map.keys(schema))
    |> Changeset.validate_required([:display_name])
    |> Changeset.validate_length(:display_name, min: 1, max: 255)
  end

  @doc """
  Processes the join board request, creating or updating a
  `RetroTaxi.Users.User` (depending on the `user_id` passed in) and their
  `display_name`. Additionally records a `UserIdentityPromptEvent` as a record
  that the user has already been through the join prompt.

  If the request is invalid an {:error, changeset}` tuple will be returned.

  The incoming `user_id` is expected to be nil or match an existing stored
  entity. If an invalid id is passed in an `MatchError` will be thrown.
  """
  @spec process_request(Request.t(), User.id() | nil, Board.id()) ::
          {:ok, User.t(), UserIdentityPromptEvent.t()}
          | {:error, Changeset.t(Request.t())}
  def process_request(request, user_id, board_id) do
    changeset = change_request(request, %{})

    case changeset.valid? do
      false ->
        {:error, %{changeset | action: :insert}}

      true ->
        {:ok, {user, event}} =
          Repo.transaction(fn ->
            {:ok, updated_user} = upsert_user(user_id, request.display_name)
            {:ok, event} = create_user_identity_prompt_event(updated_user.id, board_id)
            {updated_user, event}
          end)

        {:ok, user, event}
    end
  end

  # Creates or updates a `RetroTaxi.Users.User` entity given a `user_id` value,
  # which can be nil, with the given `display_name`.
  defp upsert_user(nil, new_display_name) do
    {:ok, new_user} = Users.register_user()
    Users.upsert_user_display_name(new_user, new_display_name)
  end

  defp upsert_user(user_id, new_display_name) do
    case Users.get_user(user_id) do
      nil ->
        {:error, :user_not_found}

      user ->
        Users.upsert_user_display_name(user, new_display_name)
    end
  end

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
