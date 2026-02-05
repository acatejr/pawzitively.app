defmodule PawzitivelyWeb.OwnerLive.Show do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Owners

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@owner.first_name} {@owner.last_name}
        <:actions>
          <.button navigate={~p"/owners"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/owners/#{@owner}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit owner
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Email">{@owner.email}</:item>
        <:item title="Phone">{@owner.phone}</:item>
        <:item title="Emergency contact">{@owner.emergency_contact_name}</:item>
        <:item title="Emergency phone">{@owner.emergency_contact_phone}</:item>
        <:item title="Notes">{@owner.notes}</:item>
      </.list>

      <div class="mt-10">
        <.header>
          Pets
          <:actions>
            <.button variant="primary" navigate={~p"/pets/new?owner_id=#{@owner.id}"}>
              <.icon name="hero-plus" /> Add Pet
            </.button>
          </:actions>
        </.header>
      </div>

      <.table id="owner-pets" rows={@owner.pets}>
        <:col :let={pet} label="Name">{pet.name}</:col>
        <:col :let={pet} label="Species">{pet.species}</:col>
        <:col :let={pet} label="Breed">{pet.breed}</:col>
        <:action :let={pet}>
          <.link navigate={~p"/pets/#{pet}"}>View</.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    owner = Owners.get_owner!(id) |> Pawzitively.Repo.preload(:pets)

    {:ok,
     socket
     |> assign(:page_title, "Show Owner")
     |> assign(:owner, owner)}
  end
end
