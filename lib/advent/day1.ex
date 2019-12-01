defmodule Advent.Day1 do
  @moduledoc """
  Day 1: The Tyranny of the Rocket Equation
  Calculate the fuel required for all modules.
  """

  def calculate_module_fuel() do
    "data/day1.txt"
    |> Advent.Data.read_integers()
    |> Enum.map(&module_fuel/1)
    |> Enum.sum()
  end

  def calculate_full_load_fuel() do
    "data/day1.txt"
    |> Advent.Data.read_integers()
    |> Enum.map(&full_load_fuel/1)
    |> Enum.sum()
  end

  @doc """
  Calculate the fuel required for a single module

  ## Examples

    iex> Advent.Day1.module_fuel(12)
    2
    iex> Advent.Day1.module_fuel(14)
    2
    iex> Advent.Day1.module_fuel(1969)
    654
    iex> Advent.Day1.module_fuel(100756)
    33583
  """
  def module_fuel(mass) do
    div(mass, 3) - 2
  end

  @doc """
  Calculate the fuel required for a single module
  while also factoring in the mass of the fuel

  ## Examples

    iex> Advent.Day1.full_load_fuel(12)
    2
    iex> Advent.Day1.full_load_fuel(14)
    2
    iex> Advent.Day1.full_load_fuel(1969)
    966
    iex> Advent.Day1.full_load_fuel(100756)
    50346
  """
  def full_load_fuel(mass) do
    mass
    |> module_fuel()
    |> max(0)
    |> case do
      0 -> 0
      fuel -> fuel + full_load_fuel(fuel)
    end
  end
end
