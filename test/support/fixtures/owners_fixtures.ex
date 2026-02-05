defmodule Pawzitively.OwnersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pawzitively.Owners` context.
  """

  @doc """
  Generate a owner.
  """
  def owner_fixture(attrs \\ %{}) do
    {:ok, owner} =
      attrs
      |> Enum.into(%{
        first_name: "Jane",
        last_name: "Doe",
        email: "jane.doe.#{System.unique_integer([:positive])}@example.com",
        phone: "555-0100",
        emergency_contact_name: "John Doe",
        emergency_contact_phone: "555-0101"
      })
      |> Pawzitively.Owners.create_owner()

    owner
  end
end
