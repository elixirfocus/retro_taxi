defmodule RetroTaxi.Repo.Migrations.CreateColumns do
  use Ecto.Migration

  def change do
    create table(:columns) do
      add :title, :string
      add :sort_order, :integer
      add :board_id, references(:boards)

      timestamps(type: :timestamptz)
    end
  end
end
