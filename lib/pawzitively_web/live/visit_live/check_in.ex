defmodule PawzitivelyWeb.VisitLive.CheckIn do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Pets
  alias Pawzitively.Employees
  alias Pawzitively.Visits
  alias Pawzitively.Visits.Visit

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Check in a pet
        <:subtitle>Record who is dropping the pet off and the employee handling it.</:subtitle>
      </.header>

      <.form for={@form} id="check-in-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:pet_id]}
          type="select"
          label="Pet"
          options={@pet_options}
          prompt="Select a pet"
        />
        <.input
          field={@form[:checked_in_by_owner_id]}
          type="select"
          label="Dropped off by (owner)"
          options={@owner_options}
          prompt={owner_prompt(@owner_options)}
        />
        <.input
          field={@form[:checked_in_by_employee_id]}
          type="select"
          label="Checked in by (employee)"
          options={@employee_options}
          prompt="Select an employee"
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Check in</.button>
          <.button navigate={~p"/dashboard"}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Check in a pet")
     |> assign(:pet_options, pet_options())
     |> assign(:employee_options, employee_options())
     |> assign(:owner_options, [])
     |> assign_form(Visits.change_check_in(%Visit{}))}
  end

  @impl true
  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset = Visits.change_check_in(%Visit{}, visit_params)

    {:noreply,
     socket
     |> assign(:owner_options, owner_options(visit_params["pet_id"]))
     |> assign_form(Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"visit" => visit_params}, socket) do
    case Visits.check_in(visit_params) do
      {:ok, _visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pet checked in successfully")
         |> push_navigate(to: ~p"/dashboard")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:owner_options, owner_options(visit_params["pet_id"]))
         |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset), do: assign(socket, :form, to_form(changeset, as: :visit))

  defp pet_options do
    Pets.list_pets()
    |> Enum.map(fn pet -> {pet.name, pet.id} end)
  end

  defp employee_options do
    Employees.list_employees(only_active: true)
    |> Enum.map(fn e -> {"#{e.first_name} #{e.last_name}", e.id} end)
  end

  defp owner_options(nil), do: []
  defp owner_options(""), do: []

  defp owner_options(pet_id) do
    pet = Pets.get_pet!(pet_id)

    pet.owners
    |> Enum.map(fn o -> {"#{o.first_name} #{o.last_name}", o.id} end)
  rescue
    Ecto.NoResultsError -> []
  end

  defp owner_prompt([]), do: "Select a pet first"
  defp owner_prompt(_), do: "Select an owner"
end
