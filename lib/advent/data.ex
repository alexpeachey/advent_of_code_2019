defmodule Advent.Data do
  def read(path) do
    path
    |> File.stream!()
    |> CSV.decode!()
    |> Enum.into([])
  end

  def read_integers(path) do
    path
    |> read()
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end
end
