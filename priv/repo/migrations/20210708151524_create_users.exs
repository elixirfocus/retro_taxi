defmodule RetroTaxi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :display_name, :string

      timestamps()
    end
  end
end
