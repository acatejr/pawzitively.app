defmodule Pawzitively.Repo.Migrations.CreatePets do
  use Ecto.Migration

  def change do
    create table(:pets) do
      add :name, :string, null: false
      add :species, :string, null: false
      add :breed, :string
      add :date_of_birth, :date
      add :weight, :decimal
      add :medical_notes, :text
      add :notes, :text
      add :spayed_neutered, :boolean, default: false, null: false
      add :owner_id, references(:owners, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:pets, [:owner_id])
  end
end
