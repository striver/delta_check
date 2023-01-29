defmodule DeltaCheck do
  @moduledoc """
  TODO
  """

  import Ecto.Query
  import ExUnit.Assertions

  defmacro assert_changes(pattern, opts \\ [], do: block) do
    unless Keyword.keyword?(pattern) do
      raise ArgumentError,
            "first argument to `assert_changes` must be a compile time keyword list"
    end

    quote do
      {result, changes} =
        track_changes(
          fn -> unquote(block) end,
          Keyword.take(unquote(opts), [:schemas])
        )

      assert unquote(Keyword.take(pattern, [:insert, :update, :delete])) = changes

      result
    end
  end

  defmacro assert_no_changes(opts \\ [], do: block) do
    quote do
      {result, changes} =
        track_changes(
          fn -> unquote(block) end,
          Keyword.take(unquote(opts), [:schemas])
        )

      assert [] = changes

      result
    end
  end

  def compare(snapshot1, snapshot2) do
    Enum.flat_map(
      Map.keys(snapshot1)
      |> MapSet.new()
      |> MapSet.union(
        Map.keys(snapshot2)
        |> MapSet.new()
      ),
      fn schema ->
        compare(
          schema,
          Map.get(snapshot1, schema, %{}),
          Map.get(snapshot2, schema, %{})
        )
      end
    )
  end

  def compare(schema, snapshot1, snapshot2) do
    ids_before = Map.keys(snapshot1) |> MapSet.new()
    ids_after = Map.keys(snapshot2) |> MapSet.new()

    Enum.concat([
      MapSet.difference(ids_after, ids_before)
      |> Enum.map(fn id ->
        {:insert, snapshot2[id]}
      end),
      MapSet.intersection(ids_before, ids_after)
      |> Enum.filter(fn id ->
        snapshot1[id] != snapshot2[id]
      end)
      |> Enum.map(fn id ->
        changed =
          schema.__schema__(:fields)
          |> Enum.filter(fn field ->
            Map.get(snapshot1[id], field) != Map.get(snapshot2[id], field)
          end)

        {
          :update,
          {
            snapshot2[id],
            Enum.map(changed, fn field ->
              {field, {Map.get(snapshot1[id], field), Map.get(snapshot2[id], field)}}
            end)
          }
        }
      end),
      MapSet.difference(ids_before, ids_after)
      |> Enum.map(fn id ->
        {:delete, snapshot1[id]}
      end)
    ])
  end

  def get_schemas(application) do
    modules =
      case :application.get_key(application, :modules) do
        {:ok, modules} ->
          modules

        :undefined ->
          raise "application does not exist: #{application}"
      end

    Enum.sort(modules)
    |> Enum.filter(fn module ->
      {:__schema__, 1} in module.__info__(:functions) &&
        module.__schema__(:primary_key) |> Enum.count() == 1
    end)
  end

  def snapshot(opts \\ []) do
    Keyword.get(opts, :schemas, Application.get_env(:delta_check, :schemas, []))
    |> Enum.into(%{}, &{&1, get_entries(&1)})
  end

  def track_changes(fun, opts \\ []) do
    snapshot_opts = for {k, v} <- opts, k in [:schemas], do: {k, v}
    before = snapshot(snapshot_opts)
    result = fun.()

    {result, compare(before, snapshot(snapshot_opts))}
  end

  defp get_entries(schema) do
    primary_key =
      case schema.__schema__(:primary_key) do
        [primary_key] ->
          primary_key

        _ ->
          raise "schema does not have a primary key: #{schema} (schemas without primary key will be supported in a future version of DeltaCheck)"
      end

    from(schema, order_by: ^primary_key)
    |> Application.fetch_env!(:delta_check, :repo).all()
    |> Enum.into(%{}, fn entry ->
      {Map.fetch!(entry, primary_key), entry}
    end)
  end
end
