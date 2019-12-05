defmodule Advent.Day5b do
  @moduledoc """
  Day 5: Sunny with a Chance of Asteroids
  Enhanced OpCode Computer
  Alternate Version refactored after initial submission
  """

  def run_diagnostics() do
    mem = Advent.Data.read_integers("data/day5.txt")
    run(%{mem: mem, ptr: 0})
  end

  def run(%{mem: mem, ptr: ptr} = state) do
    [opcode | params] = Enum.slice(mem, ptr..-1)

    [pad(opcode) | params]
    |> process(state)
    |> case do
      {:ok, state} -> run(state)
      {:stop, reason, state} -> terminate(reason, state)
    end
  end

  def terminate(reason, state) do
    IO.inspect(state)
    IO.inspect(reason)
  end

  def process(["00099" | _], state) do
    {:stop, :halt, state}
  end

  def process(
        [
          <<_a::bytes-size(1)>> <> <<b::bytes-size(1)>> <> <<c::bytes-size(1)>> <> "01",
          p1,
          p2,
          dest | _
        ],
        %{mem: mem, ptr: ptr}
      ) do
    mem = compute(mem, {c, p1}, {b, p2}, dest, &Kernel.+/2)
    {:ok, %{mem: mem, ptr: ptr + 4}}
  end

  def process(
        [
          <<_a::bytes-size(1)>> <> <<b::bytes-size(1)>> <> <<c::bytes-size(1)>> <> "02",
          p1,
          p2,
          dest | _
        ],
        %{mem: mem, ptr: ptr}
      ) do
    mem = compute(mem, {c, p1}, {b, p2}, dest, &Kernel.*/2)
    {:ok, %{mem: mem, ptr: ptr + 4}}
  end

  def process(["00003", dest | _], %{mem: mem, ptr: ptr}) do
    mem = input(mem, dest)
    {:ok, %{mem: mem, ptr: ptr + 2}}
  end

  def process(
        [
          <<_a::bytes-size(1)>> <> <<_b::bytes-size(1)>> <> <<c::bytes-size(1)>> <> "04",
          source | _
        ],
        %{mem: mem, ptr: ptr}
      ) do
    mem = output(mem, {c, source})
    {:ok, %{mem: mem, ptr: ptr + 2}}
  end

  def process(
        [
          <<_a::bytes-size(1)>> <> <<b::bytes-size(1)>> <> <<c::bytes-size(1)>> <> "05",
          check,
          jmp | _
        ],
        state
      ) do
    state = jump_true(state, {c, check}, {b, jmp})
    {:ok, state}
  end

  def process(
        [
          <<_a::bytes-size(1)>> <> <<b::bytes-size(1)>> <> <<c::bytes-size(1)>> <> "06",
          check,
          jmp | _
        ],
        state
      ) do
    state = jump_false(state, {c, check}, {b, jmp})
    {:ok, state}
  end

  def process(
        [
          <<_a::bytes-size(1)>> <> <<b::bytes-size(1)>> <> <<c::bytes-size(1)>> <> "07",
          p1,
          p2,
          dest | _
        ],
        %{mem: mem, ptr: ptr}
      ) do
    mem = set_boolean(mem, {c, p1}, {b, p2}, dest, &Kernel.</2)
    {:ok, %{mem: mem, ptr: ptr + 4}}
  end

  def process(
        [
          <<_a::bytes-size(1)>> <> <<b::bytes-size(1)>> <> <<c::bytes-size(1)>> <> "08",
          p1,
          p2,
          dest | _
        ],
        %{mem: mem, ptr: ptr}
      ) do
    mem = set_boolean(mem, {c, p1}, {b, p2}, dest, &Kernel.==/2)
    {:ok, %{mem: mem, ptr: ptr + 4}}
  end

  def process(instruction, state) do
    {:stop, instruction, state}
  end

  def pad(opcode) when opcode < 10, do: "0000#{opcode}"
  def pad(opcode) when opcode < 100, do: "000#{opcode}"
  def pad(opcode) when opcode < 1000, do: "00#{opcode}"
  def pad(opcode) when opcode < 10000, do: "0#{opcode}"
  def pad(opcode), do: to_string(opcode)

  def compute(mem, p1, p2, dest, operation) do
    value = operation.(lookup(mem, p1), lookup(mem, p2))
    List.replace_at(mem, dest, value)
  end

  def set_boolean(mem, p1, p2, dest, operation) do
    if operation.(lookup(mem, p1), lookup(mem, p2)) do
      List.replace_at(mem, dest, 1)
    else
      List.replace_at(mem, dest, 0)
    end
  end

  def jump_true(%{mem: mem, ptr: ptr}, check, jmp) do
    case lookup(mem, check) do
      0 ->
        %{mem: mem, ptr: ptr + 3}

      _ ->
        %{mem: mem, ptr: lookup(mem, jmp)}
    end
  end

  def jump_false(%{mem: mem, ptr: ptr}, check, jmp) do
    case lookup(mem, check) do
      0 ->
        %{mem: mem, ptr: lookup(mem, jmp)}

      _ ->
        %{mem: mem, ptr: ptr + 3}
    end
  end

  def input(mem, dest) do
    IO.write("input> ")

    value =
      IO.read(:stdio, :line)
      |> String.trim()
      |> String.to_integer()

    List.replace_at(mem, dest, value)
  end

  def output(mem, source) do
    mem
    |> lookup(source)
    |> IO.puts()

    mem
  end

  def lookup(mem, {"0", loc}), do: Enum.at(mem, loc)
  def lookup(_, {"1", val}), do: val
end
