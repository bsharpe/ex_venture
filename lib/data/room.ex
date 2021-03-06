defmodule Data.Room do
  @moduledoc """
  Room Schema
  """

  use Data.Schema

  alias Data.Exit
  alias Data.Item
  alias Data.Shop
  alias Data.Zone

  @ecologies [
    "default",
    "ocean",
    "river",
    "lake",
    "forest",
    "jungle",
    "town",
    "inside",
    "road",
    "hill",
    "mountain",
    "field",
    "meadow",
    "dungeon"
  ]

  schema "rooms" do
    field(:name, :string)
    field(:description, :string)
    field(:currency, :integer)
    field(:items, {:array, Item.Instance})

    field(:players, {:array, :tuple}, virtual: true)

    field(:x, :integer)
    field(:y, :integer)
    field(:map_layer, :integer)
    field(:is_zone_exit, :boolean)
    field(:is_graveyard, :boolean, default: false)
    field(:ecology, :string)
    field(:notes, :string)

    field(:exits, {:array, Exit}, virtual: true)

    has_many(:npc_spawners, Data.NPCSpawner)
    has_many(:room_items, Data.RoomItem)
    has_many(:shops, Shop)

    belongs_to(:zone, Zone)

    timestamps()
  end

  def ecologies(), do: @ecologies

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :zone_id,
      :name,
      :description,
      :x,
      :y,
      :map_layer,
      :is_zone_exit,
      :is_graveyard,
      :ecology,
      :currency,
      :items,
      :notes
    ])
    |> ensure_items
    |> ensure(:currency, 0)
    |> ensure(:ecology, "default")
    |> validate_required([
      :zone_id,
      :name,
      :description,
      :currency,
      :x,
      :y,
      :map_layer,
      :ecology,
      :is_graveyard
    ])
    |> validate_inclusion(:ecology, @ecologies)
  end

  def exits(room) do
    ["north", "east", "south", "west", "up", "down"]
    |> Enum.filter(fn direction ->
      Exit.exit_to(room, direction)
    end)
  end

  defp ensure_items(changeset) do
    case changeset do
      %{changes: %{items: _ids}} -> changeset
      %{data: %{items: ids}} when ids != nil -> changeset
      _ -> put_change(changeset, :items, [])
    end
  end
end
