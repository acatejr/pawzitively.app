defmodule PawzitivelyWeb.VisitLive.Dashboard do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Visits

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Day Care Dashboard
        <:subtitle>Pets currently checked in</:subtitle>
        <:actions>
          <.button variant="primary" navigate={~p"/dashboard/check-in"}>
            <.icon name="hero-plus" /> Check in a pet
          </.button>
        </:actions>
      </.header>

      <.table id="active-visits" rows={@active_visits}>
        <:col :let={visit} label="Pet">{visit.pet.name}</:col>
        <:col :let={visit} label="Checked in by">{owner_name(visit.checked_in_by_owner)}</:col>
        <:col :let={visit} label="Employee">{employee_name(visit.checked_in_by_employee)}</:col>
        <:col :let={visit} label="Checked in at">{format_dt(visit.checked_in_at)}</:col>
        <:action :let={visit}>
          <.link navigate={~p"/dashboard/#{visit}/edit"}>Edit times</.link>
        </:action>
        <:action :let={visit}>
          <.link navigate={~p"/dashboard/#{visit}/check-out"}>Check out</.link>
        </:action>
        <:action :let={visit}>
          <.link
            phx-click={JS.push("delete", value: %{id: visit.id})}
            data-confirm="Delete this visit? This cannot be undone."
          >
            Delete
          </.link>
        </:action>
      </.table>

      <p :if={@active_visits == []} class="text-sm text-base-content/70">
        No pets are currently checked in.
      </p>

      <div class="mt-10">
        <.header>
          Recently checked out
          <:subtitle>The latest completed visits</:subtitle>
        </.header>
      </div>

      <.table id="completed-visits" rows={@completed_visits}>
        <:col :let={visit} label="Pet">{visit.pet.name}</:col>
        <:col :let={visit} label="In by">{owner_name(visit.checked_in_by_owner)}</:col>
        <:col :let={visit} label="In at">{format_dt(visit.checked_in_at)}</:col>
        <:col :let={visit} label="Out by">{owner_name(visit.checked_out_by_owner)}</:col>
        <:col :let={visit} label="Out at">{format_dt(visit.checked_out_at)}</:col>
        <:col :let={visit} label="Duration">{format_duration(visit)}</:col>
        <:col :let={visit} label="Out employee">{employee_name(visit.checked_out_by_employee)}</:col>
        <:action :let={visit}>
          <.link navigate={~p"/dashboard/#{visit}/edit"}>Edit times</.link>
        </:action>
        <:action :let={visit}>
          <.link
            phx-click={JS.push("delete", value: %{id: visit.id})}
            data-confirm="Delete this visit? This cannot be undone."
          >
            Delete
          </.link>
        </:action>
      </.table>

      <p :if={@completed_visits == []} class="text-sm text-base-content/70">
        No completed visits yet.
      </p>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> load_visits()}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    id
    |> Visits.get_visit!()
    |> Visits.delete_visit()

    {:noreply,
     socket
     |> put_flash(:info, "Visit deleted")
     |> load_visits()}
  end

  defp load_visits(socket) do
    socket
    |> assign(:active_visits, Visits.list_active_visits())
    |> assign(:completed_visits, Visits.list_completed_visits(limit: 25))
  end

  defp owner_name(nil), do: "—"
  defp owner_name(owner), do: "#{owner.first_name} #{owner.last_name}"

  defp employee_name(nil), do: "—"
  defp employee_name(employee), do: "#{employee.first_name} #{employee.last_name}"

  defp format_dt(nil), do: "—"

  defp format_dt(%DateTime{} = dt) do
    Calendar.strftime(dt, "%Y-%m-%d %I:%M %P")
  end

  defp format_duration(%{checked_in_at: %DateTime{} = in_at, checked_out_at: %DateTime{} = out_at}) do
    total_minutes = div(DateTime.diff(out_at, in_at, :second), 60)
    hours = div(total_minutes, 60)
    minutes = rem(total_minutes, 60)
    "#{hours}h #{minutes}m"
  end

  defp format_duration(_), do: "—"
end
