defmodule Game.Session.GMCP do
  @moduledoc """
  Helpers for pushing GMCP data
  """

  use Networking.Socket

  alias Data.Room

  @doc """
  Push Character data (save stats)
  """
  @spec character(map) :: :ok
  def character(%{socket: socket, user: user}) do
    socket |> @socket.push_gmcp("Character", %{name: user.name} |> Poison.encode!())
  end

  @doc """
  Push Character.Vitals data (save stats)
  """
  @spec vitals(map) :: :ok
  def vitals(%{socket: socket, user: user, save: save}) do
    stats =
      save.stats
      |> Map.put(:skill_abbreviation, user.class.points_abbreviation)

    socket |> @socket.push_gmcp("Character.Vitals", stats |> Poison.encode!())
  end

  @doc """
  Push Room.Info data
  """
  @spec room(map, Room.t(), [Item.t()]) :: :ok
  def room(%{socket: socket}, room, items) do
    socket |> @socket.push_gmcp("Room.Info", room |> room_info(items) |> Poison.encode!())
  end

  @doc """
  A character enters a room

  Does not push directly to the socket
  """
  @spec character_enter(map, Character.t()) :: {String.t(), map}
  def character_enter(%{socket: socket}, {:user, user}) do
    socket
    |> @socket.push_gmcp(
      "Room.Character.Enter",
      %{type: :player, id: user.id, name: user.name} |> Poison.encode!()
    )
  end

  def character_enter(%{socket: socket}, {:npc, npc}) do
    socket
    |> @socket.push_gmcp(
      "Room.Character.Enter",
      %{type: :npc, id: npc.id, name: npc.name} |> Poison.encode!()
    )
  end

  @doc """
  A character leaves a room

  Does not push directly to the socket
  """
  @spec character_leave(map, Character.t()) :: {String.t(), map}
  def character_leave(%{socket: socket}, {:user, user}) do
    socket
    |> @socket.push_gmcp(
      "Room.Character.Leave",
      %{type: :player, id: user.id, name: user.name} |> Poison.encode!()
    )
  end

  def character_leave(%{socket: socket}, {:npc, npc}) do
    socket
    |> @socket.push_gmcp(
      "Room.Character.Leave",
      %{type: :npc, id: npc.id, name: npc.name} |> Poison.encode!()
    )
  end

  @doc """
  Send the player's target info
  """
  @spec targeted(map, Character.t()) :: :ok
  def targeted(%{socket: socket}, {:user, user}) do
    socket |> @socket.push_gmcp("Target.Character", user |> user_info() |> Poison.encode!())
  end

  def targeted(%{socket: socket}, {:npc, npc}) do
    socket |> @socket.push_gmcp("Target.Character", npc |> npc_info() |> Poison.encode!())
  end

  @doc """
  Send a target cleared message
  """
  @spec clear_target(map) :: :ok
  def clear_target(%{socket: socket}) do
    socket |> @socket.push_gmcp("Target.Clear", "{}")
  end

  @doc """
  Send a map message
  """
  @spec map(map, String.t()) :: :ok
  def map(%{socket: socket}, map) do
    socket |> @socket.push_gmcp("Zone.Map", %{map: map} |> Poison.encode!())
  end

  defp room_info(room, items) do
    room
    |> Map.take([:name, :description, :ecology, :zone_id, :x, :y])
    |> Map.merge(%{
      items: render_many(items),
      players: render_many(room, :players),
      npcs: render_many(room, :npcs),
      shops: render_many(room, :shops),
      exits: Room.exits(room)
    })
  end

  @doc """
  Gather information for a user
  """
  @spec user_info(User.t()) :: map
  def user_info(user) do
    %{
      type: :player,
      id: user.id,
      name: user.name
    }
  end

  @doc """
  Gather information for a npc
  """
  @spec npc_info(NPC.t()) :: map
  def npc_info(npc) do
    %{
      type: :player,
      id: npc.id,
      name: npc.name
    }
  end

  defp render_many(data) when is_list(data) do
    Enum.map(data, &%{id: &1.id, name: &1.name})
  end

  defp render_many(struct, key) do
    case struct do
      %{^key => data} when data != nil ->
        render_many(data)

      _ ->
        []
    end
  end
end
