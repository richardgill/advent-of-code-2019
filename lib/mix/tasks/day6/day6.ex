defmodule Mix.Tasks.AOC.Day6 do
  use Mix.Task

  def parse_orbits(orbits) do
    orbits
    |> String.split("\n")
    |> Enum.map(fn orbit -> String.split(orbit, ")") end)
  end

  def calculate_orbits(_, [], _) do
    0
  end

  def calculate_orbits(object, [[o, object] | _], all_orbits) do
    1 + calculate_orbits(o, all_orbits, all_orbits)
  end

  def calculate_orbits(object, [_ | tail], all_orbits) do
    calculate_orbits(object, tail, all_orbits)
  end

  def count_orbits(orbits) do
    unique_objects = List.flatten(orbits)
    |> MapSet.new()
    |> MapSet.to_list()

    unique_objects
    |> Enum.map(fn object -> calculate_orbits(object, orbits, orbits) end)
    |> Enum.sum()
  end

  def run(_) do
    # IO.inspect(count_orbits(parse_orbits("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L")))
    input =
      "./lib/mix/tasks/day6/input6.txt"
      |> File.read!()
      |> String.trim()
    answer = count_orbits(parse_orbits(input))
    IO.puts("Answer: #{answer}")
  end
end
