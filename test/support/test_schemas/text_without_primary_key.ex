defmodule DeltaCheck.TestSchemas.TextWithoutPrimaryKey do
  @moduledoc false

  use Ecto.Schema

  @primary_key false

  schema "texts_without_primary_key" do
    field(:text, :string)
  end
end
