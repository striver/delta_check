defmodule DeltaCheck.TestSchemas.OtherText do
  @moduledoc false

  use Ecto.Schema

  schema "other_texts" do
    field(:text, :string)
  end
end
