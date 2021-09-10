defmodule RetroTaxi.Repo.Migrations.CreateTopicCards do
  use Ecto.Migration

  def change do
    create table(:topic_cards) do
      add :content, :string
      add :sort_order, :integer
      add :column_id, references(:columns)

      timestamps(type: :timestamptz)

    end
    create(index(:topic_cards, :column_id))
  end
end
