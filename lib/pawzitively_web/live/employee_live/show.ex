defmodule PawzitivelyWeb.EmployeeLive.Show do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Employees

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@employee.first_name} {@employee.last_name}
        <:actions>
          <.button navigate={~p"/employees"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/employees/#{@employee}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit employee
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Email">{@employee.email}</:item>
        <:item title="Phone">{@employee.phone}</:item>
        <:item title="Active">{if @employee.active, do: "Yes", else: "No"}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Employee")
     |> assign(:employee, Employees.get_employee!(id))}
  end
end
