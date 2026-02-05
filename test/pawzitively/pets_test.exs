defmodule Pawzitively.PetsTest do
  use Pawzitively.DataCase

  alias Pawzitively.Pets

  describe "pets" do
    alias Pawzitively.Pets.Pet

    import Pawzitively.PetsFixtures
    import Pawzitively.OwnersFixtures

    @invalid_attrs %{
      name: nil,
      species: nil,
      breed: nil,
      date_of_birth: nil,
      weight: nil,
      medical_notes: nil,
      notes: nil,
      spayed_neutered: nil
    }

    test "list_pets/0 returns all pets" do
      pet = pet_fixture()
      [listed_pet] = Pets.list_pets()
      assert listed_pet.id == pet.id
      assert listed_pet.name == pet.name
    end

    test "get_pet!/1 returns the pet with given id" do
      pet = pet_fixture()
      fetched_pet = Pets.get_pet!(pet.id)
      assert fetched_pet.id == pet.id
      assert fetched_pet.name == pet.name
      assert fetched_pet.owner != nil
    end

    test "create_pet/1 with valid data creates a pet" do
      owner = owner_fixture()

      valid_attrs = %{
        name: "Rex",
        species: "Dog",
        breed: "Labrador",
        date_of_birth: ~D[2020-01-01],
        weight: "25.0",
        medical_notes: "none",
        notes: "friendly",
        spayed_neutered: true,
        owner_id: owner.id
      }

      assert {:ok, %Pet{} = pet} = Pets.create_pet(valid_attrs)
      assert pet.name == "Rex"
      assert pet.species == "Dog"
      assert pet.breed == "Labrador"
      assert pet.date_of_birth == ~D[2020-01-01]
      assert pet.weight == Decimal.new("25.0")
      assert pet.medical_notes == "none"
      assert pet.notes == "friendly"
      assert pet.spayed_neutered == true
      assert pet.owner_id == owner.id
    end

    test "create_pet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pets.create_pet(@invalid_attrs)
    end

    test "update_pet/2 with valid data updates the pet" do
      pet = pet_fixture()
      update_attrs = %{name: "Updated Name", species: "Cat", breed: "Siamese"}

      assert {:ok, %Pet{} = pet} = Pets.update_pet(pet, update_attrs)
      assert pet.name == "Updated Name"
      assert pet.species == "Cat"
      assert pet.breed == "Siamese"
    end

    test "update_pet/2 with invalid data returns error changeset" do
      pet = pet_fixture()
      assert {:error, %Ecto.Changeset{}} = Pets.update_pet(pet, @invalid_attrs)
      fetched_pet = Pets.get_pet!(pet.id)
      assert fetched_pet.name == pet.name
    end

    test "delete_pet/1 deletes the pet" do
      pet = pet_fixture()
      assert {:ok, %Pet{}} = Pets.delete_pet(pet)
      assert_raise Ecto.NoResultsError, fn -> Pets.get_pet!(pet.id) end
    end

    test "change_pet/1 returns a pet changeset" do
      pet = pet_fixture()
      assert %Ecto.Changeset{} = Pets.change_pet(pet)
    end
  end
end
