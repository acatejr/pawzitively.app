defmodule PawzitivelyWeb.OwnerLive.Index do
  use PawzitivelyWeb, :live_view

  alias Pawzitively.Owners

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Owners
        <:actions>
          <.button variant="primary" navigate={~p"/owners/new"}>
            <.icon name="hero-plus" /> New Owner
          </.button>
        </:actions>
      </.header>

      <form phx-change="search" class="mb-4">
        <.input
          type="text"
          name="search"
          value={@search}
          placeholder="Search owners..."
          phx-debounce="300"
        />
      </form>

      <.table
        id="owners"
        rows={@streams.owners}
        row_click={fn {_id, owner} -> JS.navigate(~p"/owners/#{owner}") end}
      >
        <:col :let={{_id, owner}} label="First name">{owner.first_name}</:col>
        <:col :let={{_id, owner}} label="Last name">{owner.last_name}</:col>
        <:col :let={{_id, owner}} label="Email">{owner.email}</:col>
        <:col :let={{_id, owner}} label="Phone">{owner.phone}</:col>
        <:action :let={{_id, owner}}>
          <div class="sr-only">
            <.link navigate={~p"/owners/#{owner}"}>Show</.link>
          </div>
          <.link navigate={~p"/owners/#{owner}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, owner}}>
          <.link
            phx-click={JS.push("delete", value: %{id: owner.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Owners")
     |> assign(:search, "")
     |> stream(:owners, Owners.list_owners())}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    owners = Owners.list_owners(search: search)

    {:noreply,
     socket
     |> assign(:search, search)
     |> stream(:owners, owners, reset: true)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    owner = Owners.get_owner!(id)

    case Owners.delete_owner(owner) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :owners, owner)}

      {:error, :has_associated_pets} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Cannot delete owner with associated pets. Please remove their pets first."
         )}
    end
  end
end
