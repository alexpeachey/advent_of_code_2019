defmodule Advent.Day4 do
  @moduledoc """
  Day 4: Secure Container
  Find possible security codes
  """

  def count_possible() do
    265_275..781_584
    |> Enum.filter(&has_doubles?/1)
    |> Enum.filter(&increases?/1)
    |> length()
  end

  def updated_count_possible() do
    265_275..781_584
    |> Enum.filter(&has_one_double?/1)
    |> Enum.filter(&increases?/1)
    |> length()
  end

  def has_doubles?(code) do
    to_string(code)
    |> String.codepoints()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fn [x, y] -> x == y end)
  end

  def has_one_double?(code) do
    to_string(code)
    |> String.codepoints()
    |> Enum.chunk_while([], &duplicate?/2, &remainder/1)
    |> Enum.filter(fn chunk -> length(chunk) == 2 end)
    |> length()
    |> Kernel.>(0)
  end

  def duplicate?(n, []), do: {:cont, [n]}
  def duplicate?(n, [n | _] = acc), do: {:cont, [n | acc]}
  def duplicate?(n, acc), do: {:cont, acc, [n]}

  def remainder([]), do: {:cont, []}
  def remainder(acc), do: {:cont, acc, []}

  def increases?(code) do
    to_string(code)
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [x, y] -> x <= y end)
  end
end
