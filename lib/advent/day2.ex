defmodule Advent.Day2 do
  @moduledoc """
  Day 2: 1202 Program Alarm
  Create an Intcode Computer
  """

  @gravity_assist_target 19_690_720

  def recreate_error() do
    "data/day2.txt"
    |> Advent.Data.read_integers()
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> compute(0)
  end

  def gravity_assist() do
    "data/day2.txt"
    |> Advent.Data.read_integers()
    |> find_input()
    |> encode_input()
  end

  @doc """
  Compute from the current cursor position

    ## Examples
    iex> Advent.Day2.compute([1, 0, 0, 0, 99], 0)
    [2, 0, 0, 0, 99]

    iex> Advent.Day2.compute([2, 3, 0, 3, 99], 0)
    [2, 3, 0, 6, 99]

    iex> Advent.Day2.compute([2, 4, 4, 5, 99, 0], 0)
    [2, 4, 4, 5, 99, 9801]

    iex> Advent.Day2.compute([1, 1, 1, 4, 99, 5, 6, 0, 99], 0)
    [30, 1, 1, 4, 2, 5, 6, 0, 99]
  """
  def compute(registers, cursor) do
    registers
    |> Enum.slice(cursor..-1)
    |> case do
      [99 | _] ->
        registers

      [1, first, second, destination | _] ->
        registers
        |> add(first, second, destination)
        |> compute(cursor + 4)

      [2, first, second, destination | _] ->
        registers
        |> multiply(first, second, destination)
        |> compute(cursor + 4)

      _ ->
        raise "The computer has burst into flames!"
    end
  end

  def find_input(registers) do
    [_, noun, verb | _] =
      possible_inputs()
      |> Enum.map(&modify_registers(&1, registers))
      |> Enum.find(&check_input/1)

    {noun, verb}
  end

  def modify_registers({noun, verb}, registers) do
    registers
    |> List.replace_at(1, noun)
    |> List.replace_at(2, verb)
  end

  def check_input(registers) do
    registers
    |> compute(0)
    |> List.first()
    |> Kernel.==(@gravity_assist_target)
  end

  def encode_input({noun, verb}) do
    100 * noun + verb
  end

  def possible_inputs() do
    for x <- 0..99, y <- 0..99, do: {x, y}
  end

  def add(registers, first, second, destination) do
    value = Enum.at(registers, first) + Enum.at(registers, second)
    List.replace_at(registers, destination, value)
  end

  def multiply(registers, first, second, destination) do
    value = Enum.at(registers, first) * Enum.at(registers, second)
    List.replace_at(registers, destination, value)
  end
end
