defmodule PawzitivelyWeb.VisitLive.CheckOut do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Employees
  alias Pawzitively.Visits

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Check out {@visit.pet.name}
        <:subtitle>Record who is picking the pet up and the employee handling it.</:subtitle>
      </.header>

      <.list>
        <:item title="Checked in by">
          {@visit.checked_in_by_owner.first_name} {@visit.checked_in_by_owner.last_name}
        </:item>
        <:item title="Checked in at">
          {Calendar.strftime(@visit.checked_in_at, "%Y-%m-%d %I:%M %P")}
        </:item>
      </.list>

      <.form for={@form} id="check-out-form" phx-change="validate" phx-submit="save" class="mt-6">
        <.input
          field={@form[:checked_out_by_owner_id]}
          type="select"
          label="Picked up by (owner)"
          options={@owner_options}
          prompt="Select an owner"
        />
        <.input
          field={@form[:checked_out_by_employee_id]}
          type="select"
          label="Checked out by (employee)"
          options={@employee_options}
          prompt="Select an employee"
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Check out</.button>
          <.button navigate={~p"/dashboard"}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    visit = Visits.get_visit!(id)
    pet = Pawzitively.Pets.get_pet!(visit.pet_id)

    owner_options =
      Enum.map(pet.owners, fn o -> {"#{o.first_name} #{o.last_name}", o.id} end)

    {:ok,
     socket
     |> assign(:page_title, "Check out")
     |> assign(:visit, visit)
     |> assign(:owner_options, owner_options)
     |> assign(:employee_options, employee_options())
     |> assign_form(Visits.change_check_out(visit))}
  end

  @impl true
  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset = Visits.change_check_out(socket.assigns.visit, visit_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"visit" => visit_params}, socket) do
    case Visits.check_out(socket.assigns.visit, visit_params) do
      {:ok, _visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pet checked out successfully")
         |> push_navigate(to: ~p"/dashboard")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, changeset), do: assign(socket, :form, to_form(changeset, as: :visit))

  defp employee_options do
    Employees.list_employees(only_active: true)
    |> Enum.map(fn e -> {"#{e.first_name} #{e.last_name}", e.id} end)
  end
end
