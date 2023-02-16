defmodule DeltaCheck.TestRepo.Migrations.All do
  use Ecto.Migration

  def change do
    create table(:other_texts) do
      add(:text, :text, null: false)
    end

    create table(:texts) do
      add(:text, :text, null: false)
    end

    create table(:texts_without_primary_key, primary_key: false) do
      add(:text, :text, null: false)
    end

    create table(:types) do
      add(:array, {:array, :text})
      add(:binary, :binary)
      add(:boolean, :boolean)
      add(:date, :date)
      add(:decimal, :decimal)
      add(:float, :float)
      add(:integer, :integer)
      add(:map, :map)
      add(:naive_datetime, :naive_datetime_usec)
      add(:null, :text)
      add(:string, :string)
      add(:text, :text)
      add(:time, :time_usec)
      add(:utc_datetime, :utc_datetime_usec)
    end

    create table(:users) do
      add(:name, :text, null: false)
    end
  end
end
