defmodule Advent.Day3 do
  @moduledoc """
  Day 3: Crossed Wires
  Create an Intcode Computer
  """

  def follow_wires_to_closest_intersection() do
    "data/day3.txt"
    |> Advent.Data.read()
    |> closest_intersection()
  end

  def follow_wires_to_best_intersection() do
    "data/day3.txt"
    |> Advent.Data.read()
    |> best_intersection()
  end

  @doc """
    Find the lowest number of steps to an intersection

    ##Examples

      iex> Advent.Day3.best_intersection([["R8","U5","L5","D3"],["U7","R6","D4","L4"]])
      30

      iex> Advent.Day3.best_intersection([["R75","D30","R83","U83","L12","D49","R71","U7","L72"],["U62","R66","U55","R34","D71","R55","D58","R83"]])
      610

      iex> Advent.Day3.best_intersection([["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"],["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"]])
      410
  """
  def best_intersection(instructions) do
    wires = Enum.map(instructions, &to_wire/1)

    intersections =
      wires
      |> Enum.map(&MapSet.new/1)
      |> find_intersections()
      |> Enum.reject(fn point -> point == {0, 0} end)

    wires
    |> Enum.map(&steps_to_intersections(&1, intersections))
    |> Enum.zip()
    |> Enum.map(fn {{_, steps1}, {_, steps2}} -> steps1 + steps2 end)
    |> Enum.min()
  end

  @doc """
    Find the intersection of 2 wires closest to origin

    ##Examples

      iex> Advent.Day3.closest_intersection([["R8","U5","L5","D3"], ["U7","R6","D4","L4"]])
      6

      iex> Advent.Day3.closest_intersection([["R75","D30","R83","U83","L12","D49","R71","U7","L72"],["U62","R66","U55","R34","D71","R55","D58","R83"]])
      159

      iex> Advent.Day3.closest_intersection([["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"],["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"]])
      135

  """
  def closest_intersection(instructions) do
    instructions
    |> Enum.map(&to_wire/1)
    |> Enum.map(&MapSet.new/1)
    |> find_intersections()
    |> Enum.reject(fn point -> point == {0, 0} end)
    |> Enum.map(&distance/1)
    |> Enum.min()
  end

  def steps_to_intersections(wire, intersections) do
    intersections
    |> Enum.map(&{&1, steps_to_intersection(&1, wire)})
  end

  def steps_to_intersection(intersection, wire) do
    wire
    |> Enum.split_while(fn point -> point != intersection end)
    |> Tuple.to_list()
    |> List.first()
    |> length()
  end

  def find_intersections([wire1, wire2]) do
    wire1
    |> MapSet.intersection(wire2)
    |> MapSet.to_list()
  end

  def distance({x, y}) do
    abs(x) + abs(y)
  end

  def to_wire(instructions) do
    instructions
    |> Enum.reduce([{0, 0}], &lay_wire/2)
    |> Enum.reverse()
  end

  def lay_wire(step, [point | _] = path) do
    case decode(step) do
      {"U", count} ->
        spooly(count..1, point) ++ path

      {"D", count} ->
        spooly(-count..-1, point) ++ path

      {"L", count} ->
        spoolx(-count..-1, point) ++ path

      {"R", count} ->
        spoolx(count..1, point) ++ path
    end
  end

  def spoolx(range, {x, y}) do
    range
    |> Enum.map(fn dx -> {x + dx, y} end)
  end

  def spooly(range, {x, y}) do
    range
    |> Enum.map(fn dy -> {x, y + dy} end)
  end

  def decode(step) do
    [direction | rest] = String.codepoints(step)

    count =
      rest
      |> Enum.join()
      |> String.to_integer()

    {direction, count}
  end
end
