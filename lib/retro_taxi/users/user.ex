defmodule RetroTaxi.Users.User do
  @moduledoc """
  An Ecto-based schema that defines the attributes of a `User`.

  A `RetroTaxi.Users.User` will store the persisted attributes relative to a
  user of the application, such as display name.
  """

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  @type id :: Ecto.UUID.t()

  @typedoc """
  TODO
  """
  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: id(),
          inserted_at: DateTime.t(),
          # FIXME: Should we do `display_name` or just `name`?
          display_name: String.t(),
          updated_at: DateTime.t()
        }

  schema "users" do
    field :display_name, :string

    timestamps()
  end
end
