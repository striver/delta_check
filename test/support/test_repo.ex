defmodule DeltaCheck.TestRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :delta_check,
    adapter: Ecto.Adapters.Postgres

  alias DeltaCheck.TestRepo
  alias DeltaCheck.TestSchemas.OtherText
  alias DeltaCheck.TestSchemas.Text
  alias DeltaCheck.TestSchemas.TextWithoutPrimaryKey

  def add_noise(seed) do
    :rand.seed(:exsss, {seed, seed, seed})

    Enum.each([OtherText, Text, TextWithoutPrimaryKey], fn schema ->
      StreamData.string(:ascii)
      |> StreamData.list_of()
      |> ExUnitProperties.pick()
      |> Enum.each(fn text ->
        struct(schema, %{text: text})
        |> TestRepo.insert()
      end)
    end)
  end
end
