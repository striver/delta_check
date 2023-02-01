defmodule DeltaCheck.SnapshotStrategy do
  @moduledoc """
  TODO
  """

  @callback snapshot(repo :: Ecto.Repo.t(), schemas :: [module()]) :: %{
              optional(module()) => %{optional(term()) => struct()}
            }
end
