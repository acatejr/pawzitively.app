defmodule PawzitivelyWeb.PetLive.Index do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Pets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Pets
        <:actions>
          <.button variant="primary" navigate={~p"/pets/new"}>
            <.icon name="hero-plus" /> New Pet
          </.button>
        </:actions>
      </.header>

      <form phx-change="search" class="mb-4">
        <.input
          type="text"
          name="search"
          value={@search}
          placeholder="Search pets..."
          phx-debounce="300"
        />
      </form>

      <.table
        id="pets"
        rows={@streams.pets}
        row_click={fn {_id, pet} -> JS.navigate(~p"/pets/#{pet}") end}
      >
        <:col :let={{_id, pet}} label="Name">{pet.name}</:col>
        <:col :let={{_id, pet}} label="Species">{pet.species}</:col>
        <:col :let={{_id, pet}} label="Breed">{pet.breed}</:col>
        <:col :let={{_id, pet}} label="Owner">{pet.owner.first_name} {pet.owner.last_name}</:col>
        <:action :let={{_id, pet}}>
          <div class="sr-only">
            <.link navigate={~p"/pets/#{pet}"}>Show</.link>
          </div>
          <.link navigate={~p"/pets/#{pet}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, pet}}>
          <.link
            phx-click={JS.push("delete", value: %{id: pet.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Pets")
     |> assign(:search, "")
     |> stream(:pets, Pets.list_pets())}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    pets = Pets.list_pets(search: search)

    {:noreply,
     socket
     |> assign(:search, search)
     |> stream(:pets, pets, reset: true)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    pet = Pets.get_pet!(id)
    {:ok, _} = Pets.delete_pet(pet)

    {:noreply, stream_delete(socket, :pets, pet)}
  end
end
