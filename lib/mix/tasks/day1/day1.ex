defmodule Mix.Tasks.AOC.Day1 do
  use Mix.Task

  def fuelForMass(mass) do
    Integer.floor_div(mass, 3) - 2
  end

  def run(_) do
    massesAsStrings = String.split(String.trim(File.read!("./lib/mix/tasks/day1/input1.txt")), "\n")

    massesAsNumbers = Enum.map(massesAsStrings, fn x -> elem(Integer.parse(x), 0) end)
    Enum.map(massesAsNumbers, &fuelForMass/1)
    answer = Enum.sum(Enum.map(massesAsNumbers, &fuelForMass/1))
    IO.puts("Answer: #{answer}")
  end
end
