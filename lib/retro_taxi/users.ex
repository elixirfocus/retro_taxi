defmodule RetroTaxi.Users do
  @moduledoc """
  TODO
  """

  import Ecto.Changeset

  alias RetroTaxi.Repo
  alias RetroTaxi.Users.User

  @doc """
  Registers a new `RetroTaxi.Users.User` entity.
  """
  def register_user() do
    # creates the new entity and returns it.
    # a user has a display name, and out of the box it should be a random
    # the entity's id will be a UUID so we can use that in the cookie
    %User{}
    |> change_user(%{display_name: Faker.Superhero.name()})
    |> Repo.insert()
  end

  @doc """
  Returns a `RetroTaxi.Users.User` entity for the given `id` value.

  Returns `nil` if no entity could be found.
  """
  def get_user(id) do
    Repo.get(User, id)
  end

  def update_user_display_name(user, new_display_name) do
    user
    |> change_user(%{display_name: new_display_name})
    |> Repo.update()
  end

  @doc """
  Returns an `Ecto.Changeset` to track changes for the passed in
  `RetroTaxi.Users.User` and accompanying map of attributes.
  """
  @spec change_user(%User{}, map()) :: Ecto.Changeset.t()
  def change_user(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [:display_name])
    |> validate_required([:display_name])
  end
end