defmodule RetroTaxi.BoardCreation do
  @moduledoc """
  Provides functions for coordinating work related to user task of board creation.
  """

  alias Ecto.Changeset
  alias RetroTaxi.BoardCreation.Request
  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Users
  alias RetroTaxi.Users.User
  alias RetroTaxi.JoinBoard

  @doc """
  Returns an `%Ecto.Changeset{}` for the given `RetroTaxi.BoardCreation.Request`
  value. Useful for validating input.
  """
  @spec change_request(Request.t(), map()) :: Changeset.t(Request.t())
  def change_request(%Request{} = request, attrs \\ %{}) do
    types = %{
      board_name: :string,
      facilitator_name: :string
    }

    # FIXME: Kind of sucks to duplicate validation logic here but ok for now.
    {request, types}
    |> Changeset.cast(attrs, Map.keys(types))
    |> Changeset.validate_required([:board_name, :facilitator_name])
    |> Changeset.validate_length(:board_name, min: 1, max: 255)
    |> Changeset.validate_length(:facilitator_name, min: 1, max: 255)
  end

  @doc """
  Given a `RetroTaxi.BoardCreation.Request` and an optional `user_id` this
  function will proceeds the request and create a new `RetroTaxi.Boards.Board`
  entity with the given name and updates (or create) the related facilitator
  `RetroTaxi.Users.User` entity with the expected display name. This user entity
  will also be assigned as the facilitator of the new board.

  If the request is invalid an {:error, changeset}` tuple will be returned.

  If the supplied `user_id` does not reference a known `RetroTaxi.Users.User`
  entity an error tuple of `{:error, :user_not_found}` is returned.
  """
  @spec process_request(Request.t(), User.id() | nil) ::
          {:ok, Board.t(), User.t()}
          | {:error, :user_not_found}
          | {:error, Changeset.t(Request.t())}
  def process_request(request, user_id) do
    # FIXME: This function would benefit wrapping the multiple persistance changes in a transaction.
    changeset = change_request(request, %{})

    case changeset.valid? do
      false ->
        # We need to force an action value so the Phoenix forms will display the errors.
        {:error, %{changeset | action: :insert}}

      true ->
        user =
          case user_id do
            nil ->
              {:ok, new_user} = Users.register_user()
              new_user

            non_nil_user_id ->
              Users.get_user(non_nil_user_id)
          end

        case user do
          nil ->
            {:error, :user_not_found}

          user ->
            {:ok, board} = Boards.create_board(request.board_name, user.id)
            {:ok, updated_user} = Users.update_user_display_name(user, request.facilitator_name)
            {:ok, _event} = JoinBoard.create_user_identity_prompt_event(updated_user.id, board.id)
            {:ok, board, updated_user}
        end
    end
  end
end
