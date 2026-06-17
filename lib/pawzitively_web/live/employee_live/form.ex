defmodule PawzitivelyWeb.EmployeeLive.Form do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Employees
  alias Pawzitively.Employees.Employee

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage employee records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="employee-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:last_name]} type="text" label="Last name" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:phone]} type="text" label="Phone" />
        <.input field={@form[:active]} type="checkbox" label="Active" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Employee</.button>
          <.button navigate={return_path(@return_to, @employee)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    employee = Employees.get_employee!(id)

    socket
    |> assign(:page_title, "Edit Employee")
    |> assign(:employee, employee)
    |> assign(:form, to_form(Employees.change_employee(employee)))
  end

  defp apply_action(socket, :new, _params) do
    employee = %Employee{}

    socket
    |> assign(:page_title, "New Employee")
    |> assign(:employee, employee)
    |> assign(:form, to_form(Employees.change_employee(employee)))
  end

  @impl true
  def handle_event("validate", %{"employee" => employee_params}, socket) do
    changeset = Employees.change_employee(socket.assigns.employee, employee_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"employee" => employee_params}, socket) do
    save_employee(socket, socket.assigns.live_action, employee_params)
  end

  defp save_employee(socket, :edit, employee_params) do
    case Employees.update_employee(socket.assigns.employee, employee_params) do
      {:ok, employee} ->
        {:noreply,
         socket
         |> put_flash(:info, "Employee updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, employee))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_employee(socket, :new, employee_params) do
    case Employees.create_employee(employee_params) do
      {:ok, employee} ->
        {:noreply,
         socket
         |> put_flash(:info, "Employee created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, employee))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _employee), do: ~p"/employees"
  defp return_path("show", employee), do: ~p"/employees/#{employee}"
end
