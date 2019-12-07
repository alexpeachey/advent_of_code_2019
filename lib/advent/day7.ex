defmodule Advent.Day7 do
  @moduledoc """
  Day 7: Amplification Circuit
  Enhanced OpCode Computer
  """
  alias Advent.Day7.IO

  def find_highest_signal() do
    IO.start_link([:amp1, :amp2, :amp3, :amp4, :amp5])
    mem = Advent.Data.read_integers("data/day7.txt")

    inputs =
      for a <- 0..4,
          b <- 0..4,
          c <- 0..4,
          d <- 0..4,
          e <- 0..4,
          do: {a, b, c, d, e}

    inputs
    |> Enum.reject(&duplicate_phase_inputs/1)
    |> Enum.map(&run_circuit(&1, mem))
    |> Enum.max()
  end

  def find_highest_feedback_signal() do
    IO.start_link([:amp1, :amp2, :amp3, :amp4, :amp5])
    mem = Advent.Data.read_integers("data/day7.txt")

    inputs =
      for a <- 5..9,
          b <- 5..9,
          c <- 5..9,
          d <- 5..9,
          e <- 5..9,
          do: {a, b, c, d, e}

    inputs
    |> Enum.reject(&duplicate_phase_inputs/1)
    |> Enum.map(&run_feedback(&1, mem))
    |> Enum.max()
  end

  def duplicate_phase_inputs(inputs) do
    inputs
    |> Tuple.to_list()
    |> Enum.uniq()
    |> Enum.count()
    |> Kernel.!=(5)
  end

  def run_circuit({a, b, c, d, e}, mem) do
    IO.flush()
    IO.puts(:amp1, a)
    IO.puts(:amp2, b)
    IO.puts(:amp3, c)
    IO.puts(:amp4, d)
    IO.puts(:amp5, e)
    IO.puts(:amp1, 0)
    run(%{mem: mem, ptr: 0, in: :amp1, out: :amp2})
    run(%{mem: mem, ptr: 0, in: :amp2, out: :amp3})
    run(%{mem: mem, ptr: 0, in: :amp3, out: :amp4})
    run(%{mem: mem, ptr: 0, in: :amp4, out: :amp5})
    run(%{mem: mem, ptr: 0, in: :amp5, out: :amp5})

    IO.read(:amp5, :line)
    |> String.trim()
    |> String.to_integer()
  end

  def run_feedback({a, b, c, d, e}, mem) do
    IO.flush()
    IO.puts(:amp1, a)
    IO.puts(:amp2, b)
    IO.puts(:amp3, c)
    IO.puts(:amp4, d)
    IO.puts(:amp5, e)
    IO.puts(:amp1, 0)

    [
      Task.async(fn -> run(%{mem: mem, ptr: 0, in: :amp1, out: :amp2}) end),
      Task.async(fn -> run(%{mem: mem, ptr: 0, in: :amp2, out: :amp3}) end),
      Task.async(fn -> run(%{mem: mem, ptr: 0, in: :amp3, out: :amp4}) end),
      Task.async(fn -> run(%{mem: mem, ptr: 0, in: :amp4, out: :amp5}) end),
      Task.async(fn -> run(%{mem: mem, ptr: 0, in: :amp5, out: :amp1}) end)
    ]
    |> Enum.each(&Task.await/1)

    IO.read(:amp1, :line)
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

  def process([{_a, b, c, "01"}, p1, p2, dest | _], %{mem: mem, ptr: ptr} = state) do
    mem = compute(mem, {c, p1}, {b, p2}, dest, &Kernel.+/2)
    {:ok, Map.merge(state, %{mem: mem, ptr: ptr + 4})}
  end

  def process([{_a, b, c, "02"}, p1, p2, dest | _], %{mem: mem, ptr: ptr} = state) do
    mem = compute(mem, {c, p1}, {b, p2}, dest, &Kernel.*/2)
    {:ok, Map.merge(state, %{mem: mem, ptr: ptr + 4})}
  end

  def process([{_a, _b, _c, "03"}, dest | _], %{mem: mem, ptr: ptr, in: io} = state) do
    mem = input(mem, dest, io)
    {:ok, Map.merge(state, %{mem: mem, ptr: ptr + 2})}
  end

  def process([{_a, _b, c, "04"}, source | _], %{mem: mem, ptr: ptr, out: io} = state) do
    mem = output(mem, {c, source}, io)
    {:ok, Map.merge(state, %{mem: mem, ptr: ptr + 2})}
  end

  def process([{_a, b, c, "05"}, check, jmp | _], state) do
    state = jump_true(state, {c, check}, {b, jmp})
    {:ok, state}
  end

  def process([{_a, b, c, "06"}, check, jmp | _], state) do
    state = jump_false(state, {c, check}, {b, jmp})
    {:ok, state}
  end

  def process([{_a, b, c, "07"}, p1, p2, dest | _], %{mem: mem, ptr: ptr} = state) do
    mem = set_boolean(mem, {c, p1}, {b, p2}, dest, &Kernel.</2)
    {:ok, Map.merge(state, %{mem: mem, ptr: ptr + 4})}
  end

  def process([{_a, b, c, "08"}, p1, p2, dest | _], %{mem: mem, ptr: ptr} = state) do
    mem = set_boolean(mem, {c, p1}, {b, p2}, dest, &Kernel.==/2)
    {:ok, Map.merge(state, %{mem: mem, ptr: ptr + 4})}
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

  def jump_true(%{mem: mem, ptr: ptr} = state, check, jmp) do
    case lookup(mem, check) do
      0 ->
        Map.merge(state, %{mem: mem, ptr: ptr + 3})

      _ ->
        Map.merge(state, %{mem: mem, ptr: lookup(mem, jmp)})
    end
  end

  def jump_false(%{mem: mem, ptr: ptr} = state, check, jmp) do
    case lookup(mem, check) do
      0 ->
        Map.merge(state, %{mem: mem, ptr: lookup(mem, jmp)})

      _ ->
        Map.merge(state, %{mem: mem, ptr: ptr + 3})
    end
  end

  def input(mem, dest, io) do
    value =
      IO.read(io, :line)
      |> String.trim()
      |> String.to_integer()

    List.replace_at(mem, dest, value)
  end

  def output(mem, source, io) do
    value = lookup(mem, source)
    IO.puts(io, value)

    mem
  end

  def lookup(mem, {"0", loc}), do: Enum.at(mem, loc)
  def lookup(_, {"1", val}), do: val
end
