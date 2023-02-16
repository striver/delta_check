defmodule DeltaCheck.SnapshotStrategy do
  @moduledoc """
  A snapshot strategy is a function, `snapshot/2`, that takes an Ecto repo and a
  list of Ecto schemas, and returns a snapshot of the database in the expected
  format.

  The default implementation is `DeltaCheck.SnapshotStrategy.RepoAll`, but you
  can configure DeltaCheck to use your own custom snapshot strategy in the
  application environment:

      Application.put_env(:delta_check, :snapshot_strategy, MySnapshotStrategy)
  """

  @doc """
  Returns a snapshot of the given Ecto schemas, using the given Ecto
  repo. Here's an example of the expected format of the snapshot:

      %{
        SchemaA => %{
          1 => %SchemaA{field: "foo", id: 1}
        },
        SchemaB => %{
          1 => %SchemaB{field: "bar", id: 1},
          2 => %SchemaB{field: "baz", id: 2}
        }
      }
  """
  @callback snapshot(repo :: Ecto.Repo.t(), schemas :: [module()]) :: DeltaCheck.snapshot()
end
