defmodule Pawzitively.Repo.Migrations.PetOwnersManyToMany do
  use Ecto.Migration

  def change do
    create table(:pet_owners) do
      add :pet_id, references(:pets, on_delete: :delete_all), null: false
      add :owner_id, references(:owners, on_delete: :delete_all), null: false
    end

    create index(:pet_owners, [:pet_id])
    create index(:pet_owners, [:owner_id])
    create unique_index(:pet_owners, [:pet_id, :owner_id])

    alter table(:pets) do
      remove :owner_id
    end
  end
end
