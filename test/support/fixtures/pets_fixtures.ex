defmodule Pawzitively.PetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pawzitively.Pets` context.
  """

  @doc """
  Generate a pet.
  """
  def pet_fixture(attrs \\ %{}) do
    owner =
      if attrs[:owner_id] do
        nil
      else
        Pawzitively.OwnersFixtures.owner_fixture()
      end

    {:ok, pet} =
      attrs
      |> Enum.into(%{
        name: "Buddy",
        species: "Dog",
        breed: "Golden Retriever",
        date_of_birth: ~D[2020-06-15],
        weight: "30.5",
        spayed_neutered: true,
        owner_id: (owner && owner.id) || attrs[:owner_id]
      })
      |> Pawzitively.Pets.create_pet()

    pet
  end
end
