defmodule DeltaCheck.TestSchemas.Text do
  @moduledoc false

  use Ecto.Schema

  schema "texts" do
    field(:text, :string)
  end
end
