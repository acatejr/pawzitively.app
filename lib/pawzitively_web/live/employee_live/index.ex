defmodule PawzitivelyWeb.EmployeeLive.Index do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Employees

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Employees
        <:actions>
          <.button variant="primary" navigate={~p"/employees/new"}>
            <.icon name="hero-plus" /> New Employee
          </.button>
        </:actions>
      </.header>

      <.table
        id="employees"
        rows={@streams.employees}
        row_click={fn {_id, employee} -> JS.navigate(~p"/employees/#{employee}") end}
      >
        <:col :let={{_id, employee}} label="First name">{employee.first_name}</:col>
        <:col :let={{_id, employee}} label="Last name">{employee.last_name}</:col>
        <:col :let={{_id, employee}} label="Email">{employee.email}</:col>
        <:col :let={{_id, employee}} label="Phone">{employee.phone}</:col>
        <:col :let={{_id, employee}} label="Active">{if employee.active, do: "Yes", else: "No"}</:col>
        <:action :let={{_id, employee}}>
          <div class="sr-only">
            <.link navigate={~p"/employees/#{employee}"}>Show</.link>
          </div>
          <.link navigate={~p"/employees/#{employee}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, employee}}>
          <.link
            phx-click={JS.push("delete", value: %{id: employee.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Employees")
     |> stream(:employees, Employees.list_employees())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    employee = Employees.get_employee!(id)

    case Employees.delete_employee(employee) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :employees, employee)}

      {:error, _changeset} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Cannot delete employee: they are referenced by one or more check-ins. Mark them inactive instead."
         )}
    end
  end
end
