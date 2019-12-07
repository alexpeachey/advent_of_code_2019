defmodule Advent.Day7.IO do
  @moduledoc """
  IO for connecting applifiers
  """
  use GenServer

  def start_link(descriptors) do
    state =
      descriptors
      |> Enum.reduce(%{}, fn d, ds -> Map.put(ds, d, []) end)

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(descriptors) do
    {:ok, descriptors}
  end

  def puts(descriptor, value) do
    GenServer.cast(__MODULE__, {:puts, descriptor, value})
  end

  def read(descriptor, mode, timeout \\ 10_000) do
    read(descriptor, mode, timeout, 0)
  end

  def read(descriptor, _mode, timeout, elapsed) when elapsed > timeout do
    raise "Timeout exceeded on #{descriptor}"
  end

  def read(descriptor, mode, timeout, elapsed) do
    case GenServer.call(__MODULE__, {:read, descriptor}) do
      nil ->
        read(descriptor, mode, timeout, elapsed + 1)

      value ->
        value
    end
  end

  def flush() do
    GenServer.call(__MODULE__, :flush)
  end

  def handle_cast({:puts, descriptor, value}, descriptors) do
    buffer = descriptors[descriptor]
    {:noreply, Map.put(descriptors, descriptor, ["#{value}\n" | buffer])}
  end

  def handle_call({:read, descriptor}, _from, descriptors) do
    case Enum.reverse(descriptors[descriptor]) do
      [head | tail] ->
        {:reply, head, Map.put(descriptors, descriptor, Enum.reverse(tail))}

      [] ->
        {:reply, nil, descriptors}
    end
  end

  def handle_call(:flush, _from, descriptors) do
    cleared =
      descriptors
      |> Enum.map(fn {descriptor, _} -> {descriptor, []} end)
      |> Enum.into(%{})

    {:reply, :ok, cleared}
  end
end
