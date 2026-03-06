defmodule Pawzitively.PetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pawzitively.Pets` context.
  """

  @doc """
  Generate a pet.
  """
  def pet_fixture(attrs \\ %{}) do
    owner_ids =
      if attrs[:owner_ids] do
        attrs[:owner_ids]
      else
        owner = Pawzitively.OwnersFixtures.owner_fixture()
        [owner.id]
      end

    {:ok, pet} =
      attrs
      |> Map.delete(:owner_ids)
      |> Enum.into(%{
        name: "Buddy",
        species: "Dog",
        breed: "Golden Retriever",
        date_of_birth: ~D[2020-06-15],
        weight: "30.5",
        spayed_neutered: true,
        owner_ids: owner_ids
      })
      |> Pawzitively.Pets.create_pet()

    pet
  end
end
