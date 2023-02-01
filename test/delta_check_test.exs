defmodule DeltaCheckTest do
  use DeltaCheck.EctoCase
  use ExUnit.Case

  import DeltaCheck

  alias DeltaCheck.TestRepo
  alias DeltaCheck.TestSchemas.OtherText
  alias DeltaCheck.TestSchemas.Text
  alias DeltaCheck.TestSchemas.TextWithoutPrimaryKey
  alias DeltaCheck.TestSchemas.Type

  doctest DeltaCheck

  describe "assert_changes" do
    test "expected changes" do
      result =
        assert_changes(
          [insert: %Text{text: "foo"}],
          schemas: [Text]
        ) do
          TestRepo.insert(%Text{text: "foo"})
        end

      assert {:ok, _} = result
    end

    test "unexpected changes" do
      assert_raise ExUnit.AssertionError, fn ->
        assert_changes(
          [insert: %Text{text: "bar"}],
          schemas: [Text]
        ) do
          TestRepo.insert(%Text{text: "foo"})
        end
      end
    end
  end

  describe "assert_no_changes" do
    test "no changes" do
      result =
        assert_no_changes(schemas: [Text]) do
          "some result"
        end

      assert result == "some result"
    end

    test "changes" do
      assert_raise ExUnit.AssertionError, fn ->
        assert_no_changes(schemas: [Text]) do
          TestRepo.insert(%Text{text: "foo"})
        end
      end
    end
  end

  describe "compare" do
    test "no changes" do
      snapshot = %{Text => %{1 => %Text{id: 1, text: "foo"}}}

      assert compare(snapshot, snapshot) == []
    end

    test "insert" do
      assert [insert: %Text{text: "foo"}] =
               compare(%{}, %{Text => %{1 => %Text{id: 1, text: "foo"}}})
    end

    test "update" do
      assert(
        [
          update: {%Text{id: 1}, text: {"foo", "bar"}}
        ] =
          compare(
            %{Text => %{1 => %Text{id: 1, text: "foo"}}},
            %{Text => %{1 => %Text{id: 1, text: "bar"}}}
          )
      )
    end

    test "delete" do
      assert(
        [
          delete: %Text{id: 1}
        ] =
          compare(
            %{Text => %{1 => %Text{id: 1, text: "foo"}}},
            %{}
          )
      )
    end

    test "insert, update and delete" do
      assert(
        [
          insert: %Text{id: 3, text: "qux"},
          update: {%Text{id: 2}, [text: {"bar", "baz"}]},
          delete: %Text{id: 1}
        ] =
          compare(
            %{
              Text => %{
                1 => %Text{id: 1, text: "foo"},
                2 => %Text{id: 2, text: "bar"}
              }
            },
            %{
              Text => %{
                2 => %Text{id: 2, text: "baz"},
                3 => %Text{id: 3, text: "qux"}
              }
            }
          )
      )
    end

    test "multiple schemas" do
      assert(
        [
          insert: %OtherText{text: "baz"},
          update: {%Text{id: 1}, [text: {"foo", "bar"}]}
        ] =
          compare(
            %{
              Text => %{
                1 => %Text{id: 1, text: "foo"}
              }
            },
            %{
              OtherText => %{
                2 => %OtherText{id: 2, text: "baz"}
              },
              Text => %{
                1 => %Text{id: 1, text: "bar"}
              }
            }
          )
      )
    end
  end

  describe "get_schemas" do
    test "application with schemas" do
      assert get_schemas(:delta_check) == [OtherText, Text, Type]
    end

    test "application without schemas" do
      # Jason won't be an avid consumer of `Ecto.Schema` anytime soon.
      assert get_schemas(:jason) == []
    end

    test "application that doesn't exist" do
      assert_raise(
        RuntimeError,
        "application does not exist: application_that_does_not_exist",
        fn ->
          get_schemas(:application_that_does_not_exist)
        end
      )
    end
  end

  describe "snapshot" do
    test "no schemas" do
      assert snapshot(schemas: []) == %{}
    end

    test "empty table" do
      TestRepo.delete_all(Text)

      assert snapshot(schemas: [Text]) == %{Text => %{}}
    end

    test "all types" do
      {:ok, type} =
        TestRepo.insert(%Type{
          array: ["foo", "bar", "baz"],
          binary: <<1, 2, 3>>,
          boolean: true,
          date: Date.new!(2021, 2, 3),
          decimal: Decimal.new("1.23"),
          float: 1.23,
          integer: 123,
          map: %{"array" => ["foo", "bar", "maz"], "map" => %{"key" => "value"}},
          naive_datetime: NaiveDateTime.new!(2021, 2, 3, 4, 5, 6, 7),
          null: nil,
          string: "foo",
          text: "bar",
          time: Time.new!(1, 2, 3, 4),
          utc_datetime:
            DateTime.new!(
              Date.new!(2021, 2, 3),
              Time.new!(1, 2, 3, 4)
            )
        })

      assert(
        snapshot(schemas: [Type]) ==
          %{
            Type => %{
              type.id => %Type{
                type
                | array: ["foo", "bar", "baz"],
                  binary: <<1, 2, 3>>,
                  boolean: true,
                  date: Date.new!(2021, 2, 3),
                  decimal: Decimal.new("1.23"),
                  float: 1.23,
                  integer: 123,
                  map: %{"array" => ["foo", "bar", "maz"], "map" => %{"key" => "value"}},
                  naive_datetime: NaiveDateTime.new!(2021, 2, 3, 4, 5, 6, 7),
                  null: nil,
                  string: "foo",
                  text: "bar",
                  time: Time.new!(1, 2, 3, 4),
                  utc_datetime:
                    DateTime.new!(
                      Date.new!(2021, 2, 3),
                      Time.new!(1, 2, 3, 4)
                    )
              }
            }
          }
      )
    end

    test "multiple records" do
      TestRepo.delete_all(Text)

      {:ok, foo} = TestRepo.insert(%Text{text: "foo"})
      {:ok, bar} = TestRepo.insert(%Text{text: "bar"})
      {:ok, baz} = TestRepo.insert(%Text{text: "baz"})

      assert(
        snapshot(schemas: [Text]) ==
          %{
            Text => %{
              foo.id => %Text{foo | text: "foo"},
              bar.id => %Text{bar | text: "bar"},
              baz.id => %Text{baz | text: "baz"}
            }
          }
      )
    end

    test "multiple schemas" do
      TestRepo.delete_all(OtherText)
      TestRepo.delete_all(Text)

      {:ok, text} = TestRepo.insert(%Text{text: "foo"})
      {:ok, other_text} = TestRepo.insert(%OtherText{text: "bar"})

      assert(
        snapshot(schemas: [OtherText, Text]) ==
          %{
            OtherText => %{other_text.id => %OtherText{other_text | text: "bar"}},
            Text => %{text.id => %Text{text | text: "foo"}}
          }
      )
    end

    test "schema without primary key" do
      assert_raise(
        RuntimeError,
        ~r/schema does not have a primary key: Elixir\.DeltaCheck\.TestSchemas\.TextWithoutPrimaryKey/,
        fn ->
          snapshot(schemas: [TextWithoutPrimaryKey])
        end
      )
    end

    @tag :benchmark
    test "benchmark" do
      # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
      schema_count = 100
      schemas = for n <- 1..schema_count, do: :"Elixir.DeltaCheck.TestSchemas.BenchmarkText#{n}"
      text = for _ <- 1..1024, do: "a", into: ""
      texts = for _ <- 1..10, do: [text: text]

      Enum.each(schemas, fn schema ->
        table =
          schema |> Atom.to_string() |> String.split(".") |> List.last() |> Macro.underscore()

        Module.create(
          schema,
          quote do
            use Ecto.Schema

            schema unquote(table) do
              field(:text, :string)
            end
          end,
          Macro.Env.location(__ENV__)
        )

        Ecto.Adapters.SQL.query(
          TestRepo,
          """
          create table #{table} (
            id serial,
            text text not null
          )
          """
        )

        TestRepo.insert_all(schema, texts)
      end)

      Benchee.run(%{
        "#{schema_count} schemas" => fn ->
          assert snapshot(schemas: schemas) |> Enum.count() == schema_count
        end
      })

      Enum.each(schemas, fn schema ->
        :code.delete(schema)
        :code.purge(schema)
      end)
    end
  end

  describe "track_changes" do
    test "no schemas" do
      assert(
        {"some result", []} =
          track_changes(fn ->
            {:ok, _} = TestRepo.insert(%Text{text: "foo"})
            "some result"
          end)
      )
    end

    test "no changes" do
      assert(
        {:ok, []} =
          track_changes(
            fn -> :ok end,
            schemas: [Text]
          )
      )
    end

    test "insert" do
      assert(
        {{:ok, _}, [insert: %Text{text: "foo"}]} =
          track_changes(
            fn ->
              TestRepo.insert(%Text{text: "foo"})
            end,
            schemas: [Text]
          )
      )
    end

    test "update" do
      {:ok, text = %{id: id}} = TestRepo.insert(%Text{text: "foo"})

      assert(
        {{:ok, _}, [update: {%Text{id: ^id}, text: {"foo", "bar"}}]} =
          track_changes(
            fn ->
              Ecto.Changeset.change(text, text: "bar")
              |> TestRepo.update()
            end,
            schemas: [Text]
          )
      )
    end

    test "delete" do
      {:ok, text = %{id: id}} = TestRepo.insert(%Text{text: "foo"})

      assert(
        {{:ok, _}, [delete: %Text{id: ^id}]} =
          track_changes(
            fn ->
              TestRepo.delete(text)
            end,
            schemas: [Text]
          )
      )
    end

    test "insert, update and delete" do
      {:ok, delete = %{id: delete_id}} = TestRepo.insert(%Text{text: "foo"})
      {:ok, update = %{id: update_id}} = TestRepo.insert(%Text{text: "bar"})

      assert(
        {
          {:ok, _},
          [
            insert: %Text{text: "qux"},
            update: {%Text{id: ^update_id}, text: {"bar", "baz"}},
            delete: %Text{id: ^delete_id}
          ]
        } =
          track_changes(
            fn ->
              TestRepo.insert(%Text{text: "qux"})

              Ecto.Changeset.change(update, text: "baz")
              |> TestRepo.update()

              TestRepo.delete(delete)
            end,
            schemas: [Text]
          )
      )
    end

    test "multiple schemas" do
      {:ok, update = %{id: update_id}} = TestRepo.insert(%Text{text: "foo"})

      assert(
        {
          {:ok, _},
          [
            insert: %OtherText{text: "baz"},
            update: {%Text{id: ^update_id}, text: {"foo", "bar"}}
          ]
        } =
          track_changes(
            fn ->
              TestRepo.insert(%OtherText{text: "baz"})

              Ecto.Changeset.change(update, text: "bar")
              |> TestRepo.update()
            end,
            schemas: [OtherText, Text]
          )
      )
    end
  end
end
