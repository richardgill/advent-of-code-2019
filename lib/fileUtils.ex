defmodule FileUtils do

  def splitFileToIntegers(file, separator) do
    file
    |> File.read!()
    |> String.trim()
    |> String.split(separator)
    |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)
  end
end
