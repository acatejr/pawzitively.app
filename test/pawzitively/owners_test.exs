defmodule Pawzitively.OwnersTest do
  use Pawzitively.DataCase

  alias Pawzitively.Owners

  describe "owners" do
    alias Pawzitively.Owners.Owner

    import Pawzitively.OwnersFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, email: nil, phone: nil}

    test "list_owners/0 returns all owners" do
      owner = owner_fixture()
      assert Owners.list_owners() == [owner]
    end

    test "get_owner!/1 returns the owner with given id" do
      owner = owner_fixture()
      assert Owners.get_owner!(owner.id) == owner
    end

    test "create_owner/1 with valid data creates a owner" do
      valid_attrs = %{
        first_name: "John",
        last_name: "Smith",
        email: "john@example.com",
        phone: "555-1234",
        emergency_contact_name: "Jane Smith",
        emergency_contact_phone: "555-5678",
        notes: "some notes"
      }

      assert {:ok, %Owner{} = owner} = Owners.create_owner(valid_attrs)
      assert owner.first_name == "John"
      assert owner.last_name == "Smith"
      assert owner.email == "john@example.com"
      assert owner.phone == "555-1234"
      assert owner.emergency_contact_name == "Jane Smith"
      assert owner.emergency_contact_phone == "555-5678"
      assert owner.notes == "some notes"
    end

    test "create_owner/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Owners.create_owner(@invalid_attrs)
    end

    test "update_owner/2 with valid data updates the owner" do
      owner = owner_fixture()

      update_attrs = %{
        first_name: "Updated",
        last_name: "Name",
        email: "updated@example.com",
        phone: "555-9999"
      }

      assert {:ok, %Owner{} = owner} = Owners.update_owner(owner, update_attrs)
      assert owner.first_name == "Updated"
      assert owner.last_name == "Name"
      assert owner.email == "updated@example.com"
      assert owner.phone == "555-9999"
    end

    test "update_owner/2 with invalid data returns error changeset" do
      owner = owner_fixture()
      assert {:error, %Ecto.Changeset{}} = Owners.update_owner(owner, @invalid_attrs)
      assert owner == Owners.get_owner!(owner.id)
    end

    test "delete_owner/1 deletes the owner" do
      owner = owner_fixture()
      assert {:ok, %Owner{}} = Owners.delete_owner(owner)
      assert_raise Ecto.NoResultsError, fn -> Owners.get_owner!(owner.id) end
    end

    test "change_owner/1 returns a owner changeset" do
      owner = owner_fixture()
      assert %Ecto.Changeset{} = Owners.change_owner(owner)
    end
  end
end
