defmodule Mix.Tasks.AOC.Day6Part2 do
  use Mix.Task

  def parse_orbits(orbits) do
    orbits
    |> String.split("\n")
    |> Enum.map(fn orbit -> String.split(orbit, ")") end)
  end

  def calculate_transfer_lengths(_, _, [], _, _), do: 0

  def calculate_transfer_lengths(from, to, [orbit | _], _, length_so_far) when orbit in [[from, to], [to, from]], do: length_so_far - 1

  def calculate_transfer_lengths(from, to, [orbit | tail], all_orbits, length_so_far) do
    if from in orbit do
      currently_orbiting = List.delete(orbit, from) |> List.first()
        calculate_transfer_lengths(currently_orbiting, to, List.delete(all_orbits, orbit), all_orbits, length_so_far + 1) + calculate_transfer_lengths(from, to, tail, all_orbits, length_so_far)
      else
        calculate_transfer_lengths(from, to, tail, all_orbits, length_so_far)
    end
  end

  def shortest_transfer(from, to, orbits) do
    calculate_transfer_lengths(from, to, orbits, orbits, 0)
  end

  def run(_) do
    IO.inspect(shortest_transfer("YOU", "SAN", parse_orbits("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN")))

    input =
      "./lib/mix/tasks/day6/input6.txt"
      |> File.read!()
      |> String.trim()

    answer = shortest_transfer("YOU", "SAN", parse_orbits(input))
    IO.puts("Answer: #{answer}")
  end
end
