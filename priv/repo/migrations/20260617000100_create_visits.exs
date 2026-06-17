defmodule Pawzitively.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :pet_id, references(:pets, on_delete: :delete_all), null: false

      add :checked_in_at, :utc_datetime, null: false
      add :checked_out_at, :utc_datetime

      add :checked_in_by_owner_id, references(:owners, on_delete: :restrict), null: false
      add :checked_out_by_owner_id, references(:owners, on_delete: :restrict)

      add :checked_in_by_employee_id, references(:employees, on_delete: :restrict), null: false
      add :checked_out_by_employee_id, references(:employees, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create index(:visits, [:pet_id])
    create index(:visits, [:checked_in_by_owner_id])
    create index(:visits, [:checked_out_by_owner_id])
    create index(:visits, [:checked_in_by_employee_id])
    create index(:visits, [:checked_out_by_employee_id])

    # A pet can only have one open (not-yet-checked-out) visit at a time.
    create unique_index(:visits, [:pet_id],
             where: "checked_out_at IS NULL",
             name: :visits_active_pet_index
           )
  end
end
