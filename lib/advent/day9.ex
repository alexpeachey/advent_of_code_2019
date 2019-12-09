defmodule Advent.Day9 do
  @moduledoc """
  Day 9: Sensor Boost
  Enhanced OpCode Computer
  """
  alias Advent.Day7.IO

  def find_boost_keycode() do
    IO.start_link([:stdin, :stdout])
    mem = Advent.Data.read_integers("data/day9.txt")
    IO.puts(:stdin, 1)
    run(%{mem: mem, ptr: 0, base: 0, in: :stdin, out: :stdout})

    IO.read(:stdout, :line)
    |> String.trim()
    |> String.to_integer()
  end

  def lock_on_distress_signal() do
    IO.start_link([:stdin, :stdout])
    mem = Advent.Data.read_integers("data/day9.txt")
    IO.puts(:stdin, 2)
    run(%{mem: mem, ptr: 0, base: 0, in: :stdin, out: :stdout})

    IO.read(:stdout, :line)
    |> String.trim()
    |> String.to_integer()
  end

  def run(%{mem: mem, ptr: ptr} = state) do
    [opcode | params] = Enum.slice(mem, ptr..-1)

    [parse(pad(opcode)) | params]
    |> process(state)
    |> case do
      {:ok, state} -> run(state)
      {:stop, reason, state} -> terminate(reason, state)
    end
  end

  def terminate(reason, state) do
    # Elixir.IO.inspect(state)
    # Elixir.IO.inspect(reason)
  end

  def process([{_a, _b, _c, "99"} | _], state) do
    {:stop, :halt, state}
  end

  def process([{a, b, c, "01"}, p1, p2, dest | _], state) do
    {:ok, compute(state, {c, p1}, {b, p2}, abs_dest(state, {a, dest}), &Kernel.+/2)}
  end

  def process([{a, b, c, "02"}, p1, p2, dest | _], state) do
    {:ok, compute(state, {c, p1}, {b, p2}, abs_dest(state, {a, dest}), &Kernel.*/2)}
  end

  def process([{_a, _b, c, "03"}, dest | _], state) do
    {:ok, input(state, abs_dest(state, {c, dest}))}
  end

  def process([{_a, _b, c, "04"}, source | _], state) do
    {:ok, output(state, {c, source})}
  end

  def process([{_a, b, c, "05"}, check, jmp | _], state) do
    {:ok, jump_true(state, {c, check}, {b, jmp})}
  end

  def process([{_a, b, c, "06"}, check, jmp | _], state) do
    {:ok, jump_false(state, {c, check}, {b, jmp})}
  end

  def process([{a, b, c, "07"}, p1, p2, dest | _], state) do
    {:ok, set_boolean(state, {c, p1}, {b, p2}, abs_dest(state, {a, dest}), &Kernel.</2)}
  end

  def process([{a, b, c, "08"}, p1, p2, dest | _], state) do
    {:ok, set_boolean(state, {c, p1}, {b, p2}, abs_dest(state, {a, dest}), &Kernel.==/2)}
  end

  def process([{_a, _b, c, "09"}, loc | _], state) do
    {:ok, update_base(state, {c, loc})}
  end

  def process(instruction, state) do
    {:stop, instruction, state}
  end

  def pad(opcode) when opcode < 10, do: "0000#{opcode}"
  def pad(opcode) when opcode < 100, do: "000#{opcode}"
  def pad(opcode) when opcode < 1000, do: "00#{opcode}"
  def pad(opcode) when opcode < 10000, do: "0#{opcode}"
  def pad(opcode), do: to_string(opcode)

  def parse(<<a::bytes-size(1)>> <> <<b::bytes-size(1)>> <> <<c::bytes-size(1)>> <> opcode) do
    {a, b, c, opcode}
  end

  def set_at(mem, loc, val) when length(mem) <= loc do
    mem = malloc(mem, loc - length(mem) + 1)
    set_at(mem, loc, val)
  end

  def set_at(mem, loc, val) do
    List.replace_at(mem, loc, val)
  end

  def malloc(mem, size) do
    mem ++ Enum.map(0..size, fn _ -> 0 end)
  end

  def compute(%{mem: mem, ptr: ptr, base: base} = state, p1, p2, dest, operation) do
    value = operation.(lookup(mem, base, p1), lookup(mem, base, p2))
    mem = set_at(mem, dest, value)
    Map.merge(state, %{mem: mem, ptr: ptr + 4})
  end

  def set_boolean(%{mem: mem, ptr: ptr, base: base} = state, p1, p2, dest, operation) do
    mem =
      if operation.(lookup(mem, base, p1), lookup(mem, base, p2)) do
        set_at(mem, dest, 1)
      else
        set_at(mem, dest, 0)
      end

    Map.merge(state, %{mem: mem, ptr: ptr + 4})
  end

  def jump_true(%{mem: mem, ptr: ptr, base: base} = state, check, jmp) do
    case lookup(mem, base, check) do
      0 ->
        Map.merge(state, %{mem: mem, ptr: ptr + 3})

      _ ->
        Map.merge(state, %{mem: mem, ptr: lookup(mem, base, jmp)})
    end
  end

  def jump_false(%{mem: mem, ptr: ptr, base: base} = state, check, jmp) do
    case lookup(mem, base, check) do
      0 ->
        Map.merge(state, %{mem: mem, ptr: lookup(mem, base, jmp)})

      _ ->
        Map.merge(state, %{mem: mem, ptr: ptr + 3})
    end
  end

  def input(%{mem: mem, ptr: ptr, in: io} = state, dest) do
    value =
      IO.read(io, :line)
      |> String.trim()
      |> String.to_integer()

    mem = set_at(mem, dest, value)
    Map.merge(state, %{mem: mem, ptr: ptr + 2})
  end

  def output(%{mem: mem, ptr: ptr, base: base, out: io} = state, source) do
    value = lookup(mem, base, source)
    IO.puts(io, value)
    Map.merge(state, %{ptr: ptr + 2})
  end

  def update_base(%{mem: mem, ptr: ptr, base: base} = state, loc) do
    adj = lookup(mem, base, loc)
    Map.merge(state, %{ptr: ptr + 2, base: base + adj})
  end

  def abs_dest(_state, {"0", loc}), do: loc
  def abs_dest(%{base: base}, {"2", loc}), do: base + loc

  def lookup(mem, _base, {"0", loc}), do: Enum.at(mem, loc, 0)
  def lookup(_, _base, {"1", val}), do: val
  def lookup(mem, base, {"2", rel}), do: Enum.at(mem, base + rel, 0)
end
