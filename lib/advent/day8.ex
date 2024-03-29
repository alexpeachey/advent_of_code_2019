defmodule Advent.Day8 do
  @moduledoc """
  Day 8: Space Image Format
  Decode Images
  """

  def assemble_image() do
    "data/day8.txt"
    |> File.read!()
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.chunk_every(150)
    |> Enum.reduce(&merge_layers/2)
    |> Enum.map(fn x -> if x == "2", do: "⬛️", else: x end)
    |> Enum.map(fn x -> if x == "1", do: "⬜️", else: x end)
    |> Enum.map(fn x -> if x == "0", do: "⬛️", else: x end)
    |> Enum.chunk_every(25)
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.each(&IO.puts/1)
  end

  def merge_layers(layer, previous) do
    previous
    |> Enum.zip(layer)
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&merge_pixels/1)
  end

  def merge_pixels(["2", x]), do: x
  def merge_pixels([x, _]), do: x

  def fewest_zeros() do
    layer =
      "data/day8.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("", trim: true)
      |> Enum.chunk_every(150)
      |> Enum.min_by(&count_digit(&1, "0"))

    ones = count_digit(layer, "1")
    twos = count_digit(layer, "2")
    ones * twos
  end

  def count_digit(data, digit) do
    Enum.count(data, fn d -> d == digit end)
  end
end
