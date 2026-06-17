defmodule Pawzitively.Visits.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :checked_in_at, :utc_datetime
    field :checked_out_at, :utc_datetime

    belongs_to :pet, Pawzitively.Pets.Pet
    belongs_to :checked_in_by_owner, Pawzitively.Owners.Owner
    belongs_to :checked_out_by_owner, Pawzitively.Owners.Owner
    belongs_to :checked_in_by_employee, Pawzitively.Employees.Employee
    belongs_to :checked_out_by_employee, Pawzitively.Employees.Employee

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for checking a pet in.
  """
  def check_in_changeset(visit, attrs) do
    visit
    |> cast(attrs, [
      :pet_id,
      :checked_in_by_owner_id,
      :checked_in_by_employee_id,
      :checked_in_at
    ])
    |> validate_required([
      :pet_id,
      :checked_in_by_owner_id,
      :checked_in_by_employee_id,
      :checked_in_at
    ])
    |> assoc_constraint(:pet)
    |> assoc_constraint(:checked_in_by_owner)
    |> assoc_constraint(:checked_in_by_employee)
    |> unique_constraint(:pet_id,
      name: :visits_active_pet_index,
      message: "is already checked in"
    )
  end

  @doc """
  Changeset for checking a pet out.
  """
  def check_out_changeset(visit, attrs) do
    visit
    |> cast(attrs, [
      :checked_out_by_owner_id,
      :checked_out_by_employee_id,
      :checked_out_at
    ])
    |> validate_required([
      :checked_out_by_owner_id,
      :checked_out_by_employee_id,
      :checked_out_at
    ])
    |> validate_checked_out_after_checked_in()
    |> assoc_constraint(:checked_out_by_owner)
    |> assoc_constraint(:checked_out_by_employee)
  end

  @doc """
  Changeset for manually adjusting a visit's check-in / check-out timestamps.

  The check-out time is optional (an active visit has none yet), but when
  present it must fall after the check-in time.
  """
  def times_changeset(visit, attrs) do
    visit
    |> cast(attrs, [:checked_in_at, :checked_out_at])
    |> validate_required([:checked_in_at])
    |> validate_checked_out_after_checked_in()
  end

  defp validate_checked_out_after_checked_in(changeset) do
    checked_in_at = get_field(changeset, :checked_in_at)
    checked_out_at = get_field(changeset, :checked_out_at)

    if checked_in_at && checked_out_at &&
         DateTime.compare(checked_out_at, checked_in_at) == :lt do
      add_error(changeset, :checked_out_at, "must be after check-in time")
    else
      changeset
    end
  end
end
