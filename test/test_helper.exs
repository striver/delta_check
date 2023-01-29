Mix.Task.run("ecto.drop", ["--force-drop", "--quiet", "-r", "DeltaCheck.TestRepo"])
Mix.Task.run("ecto.create", ["--quiet", "-r", "DeltaCheck.TestRepo"])
Mix.Task.run("ecto.migrate", ["--quiet", "-r", "DeltaCheck.TestRepo"])

DeltaCheck.TestRepo.start_link()

configuration = ExUnit.configuration()

if :benchmark not in Keyword.fetch!(configuration, :include) do
  Keyword.fetch!(configuration, :seed)
  |> DeltaCheck.TestRepo.add_noise()
end

ExUnit.start(exclude: [:benchmark])
Ecto.Adapters.SQL.Sandbox.mode(DeltaCheck.TestRepo, :manual)
