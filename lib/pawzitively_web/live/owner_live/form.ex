defmodule PawzitivelyWeb.OwnerLive.Form do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Owners
  alias Pawzitively.Owners.Owner

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage owner records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="owner-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:last_name]} type="text" label="Last name" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:phone]} type="text" label="Phone" />
        <.input field={@form[:emergency_contact_name]} type="text" label="Emergency contact name" />
        <.input field={@form[:emergency_contact_phone]} type="text" label="Emergency contact phone" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Owner</.button>
          <.button navigate={return_path(@return_to, @owner)}>Cancel</.button>
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
    owner = Owners.get_owner!(id)

    socket
    |> assign(:page_title, "Edit Owner")
    |> assign(:owner, owner)
    |> assign(:form, to_form(Owners.change_owner(owner)))
  end

  defp apply_action(socket, :new, _params) do
    owner = %Owner{}

    socket
    |> assign(:page_title, "New Owner")
    |> assign(:owner, owner)
    |> assign(:form, to_form(Owners.change_owner(owner)))
  end

  @impl true
  def handle_event("validate", %{"owner" => owner_params}, socket) do
    changeset = Owners.change_owner(socket.assigns.owner, owner_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"owner" => owner_params}, socket) do
    save_owner(socket, socket.assigns.live_action, owner_params)
  end

  defp save_owner(socket, :edit, owner_params) do
    case Owners.update_owner(socket.assigns.owner, owner_params) do
      {:ok, owner} ->
        {:noreply,
         socket
         |> put_flash(:info, "Owner updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, owner))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_owner(socket, :new, owner_params) do
    case Owners.create_owner(owner_params) do
      {:ok, owner} ->
        {:noreply,
         socket
         |> put_flash(:info, "Owner created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, owner))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _owner), do: ~p"/owners"
  defp return_path("show", owner), do: ~p"/owners/#{owner}"
end
