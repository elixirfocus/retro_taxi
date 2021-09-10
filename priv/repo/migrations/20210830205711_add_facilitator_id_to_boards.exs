defmodule RetroTaxi.Repo.Migrations.AddFacilitatorIdToBoards do
  use Ecto.Migration

  def change do
    alter table("boards") do
      add :facilitator_id, references(:users, type: :uuid, on_delete: :nothing)
    end

    create(index(:boards, :facilitator_id))
  end
end
