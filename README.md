# DeltaCheck

Write thorough tests by making assertions on exactly what you insert, update and delete in the database. Here's an example:

```elixir
test "create a user" do
  assert_changes(insert: %User{name: "John Doe"}) do
    Accounts.create_user(%{name: "John Doe"})
  end
end
```

DeltaCheck provides a concise API for tracking and asserting on what changes your code makes and doesn't make in the database. Use it to make sure:

* the entries you expect to be inserted are inserted,
* the fields you expect to be updated are updated with their expected values,
* the entries you expect to be deleted are deleted,
* and nothing else happens in the database.

## Installation

Add `:delta_check` to your `mix.exs`:

```elixir
{:delta_check, "~> 0.1"}
```

In your `test_helper.exs`, let DeltaCheck know which repo and schemas to use by default:

```elixir
Application.put_all_env(
  delta_check: [repo: MyApp.Repo, schemas: DeltaCheck.get_schemas(:my_app)]
)
```

`DeltaCheck.get_schemas/1` will find all Ecto schemas in your application. But you can of course also provide them manually, e.g.: `schemas: [MyApp.Foo, MyApp.Bar]`.

Finally, if you want to, you can add DeltaCheck to your case templates, like `MyApp.DataCase` and `MyApp.ConnCase`:

```elixir
import DeltaCheck
```

## Usage

_For more examples and the rationale behind DeltaCheck, visit the [guide](GUIDE.md)._

In your tests, you'll primarly use `DeltaCheck.assert_changes/3`, `DeltaCheck.assert_no_changes/2` and `DeltaCheck.track_changes/2`. Since both `assert_changes` and `assert_no_changes` are macros that build upon `track_changes`, let's start with an explanation of the latter.

### Deltas and `track_changes`

`track_changes` takes and invokes a function, and returns a tuple containing the return value of the function and a database delta. For example:

```elixir
{return_value, delta} = track_changes(fn ->
  Accounts.delete_user_by_id(1)
  Accounts.create_user(%{name: "John Doe"})

  :some_return_value
end)

assert return_value == :some_return_value
assert [insert: %User{name: "John Doe"}, delete: %User{id: 1}] = delta
```

The delta is produced by comparing snapshots of the database before and after the function invocation. The delta is a keyword list, where the keys are `:insert`, `:update` or `:delete`, and the values contain the respective schema structs.

```elixir
[
  insert: %User{name: "New user"},
  update: {%User{id: ^updated_user_id}, name: {"Old name", "New name"}},
  delete: %User{id: ^deleted_user_id}
]
```

`:insert`s always come first, then `:update`s and then `:delete`s. Furthermore, the delta is ordered by schema name and finally the primary key.

`:update` is a little bit different, since it doesn't only contain the schema struct of the entry that was updated. Instead, it's a tuple where the first item is the schema struct, and the second item is a keyword list with the fields that where updated. This way you can assert that only the fields you expected to be updated were updated.

`track_changes` should cover all your database assertion needs. But to make your tests just a little bit cleaner, two macros are also provided.

### `assert_changes` and `assert_no_changes`

Most uses of `track_changes` will follow the same pattern, where the delta is bound to something called `delta`, which is then asserted on like this: `assert [...] = delta`. To make this pattern a little bit cleaner, DeltaCheck provides `assert_changes`, which does both things at once:

```elixir
assert_changes(insert: %User{name: "John Doe"}) do
  Accounts.create_user(%{name: "John Doe"})
end

# Which is equivalent to:

{_, delta} = track_changes(fn ->
  Accounts.create_user(%{name: "John Doe"})
end)

assert [insert: %User{name: "John Doe"}] = delta
```

Likewise, when you need to assert that nothing happened in the database, `assert_no_changes` is helpful:

```elixir
assert_no_changes do
  Accounts.create_user(%{name: nil})
end

# Which is equivalent to:

{_, delta} = track_changes(fn ->
  Accounts.create_user(%{name: nil})
end)

assert [] = delta
```

With that said, there are use cases for `track_changes`, where `assert_changes` and `assert_no_changes` won't work. One example is when you need to dynamically make assertions on the delta:

```elixir
{_, delta} = track_changes(fn ->
  for _ <- 1..1_000 do
    Accounts.create_user(%{name: "John Doe"})
  end
end)

assert Enum.count(delta) == 1_000
```

## Caveats

### Tables without a primary key

DeltaCheck currently only works with Ecto schemas that have a primary key defined. This is not a fundamental limitation, though; a fix is being worked on.

### Performance

DeltaCheck generates deltas by taking snapshots of the database and comparing them. This means that DeltaCheck will take a lot of snapshots throughout your test suite, which depending on your application might be a performance problem.

If you have less than roughly 20 Ecto schemas defined in your application, the performance penalty is likely going to be negligible. But if you have more than that, it might be worthwhile to configure DeltaCheck to only use a subset of your schemas, or explicitly provide the relevant schemas for each test.

Alternatively, you can configure DeltaCheck to use a custom `DeltaCheck.SnapshotStrategy`, which suits your application better than the default `DeltaCheck.SnapshotStrategy.RepoAll`.

## License

DeltaCheck is released under the MIT license. See the [LICENSE](LICENSE) file for more information.

## About Striver

DeltaCheck is brought to you by [Striver](https://striver.se), a development consultancy in Sweden. Let us know if we can help you with your Elixir project.
