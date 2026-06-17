defmodule PawzitivelyWeb.VisitLive.Edit do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Visits

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Adjust times for {@visit.pet.name}
        <:subtitle>Correct the check-in or check-out date and time for this visit.</:subtitle>
      </.header>

      <.form for={@form} id="visit-times-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:checked_in_at]} type="datetime-local" label="Checked in at" />
        <.input
          :if={@checked_out?}
          field={@form[:checked_out_at]}
          type="datetime-local"
          label="Checked out at"
        />
        <p :if={!@checked_out?} class="text-sm text-base-content/70">
          This pet is still checked in, so there's no check-out time to adjust yet.
        </p>
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save changes</.button>
          <.button navigate={~p"/dashboard"}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    visit = Visits.get_visit!(id)

    {:ok,
     socket
     |> assign(:page_title, "Adjust visit times")
     |> assign(:visit, visit)
     |> assign(:checked_out?, not is_nil(visit.checked_out_at))
     |> assign_form(Visits.change_visit_times(visit))}
  end

  @impl true
  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset = Visits.change_visit_times(socket.assigns.visit, visit_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"visit" => visit_params}, socket) do
    case Visits.update_visit_times(socket.assigns.visit, visit_params) do
      {:ok, _visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Visit times updated successfully")
         |> push_navigate(to: ~p"/dashboard")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, changeset), do: assign(socket, :form, to_form(changeset, as: :visit))
end
