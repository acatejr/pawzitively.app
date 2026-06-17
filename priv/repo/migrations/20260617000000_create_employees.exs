defmodule Pawzitively.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string
      add :phone, :string
      add :active, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:employees, [:email])
  end
end
