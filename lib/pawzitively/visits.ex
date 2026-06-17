defmodule Pawzitively.Visits do
  @moduledoc """
  The Visits context.

  A visit represents a single day-care stay: a pet is checked in by one of its
  owners (recorded alongside the employee who handled the check-in) and later
  checked out, again recording the owner picking up and the employee on duty.
  An "active" visit is one that has been checked in but not yet checked out.
  """

  import Ecto.Query, warn: false
  alias Pawzitively.Repo

  alias Pawzitively.Visits.Visit

  @preloads [
    :pet,
    :checked_in_by_owner,
    :checked_out_by_owner,
    :checked_in_by_employee,
    :checked_out_by_employee
  ]

  @doc """
  Returns currently checked-in visits (no check-out recorded yet), oldest first.
  """
  def list_active_visits do
    from(v in Visit,
      where: is_nil(v.checked_out_at),
      order_by: [asc: v.checked_in_at],
      preload: ^@preloads
    )
    |> Repo.all()
  end

  @doc """
  Returns the most recently completed (checked-out) visits, newest first.

  Pass `:limit` to cap the number of rows (defaults to 50).
  """
  def list_completed_visits(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(v in Visit,
      where: not is_nil(v.checked_out_at),
      order_by: [desc: v.checked_out_at],
      limit: ^limit,
      preload: ^@preloads
    )
    |> Repo.all()
  end

  @doc """
  Gets a single visit with all associations preloaded.

  Raises `Ecto.NoResultsError` if the Visit does not exist.
  """
  def get_visit!(id) do
    Visit
    |> Repo.get!(id)
    |> Repo.preload(@preloads)
  end

  @doc """
  Returns true if the given pet currently has an open visit.
  """
  def pet_checked_in?(pet_id) do
    Repo.exists?(from v in Visit, where: v.pet_id == ^pet_id and is_nil(v.checked_out_at))
  end

  @doc """
  Checks a pet in.

  `checked_in_at` defaults to the current time when not supplied. Returns
  `{:ok, visit}` or `{:error, changeset}` (including when the pet is already
  checked in).
  """
  def check_in(attrs) do
    attrs = put_default_timestamp(attrs, :checked_in_at)

    %Visit{}
    |> Visit.check_in_changeset(attrs)
    |> Repo.insert()
    |> preload_result()
  end

  @doc """
  Checks a pet out, completing an active visit.

  `checked_out_at` defaults to the current time when not supplied.
  """
  def check_out(%Visit{} = visit, attrs) do
    attrs = put_default_timestamp(attrs, :checked_out_at)

    visit
    |> Visit.check_out_changeset(attrs)
    |> Repo.update()
    |> preload_result()
  end

  @doc """
  Adjusts a visit's check-in / check-out timestamps.
  """
  def update_visit_times(%Visit{} = visit, attrs) do
    visit
    |> Visit.times_changeset(attrs)
    |> Repo.update()
    |> preload_result()
  end

  @doc """
  Deletes a visit.
  """
  def delete_visit(%Visit{} = visit) do
    Repo.delete(visit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking check-in changes.
  """
  def change_check_in(%Visit{} = visit, attrs \\ %{}) do
    Visit.check_in_changeset(visit, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for adjusting a visit's timestamps.
  """
  def change_visit_times(%Visit{} = visit, attrs \\ %{}) do
    Visit.times_changeset(visit, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking check-out changes.
  """
  def change_check_out(%Visit{} = visit, attrs \\ %{}) do
    Visit.check_out_changeset(visit, attrs)
  end

  # Adds a default timestamp when the caller didn't supply one. Ecto's `cast`
  # rejects maps that mix atom and string keys, so we insert using whichever
  # key style the incoming params already use (form params are string-keyed).
  defp put_default_timestamp(attrs, key) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    string_key = to_string(key)

    cond do
      present?(Map.get(attrs, key)) -> attrs
      present?(Map.get(attrs, string_key)) -> attrs
      Enum.any?(Map.keys(attrs), &is_atom/1) -> Map.put(attrs, key, now)
      true -> Map.put(attrs, string_key, now)
    end
  end

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?(_), do: true

  defp preload_result({:ok, visit}), do: {:ok, Repo.preload(visit, @preloads)}
  defp preload_result(other), do: other
end
