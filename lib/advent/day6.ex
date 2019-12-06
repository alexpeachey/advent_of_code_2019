defmodule Advent.Day6 do
  @moduledoc """
  Day 6: Universal Orbit Map
  Counting orbits
  """

  defmodule OrbitMap do
    defstruct name: nil, orbiting: nil, orbits: [], children: []
  end

  def count_orbits() do
    "data/day6.txt"
    |> Advent.Data.read()
    |> List.flatten()
    |> build_map(%OrbitMap{name: "COM"})
    |> count()
  end

  def find_transfers() do
    map =
      "data/day6.txt"
      |> Advent.Data.read()
      |> List.flatten()
      |> build_map(%OrbitMap{name: "COM"})

    you = find(map, "YOU")
    san = find(map, "SAN")
    shortest_transfers(you.orbits, san.orbits)
  end

  def build_map(map, node) do
    children =
      map
      |> Enum.filter(&String.starts_with?(&1, node.name))
      |> Enum.map(&create_child(&1, node, map))

    Map.put(node, :children, children)
  end

  def create_child(rel, node, map) do
    [_, orbiter] = String.split(rel, ")")
    build_map(map, %OrbitMap{name: orbiter, orbiting: node, orbits: [node.name | node.orbits]})
  end

  def count(map) do
    length(map.orbits) +
      Enum.reduce(map.children, 0, fn child, sum ->
        sum + count(child)
      end)
  end

  def find(%{name: name} = map, name), do: map

  def find(%{children: []}, _name), do: nil

  def find(map, name) do
    map.children
    |> Enum.map(&find(&1, name))
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> nil
      [node] -> node
    end
  end

  def shortest_transfers(you, san) do
    [intersection | _] = Enum.filter(you, fn n -> Enum.member?(san, n) end)

    Enum.find_index(you, fn n -> n == intersection end) +
      Enum.find_index(san, fn n -> n == intersection end)
  end
end
