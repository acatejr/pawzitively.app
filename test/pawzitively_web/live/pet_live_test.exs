defmodule PawzitivelyWeb.PetLiveTest do
  use PawzitivelyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pawzitively.PetsFixtures
  import Pawzitively.OwnersFixtures

  @update_attrs %{name: "Updated Name", species: "Cat", breed: "Siamese"}
  @invalid_attrs %{name: nil, species: nil}

  defp create_pet(_) do
    pet = pet_fixture()

    %{pet: pet}
  end

  describe "Index" do
    setup [:create_pet]

    test "lists all pets", %{conn: conn, pet: pet} do
      {:ok, _index_live, html} = live(conn, ~p"/pets")

      assert html =~ "Listing Pets"
      assert html =~ pet.name
    end

    test "saves new pet", %{conn: conn} do
      owner = owner_fixture()
      {:ok, index_live, _html} = live(conn, ~p"/pets")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Pet")
               |> render_click()
               |> follow_redirect(conn, ~p"/pets/new")

      assert render(form_live) =~ "New Pet"

      assert form_live
             |> form("#pet-form", pet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      create_attrs = %{name: "Rex", species: "Dog", breed: "Lab", owner_id: owner.id}

      assert {:ok, index_live, _html} =
               form_live
               |> form("#pet-form", pet: create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/pets")

      html = render(index_live)
      assert html =~ "Pet created successfully"
      assert html =~ "Rex"
    end

    test "updates pet in listing", %{conn: conn, pet: pet} do
      {:ok, index_live, _html} = live(conn, ~p"/pets")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#pets-#{pet.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/pets/#{pet}/edit")

      assert render(form_live) =~ "Edit Pet"

      assert form_live
             |> form("#pet-form", pet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#pet-form", pet: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/pets")

      html = render(index_live)
      assert html =~ "Pet updated successfully"
      assert html =~ "Updated Name"
    end

    test "deletes pet in listing", %{conn: conn, pet: pet} do
      {:ok, index_live, _html} = live(conn, ~p"/pets")

      assert index_live |> element("#pets-#{pet.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#pets-#{pet.id}")
    end
  end

  describe "Show" do
    setup [:create_pet]

    test "displays pet", %{conn: conn, pet: pet} do
      {:ok, _show_live, html} = live(conn, ~p"/pets/#{pet}")

      assert html =~ pet.name
      assert html =~ pet.species
    end

    test "updates pet and returns to show", %{conn: conn, pet: pet} do
      {:ok, show_live, _html} = live(conn, ~p"/pets/#{pet}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/pets/#{pet}/edit?return_to=show")

      assert render(form_live) =~ "Edit Pet"

      assert form_live
             |> form("#pet-form", pet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#pet-form", pet: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/pets/#{pet}")

      html = render(show_live)
      assert html =~ "Pet updated successfully"
      assert html =~ "Updated Name"
    end
  end
end
