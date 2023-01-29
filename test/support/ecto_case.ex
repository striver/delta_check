defmodule DeltaCheck.EctoCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(DeltaCheck.TestRepo)
  end
end
