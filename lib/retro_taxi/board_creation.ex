defmodule RetroTaxi.BoardCreation do
  @moduledoc """
  Provides functions for coordinating work related to user task of board creation.
  """

  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.BoardCreation.Request
  alias RetroTaxi.Users
  alias RetroTaxi.Users.User
  alias Ecto.Changeset

  @doc """
  Returns an `%Ecto.Changeset{}` for the given `RetroTaxi.BoardCreation.Request`
  value. Useful for validating input values provided by an end user.
  """
  @spec change_request(Request.t(), map()) :: Ecto.Changeset.t(Request.t())
  def change_request(%Request{} = request, attrs \\ %{}) do
    types = %{
      board_name: :string,
      facilitator_name: :string
    }

    # TODO: Kind of sucks to duplicate validation logic here and the other entities.
    {request, types}
    |> Ecto.Changeset.cast(attrs, Map.keys(types))
    |> Ecto.Changeset.validate_required([:board_name, :facilitator_name])
    |> Ecto.Changeset.validate_length(:board_name, min: 1, max: 255)
    |> Ecto.Changeset.validate_length(:facilitator_name, min: 1, max: 255)
  end

  @doc """
  Given a `RetroTaxi.BoardCreation.Request` and an optional user_id the request
  will be processed and create a new `RetroTaxi.Boards.Board` entity with the
  given name and updates/create the related facilitator `RetroTaxi.Users.User`
  entity's display name which is also setup as the owner of said board.

  If the request is invalid an error tuple with a changeset with be returned.

  If the supplied `user_id` does not reference a known `RetroTaxi.Users.User`
  entity an error tuple of `{:error, :user_not_found}` is returned.
  """
  @spec process_request(Request.t(), Ecto.UUID.t() | nil) ::
          {:ok, Board.t(), User.t()} | {:error, :user_not_found} | {:error, Changeset.t()}
  def process_request(request, user_id) do
    changeset = change_request(request, %{})

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        # FIXME: Should be more forgiving/informative of possible errors here.
        # Maybe wrap in transaction?
        {:ok, board} = Boards.create_board(name: request.board_name)

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
            {:ok, updated_user} = Users.update_user_display_name(user, request.facilitator_name)
            {:ok, board, updated_user}
        end
    end
  end
end
