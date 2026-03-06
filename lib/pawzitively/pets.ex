defmodule Pawzitively.Pets do
  @moduledoc """
  The Pets context.
  """

  import Ecto.Query, warn: false
  alias Pawzitively.Repo

  alias Pawzitively.Pets.Pet
  alias Pawzitively.Owners.Owner

  @doc """
  Returns the list of pets.

  ## Examples

      iex> list_pets()
      [%Pet{}, ...]

  """
  def list_pets(opts \\ []) do
    query = from(p in Pet, order_by: [asc: p.name], preload: [:owners])

    query =
      case Keyword.get(opts, :search) do
        nil ->
          query

        "" ->
          query

        term ->
          search = "%#{term}%"

          from p in query,
            where:
              ilike(p.name, ^search) or
                ilike(p.species, ^search) or
                ilike(p.breed, ^search)
      end

    Repo.all(query)
  end

  @doc """
  Gets a single pet.

  Raises `Ecto.NoResultsError` if the Pet does not exist.

  ## Examples

      iex> get_pet!(123)
      %Pet{}

      iex> get_pet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pet!(id) do
    pet =
      Pet
      |> Repo.get!(id)
      |> Repo.preload(:owners)

    %{pet | owner_ids: Enum.map(pet.owners, & &1.id)}
  end

  @doc """
  Creates a pet.

  ## Examples

      iex> create_pet(%{field: value})
      {:ok, %Pet{}}

      iex> create_pet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pet(attrs) do
    owners = fetch_owners(attrs)
    changeset = Pet.changeset(%Pet{}, attrs)

    if Enum.empty?(owners) do
      {:error, Ecto.Changeset.add_error(changeset, :owner_ids, "must have at least one owner")}
    else
      changeset
      |> Ecto.Changeset.put_assoc(:owners, owners)
      |> Repo.insert()
    end
  end

  @doc """
  Updates a pet.

  ## Examples

      iex> update_pet(pet, %{field: new_value})
      {:ok, %Pet{}}

      iex> update_pet(pet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pet(%Pet{} = pet, attrs) do
    pet = Repo.preload(pet, :owners)
    owners = fetch_owners(attrs)
    changeset = Pet.changeset(pet, attrs)

    if Enum.empty?(owners) do
      {:error, Ecto.Changeset.add_error(changeset, :owner_ids, "must have at least one owner")}
    else
      changeset
      |> Ecto.Changeset.put_assoc(:owners, owners)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a pet.

  ## Examples

      iex> delete_pet(pet)
      {:ok, %Pet{}}

      iex> delete_pet(pet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pet(%Pet{} = pet) do
    Repo.delete(pet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pet changes.

  ## Examples

      iex> change_pet(pet)
      %Ecto.Changeset{data: %Pet{}}

  """
  def change_pet(%Pet{} = pet, attrs \\ %{}) do
    Pet.changeset(pet, attrs)
  end

  defp fetch_owners(attrs) do
    owner_ids =
      (attrs["owner_ids"] || attrs[:owner_ids] || [])
      |> Enum.map(fn
        id when is_integer(id) -> id
        id when is_binary(id) ->
          case Integer.parse(id) do
            {int, ""} -> int
            _ -> nil
          end

        _ ->
          nil
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    if Enum.empty?(owner_ids) do
      []
    else
      Repo.all(from o in Owner, where: o.id in ^owner_ids)
    end
  end
end
