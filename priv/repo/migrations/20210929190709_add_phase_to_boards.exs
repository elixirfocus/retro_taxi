defmodule RetroTaxi.Repo.Migrations.AddPhaseToBoards do
  use Ecto.Migration

  def change do
    alter table("boards") do
      add :phase, :string, null: false, default: "capture"
    end
  end
end
