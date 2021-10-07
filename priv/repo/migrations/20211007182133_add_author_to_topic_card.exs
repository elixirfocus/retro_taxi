defmodule RetroTaxi.Repo.Migrations.AddAuthorToTopicCard do
  use Ecto.Migration

  def change do
    alter table("topic_cards") do
      add :author_id, references(:users, type: :uuid, on_delete: :nothing)
    end

    create(index(:topic_cards, :author_id))
  end
end
