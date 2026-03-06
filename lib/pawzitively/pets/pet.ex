defmodule Pawzitively.Pets.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :name, :string
    field :species, :string
    field :breed, :string
    field :date_of_birth, :date
    field :weight, :decimal
    field :medical_notes, :string
    field :notes, :string
    field :spayed_neutered, :boolean, default: false
    field :owner_ids, {:array, :integer}, virtual: true

    many_to_many :owners, Pawzitively.Owners.Owner,
      join_through: "pet_owners",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [
      :name,
      :species,
      :breed,
      :date_of_birth,
      :weight,
      :medical_notes,
      :notes,
      :spayed_neutered,
      :owner_ids
    ])
    |> validate_required([:name, :species])
    |> validate_number(:weight, greater_than: 0)
  end
end
