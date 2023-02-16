defmodule DeltaCheck.TestSchemas.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field(:name, :string)
  end

  def changeset(user, attrs) do
    cast(user, attrs, [:name])
    |> validate_required([:name])
  end
end
