defmodule Pawzitively.Owners do
  @moduledoc """
  The Owners context.
  """

  import Ecto.Query, warn: false
  alias Pawzitively.Repo

  alias Pawzitively.Owners.Owner

  @doc """
  Returns the list of owners.

  ## Examples

      iex> list_owners()
      [%Owner{}, ...]

  """
  def list_owners(opts \\ []) do
    query = from(o in Owner, order_by: [asc: o.last_name, asc: o.first_name])

    query =
      case Keyword.get(opts, :search) do
        nil ->
          query

        "" ->
          query

        term ->
          search = "%#{term}%"

          from o in query,
            where:
              ilike(o.first_name, ^search) or
                ilike(o.last_name, ^search) or
                ilike(o.email, ^search)
      end

    Repo.all(query)
  end

  @doc """
  Gets a single owner.

  Raises `Ecto.NoResultsError` if the Owner does not exist.

  ## Examples

      iex> get_owner!(123)
      %Owner{}

      iex> get_owner!(456)
      ** (Ecto.NoResultsError)

  """
  def get_owner!(id), do: Repo.get!(Owner, id)

  @doc """
  Creates a owner.

  ## Examples

      iex> create_owner(%{field: value})
      {:ok, %Owner{}}

      iex> create_owner(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_owner(attrs) do
    %Owner{}
    |> Owner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a owner.

  ## Examples

      iex> update_owner(owner, %{field: new_value})
      {:ok, %Owner{}}

      iex> update_owner(owner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_owner(%Owner{} = owner, attrs) do
    owner
    |> Owner.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a owner.

  ## Examples

      iex> delete_owner(owner)
      {:ok, %Owner{}}

      iex> delete_owner(owner)
      {:error, %Ecto.Changeset{}}

  """
  def delete_owner(%Owner{} = owner) do
    owner = Repo.preload(owner, :pets)

    if Enum.any?(owner.pets) do
      {:error, :has_associated_pets}
    else
      Repo.delete(owner)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking owner changes.

  ## Examples

      iex> change_owner(owner)
      %Ecto.Changeset{data: %Owner{}}

  """
  def change_owner(%Owner{} = owner, attrs \\ %{}) do
    Owner.changeset(owner, attrs)
  end
end
