defmodule DeltaCheck.TestSchemas.Type do
  @moduledoc false

  use Ecto.Schema

  schema "types" do
    field(:array, {:array, :string})
    field(:binary, :binary)
    field(:boolean, :boolean)
    field(:date, :date)
    field(:decimal, :decimal)
    field(:float, :float)
    field(:integer, :integer)
    field(:map, :map)
    field(:naive_datetime, :naive_datetime_usec)
    field(:null, :string)
    field(:string, :string)
    field(:text, :string)
    field(:time, :time_usec)
    field(:utc_datetime, :utc_datetime_usec)
  end
end
