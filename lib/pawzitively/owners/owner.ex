defmodule Pawzitively.Owners.Owner do
  use Ecto.Schema
  import Ecto.Changeset

  schema "owners" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone, :string
    field :emergency_contact_name, :string
    field :emergency_contact_phone, :string
    field :notes, :string

    has_many :pets, Pawzitively.Pets.Pet

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(owner, attrs) do
    owner
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email,
      :phone,
      :emergency_contact_name,
      :emergency_contact_phone,
      :notes
    ])
    |> validate_required([:first_name, :last_name, :email, :phone])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end
end
