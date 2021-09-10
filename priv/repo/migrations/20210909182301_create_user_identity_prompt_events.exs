defmodule RetroTaxi.Repo.Migrations.CreateUserIdentityPromptEvents do
  use Ecto.Migration

  def change do
    create table(:user_identity_prompt_events, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
      add :board_id, references(:boards)
      add(:confirmed_at, :timestamptz)

      timestamps(type: :timestamptz)
    end

    create(index(:user_identity_prompt_events, :user_id))
    create(index(:user_identity_prompt_events, :board_id))
    create(unique_index(:user_identity_prompt_events, [:user_id, :board_id], name: :user_id_board_id_unique_index))
  end
end
