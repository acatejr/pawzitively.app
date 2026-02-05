defmodule PawzitivelyWeb.PetLive.Show do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Pets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@pet.name}
        <:subtitle>{@pet.species} - {@pet.breed}</:subtitle>
        <:actions>
          <.button navigate={~p"/pets"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/pets/#{@pet}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit pet
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Owner">
          <.link navigate={~p"/owners/#{@pet.owner_id}"} class="link link-primary">
            {@pet.owner.first_name} {@pet.owner.last_name}
          </.link>
        </:item>
        <:item title="Species">{@pet.species}</:item>
        <:item title="Breed">{@pet.breed}</:item>
        <:item title="Date of birth">{@pet.date_of_birth}</:item>
        <:item title="Weight">{@pet.weight}</:item>
        <:item title="Spayed/Neutered">{@pet.spayed_neutered}</:item>
        <:item title="Medical notes">{@pet.medical_notes}</:item>
        <:item title="Notes">{@pet.notes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Pet")
     |> assign(:pet, Pets.get_pet!(id))}
  end
end
