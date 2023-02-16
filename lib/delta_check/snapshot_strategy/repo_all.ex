defmodule DeltaCheck.SnapshotStrategy.RepoAll do
  @moduledoc """
  The default snapshot strategy for DeltaCheck. This produces the snapshot by
  running `Ecto.Repo.all` for all provided schemas.
  """

  @behaviour DeltaCheck.SnapshotStrategy

  import Ecto.Query

  @impl DeltaCheck.SnapshotStrategy
  def snapshot(repo, schemas) do
    Enum.into(schemas, %{}, &{&1, get_entries(repo, &1)})
  end

  defp get_entries(repo, schema) do
    primary_key = DeltaCheck.get_primary_key!(schema)

    from(schema, order_by: ^primary_key)
    |> repo.all()
    |> Enum.into(%{}, fn entry ->
      {Map.fetch!(entry, primary_key), entry}
    end)
  end
end
