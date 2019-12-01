defmodule Advent.Data do
  def read(path) do
    path
    |> File.stream!()
    |> CSV.decode!()
    |> Enum.into([])
    |> List.flatten()
  end

  def read_integers(path) do
    path
    |> read()
    |> Enum.map(&String.to_integer/1)
  end
end
