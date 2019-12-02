defmodule Mix.Tasks.AOC.Day1Part2 do
  use Mix.Task

  def fuelForMass(mass) do
    max(Integer.floor_div(mass, 3) - 2, 0)
  end

  def fuelForFuel(0) do
    0
  end

  def fuelForFuel(mass) do
    fuelForMass(mass) + fuelForFuel(fuelForMass(mass))
  end

  def fuelForMassIncludingExtraFuel(mass) do
    fuelForMass(mass) + fuelForFuel(fuelForMass(mass))
  end

  def run(_) do
    massesAsStrings =
      String.split(String.trim(File.read!("./lib/mix/tasks/day1/input1.txt")), "\n")

    massesAsNumbers = Enum.map(massesAsStrings, fn x -> elem(Integer.parse(x), 0) end)
    Enum.map(massesAsNumbers, &fuelForMass/1)
    fuelForModules = Enum.sum(Enum.map(massesAsNumbers, &fuelForMassIncludingExtraFuel/1))
    IO.puts("Answer: #{fuelForModules}")
  end
end
