defmodule Advent.Day5 do
  @moduledoc """
  Day 5: Sunny with a Chance of Asteroids
  Enhanced OpCode Computer
  """

  def run_diagnostics() do
    "data/day5.txt"
    |> Advent.Data.read_integers()
    |> run(0)
  end

  def run(registers, cursor) do
    registers
    |> Enum.slice(cursor..-1)
    |> case do
      [99 | _] ->
        registers

      [1, p1, p2, dest | _] ->
        registers
        |> compute({0, p1}, {0, p2}, dest, &Kernel.+/2)
        |> run(cursor + 4)

      [101, p1, p2, dest | _] ->
        registers
        |> compute({1, p1}, {0, p2}, dest, &Kernel.+/2)
        |> run(cursor + 4)

      [1001, p1, p2, dest | _] ->
        registers
        |> compute({0, p1}, {1, p2}, dest, &Kernel.+/2)
        |> run(cursor + 4)

      [1101, p1, p2, dest | _] ->
        registers
        |> compute({1, p1}, {1, p2}, dest, &Kernel.+/2)
        |> run(cursor + 4)

      [2, p1, p2, dest | _] ->
        registers
        |> compute({0, p1}, {0, p2}, dest, &Kernel.*/2)
        |> run(cursor + 4)

      [102, p1, p2, dest | _] ->
        registers
        |> compute({1, p1}, {0, p2}, dest, &Kernel.*/2)
        |> run(cursor + 4)

      [1002, p1, p2, dest | _] ->
        registers
        |> compute({0, p1}, {1, p2}, dest, &Kernel.*/2)
        |> run(cursor + 4)

      [1102, p1, p2, dest | _] ->
        registers
        |> compute({1, p1}, {1, p2}, dest, &Kernel.*/2)
        |> run(cursor + 4)

      [3, dest | _] ->
        registers
        |> input(dest)
        |> run(cursor + 2)

      [4, source | _] ->
        registers
        |> output({0, source})
        |> run(cursor + 2)

      [104, source | _] ->
        registers
        |> output({1, source})
        |> run(cursor + 2)

      [5, check, jmp | _] ->
        jump_true(registers, {0, check}, {0, jmp}, cursor)

      [105, check, jmp | _] ->
        jump_true(registers, {1, check}, {0, jmp}, cursor)

      [1005, check, jmp | _] ->
        jump_true(registers, {0, check}, {1, jmp}, cursor)

      [1105, check, jmp | _] ->
        jump_true(registers, {1, check}, {1, jmp}, cursor)

      [6, check, jmp | _] ->
        jump_false(registers, {0, check}, {0, jmp}, cursor)

      [106, check, jmp | _] ->
        jump_false(registers, {1, check}, {0, jmp}, cursor)

      [1006, check, jmp | _] ->
        jump_false(registers, {0, check}, {1, jmp}, cursor)

      [1106, check, jmp | _] ->
        jump_false(registers, {1, check}, {1, jmp}, cursor)

      [7, p1, p2, dest | _] ->
        registers
        |> set_boolean({0, p1}, {0, p2}, dest, &Kernel.</2)
        |> run(cursor + 4)

      [107, p1, p2, dest | _] ->
        registers
        |> set_boolean({1, p1}, {0, p2}, dest, &Kernel.</2)
        |> run(cursor + 4)

      [1007, p1, p2, dest | _] ->
        registers
        |> set_boolean({0, p1}, {1, p2}, dest, &Kernel.</2)
        |> run(cursor + 4)

      [1107, p1, p2, dest | _] ->
        registers
        |> set_boolean({1, p1}, {1, p2}, dest, &Kernel.</2)
        |> run(cursor + 4)

      [8, p1, p2, dest | _] ->
        registers
        |> set_boolean({0, p1}, {0, p2}, dest, &Kernel.==/2)
        |> run(cursor + 4)

      [108, p1, p2, dest | _] ->
        registers
        |> set_boolean({1, p1}, {0, p2}, dest, &Kernel.==/2)
        |> run(cursor + 4)

      [1008, p1, p2, dest | _] ->
        registers
        |> set_boolean({0, p1}, {1, p2}, dest, &Kernel.==/2)
        |> run(cursor + 4)

      [1108, p1, p2, dest | _] ->
        registers
        |> set_boolean({1, p1}, {1, p2}, dest, &Kernel.==/2)
        |> run(cursor + 4)

      i ->
        IO.inspect(i)
        raise "The computer has burst into flames!"
    end
  end

  def compute(registers, p1, p2, dest, operation) do
    value = operation.(lookup(registers, p1), lookup(registers, p2))
    List.replace_at(registers, dest, value)
  end

  def set_boolean(registers, p1, p2, dest, operation) do
    if operation.(lookup(registers, p1), lookup(registers, p2)) do
      List.replace_at(registers, dest, 1)
    else
      List.replace_at(registers, dest, 0)
    end
  end

  def jump_true(registers, check, jmp, cursor) do
    case lookup(registers, check) do
      0 ->
        run(registers, cursor + 3)

      _ ->
        run(registers, lookup(registers, jmp))
    end
  end

  def jump_false(registers, check, jmp, cursor) do
    case lookup(registers, check) do
      0 ->
        run(registers, lookup(registers, jmp))

      _ ->
        run(registers, cursor + 3)
    end
  end

  def input(registers, dest) do
    value =
      IO.read(:stdio, :line)
      |> String.trim()
      |> String.to_integer()

    List.replace_at(registers, dest, value)
  end

  def output(registers, source) do
    registers
    |> lookup(source)
    |> IO.puts()

    registers
  end

  def lookup(registers, {0, loc}), do: Enum.at(registers, loc)
  def lookup(_, {1, val}), do: val
end
