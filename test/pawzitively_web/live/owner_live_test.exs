defmodule PawzitivelyWeb.OwnerLiveTest do
  use PawzitivelyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pawzitively.OwnersFixtures

  @create_attrs %{
    first_name: "John",
    last_name: "Smith",
    email: "john@example.com",
    phone: "555-1234",
    emergency_contact_name: "Jane Smith",
    emergency_contact_phone: "555-5678",
    notes: "some notes"
  }
  @update_attrs %{
    first_name: "Updated",
    last_name: "Name",
    email: "updated@example.com",
    phone: "555-9999",
    emergency_contact_name: "Updated Contact",
    emergency_contact_phone: "555-0000",
    notes: "updated notes"
  }
  @invalid_attrs %{first_name: nil, last_name: nil, email: nil, phone: nil}

  defp create_owner(_) do
    owner = owner_fixture()

    %{owner: owner}
  end

  describe "Index" do
    setup [:create_owner]

    test "lists all owners", %{conn: conn, owner: owner} do
      {:ok, _index_live, html} = live(conn, ~p"/owners")

      assert html =~ "Listing Owners"
      assert html =~ owner.first_name
    end

    test "saves new owner", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/owners")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Owner")
               |> render_click()
               |> follow_redirect(conn, ~p"/owners/new")

      assert render(form_live) =~ "New Owner"

      assert form_live
             |> form("#owner-form", owner: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#owner-form", owner: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/owners")

      html = render(index_live)
      assert html =~ "Owner created successfully"
      assert html =~ "John"
    end

    test "updates owner in listing", %{conn: conn, owner: owner} do
      {:ok, index_live, _html} = live(conn, ~p"/owners")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#owners-#{owner.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/owners/#{owner}/edit")

      assert render(form_live) =~ "Edit Owner"

      assert form_live
             |> form("#owner-form", owner: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#owner-form", owner: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/owners")

      html = render(index_live)
      assert html =~ "Owner updated successfully"
      assert html =~ "Updated"
    end

    test "deletes owner in listing", %{conn: conn, owner: owner} do
      {:ok, index_live, _html} = live(conn, ~p"/owners")

      assert index_live |> element("#owners-#{owner.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#owners-#{owner.id}")
    end
  end

  describe "Show" do
    setup [:create_owner]

    test "displays owner", %{conn: conn, owner: owner} do
      {:ok, _show_live, html} = live(conn, ~p"/owners/#{owner}")

      assert html =~ owner.first_name
      assert html =~ owner.last_name
    end

    test "updates owner and returns to show", %{conn: conn, owner: owner} do
      {:ok, show_live, _html} = live(conn, ~p"/owners/#{owner}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/owners/#{owner}/edit?return_to=show")

      assert render(form_live) =~ "Edit Owner"

      assert form_live
             |> form("#owner-form", owner: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#owner-form", owner: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/owners/#{owner}")

      html = render(show_live)
      assert html =~ "Owner updated successfully"
      assert html =~ "Updated"
    end
  end
end
