defmodule PawzitivelyWeb.PetLive.Form do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Pets
  alias Pawzitively.Pets.Pet
  alias Pawzitively.Owners

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage pet records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="pet-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:owner_id]}
          type="select"
          label="Owner"
          options={@owner_options}
          prompt="Select an owner"
        />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:species]} type="text" label="Species" />
        <.input field={@form[:breed]} type="text" label="Breed" />
        <.input field={@form[:date_of_birth]} type="date" label="Date of birth" />
        <.input field={@form[:weight]} type="number" label="Weight" step="any" />
        <.input field={@form[:medical_notes]} type="textarea" label="Medical notes" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <.input field={@form[:spayed_neutered]} type="checkbox" label="Spayed neutered" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Pet</.button>
          <.button navigate={return_path(@return_to, @pet)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    owner_options =
      Owners.list_owners()
      |> Enum.map(fn o -> {"#{o.first_name} #{o.last_name}", o.id} end)

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:owner_options, owner_options)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    pet = Pets.get_pet!(id)

    socket
    |> assign(:page_title, "Edit Pet")
    |> assign(:pet, pet)
    |> assign(:form, to_form(Pets.change_pet(pet)))
  end

  defp apply_action(socket, :new, params) do
    attrs = if params["owner_id"], do: %{owner_id: params["owner_id"]}, else: %{}
    pet = %Pet{}

    socket
    |> assign(:page_title, "New Pet")
    |> assign(:pet, pet)
    |> assign(:form, to_form(Pets.change_pet(pet, attrs)))
  end

  @impl true
  def handle_event("validate", %{"pet" => pet_params}, socket) do
    changeset = Pets.change_pet(socket.assigns.pet, pet_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"pet" => pet_params}, socket) do
    save_pet(socket, socket.assigns.live_action, pet_params)
  end

  defp save_pet(socket, :edit, pet_params) do
    case Pets.update_pet(socket.assigns.pet, pet_params) do
      {:ok, pet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pet updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, pet))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_pet(socket, :new, pet_params) do
    case Pets.create_pet(pet_params) do
      {:ok, pet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pet created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, pet))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _pet), do: ~p"/pets"
  defp return_path("show", pet), do: ~p"/pets/#{pet}"
end
