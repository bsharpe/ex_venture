defmodule Game.Session.Channels do
  @moduledoc """
  Implementation for channel callbacks
  """

  use Networking.Socket

  alias Game.Session.State

  @doc """
  Call back for joining a channel
  """
  @spec joined(State.t(), String.t()) :: State.t()
  def joined(state = %{save: save}, channel) do
    channels =
      [channel | save.channels]
      |> Enum.into(MapSet.new())
      |> Enum.into([])

    save = %{save | channels: channels}
    %{state | save: save}
  end

  @doc """
  Callback for leaving a channel
  """
  @spec left(State.t(), String.t()) :: State.t()
  def left(state = %{save: save}, channel) do
    channels = Enum.reject(save.channels, &(&1 == channel))
    save = %{save | channels: channels}
    %{state | save: save}
  end

  @doc """
  Callback for receiving a broadcast on a channel
  """
  @spec broadcast(State.t(), Message.t()) :: State.t()
  def broadcast(state = %{socket: socket}, message) do
    socket |> @socket.echo(message)
    state
  end

  @doc """
  Callback for receiving a tell
  """
  @spec tell(State.t(), Character.t(), Message.t()) :: State.t()
  def tell(state = %{socket: socket}, from, message) do
    socket |> @socket.echo(message.formatted)
    Map.put(state, :reply_to, from)
  end
end
