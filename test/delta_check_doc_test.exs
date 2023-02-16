defmodule DeltaCheckDocTest do
  use DeltaCheck.EctoCase
  use ExUnit.Case

  import DeltaCheck

  # credo:disable-for-next-line Credo.Check.Readability.AliasAs
  alias DeltaCheck.TestRepo, as: Repo
  alias DeltaCheck.TestSchemas.User

  defmodule Accounts do
    def create_user(attrs) do
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()
    end
  end

  setup_all do
    Application.put_env(:delta_check, :schemas, [User])

    on_exit(fn ->
      Application.delete_env(:delta_check, :schemas)
    end)
  end

  doctest DeltaCheck, except: [get_schemas: 1]
end
