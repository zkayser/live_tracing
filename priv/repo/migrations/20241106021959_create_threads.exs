defmodule LiveTracing.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do

      add :title, :string
      timestamps(type: :utc_datetime)
    end
  end
end
