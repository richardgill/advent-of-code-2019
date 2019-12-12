defmodule Mix.Tasks.AOC.Day12 do
  use Mix.Task
  def permutations([]), do: [[]]
  def permutations(list), do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def tuple_add(tuple_1, tuple_2) do
    tuple_1_list = Tuple.to_list(tuple_1)
    tuple_2_list = Tuple.to_list(tuple_2)

    0..(length(tuple_1_list) - 1)
    |> Enum.map(fn i ->
      Enum.at(tuple_1_list, i) + Enum.at(tuple_2_list, i)
    end)
    |> List.to_tuple()
  end

  def delete_one(list, element) do
    index = Enum.find_index(list, fn x -> x == element end)
    List.delete_at(list, index)
  end

  def calculate_velocity_difference(a, b) do
    cond do
      a > b ->
        1

      a == b ->
        0

      a < b ->
        -1
    end
  end

  def calculate_velocity({{px1, py1, pz1}, {vx, vy, vz}}, {{px2, py2, pz2}, _}) do
    new_vector = {
      vx + calculate_velocity_difference(px2, px1),
      vy + calculate_velocity_difference(py2, py1),
      vz + calculate_velocity_difference(pz2, pz1)
    }

    {{px1, py1, pz1}, new_vector}
  end

  def calculate_velocities(moon, []) do
    moon
  end

  def calculate_velocities(moon, [first_moon | other_moons]) do
    calculate_velocities(calculate_velocity(moon, first_moon), other_moons)
  end

  def calculate_new_position({position, velocity}) do
    {tuple_add(position, velocity), velocity}
  end

  def run_simulation_helper(moons, 0) do
    moons
  end

  def run_simulation_helper(moons, steps) do
    new_moons =
      moons
      |> Enum.map(fn moon -> calculate_velocities(moon, delete_one(moons, moon)) end)
      |> Enum.map(fn moon -> calculate_new_position(moon) end)
      |> IO.inspect()

    run_simulation_helper(new_moons, steps - 1)
  end

  def calculate_energy({{px, py, pz}, {vx, vy, vz}}) do
    potential_energy = abs(px) + abs(py) + abs(pz)
    kinetic_energy = abs(vx) + abs(vy) + abs(vz)
    {potential_energy, kinetic_energy, potential_energy * kinetic_energy}
  end

  def run_simulation(moons, steps) do
    moons_with_velocities =
      moons
      |> Enum.map(fn moon -> {moon, {0, 0, 0}} end)

    run_simulation_helper(moons_with_velocities, steps)
    |> Enum.map(fn moon -> calculate_energy(moon) end)
    |> IO.inspect()
    |> Enum.map(fn {_, _, total_energy} -> total_energy end)
    |> Enum.sum()
  end

  def run(_) do
    example_1 = [{-1, 0, 2}, {2, -10, -7}, {4, -8, 8}, {3, 5, -1}]
    example_2 = [{-8, -10, 0}, {5, 5, 10}, {2, -7, 3}, {9, -8, -3}]
    input = [{-8, -18, 6}, {-11, -14, 4}, {8, -3, -10}, {-2, -16, 1}]

    IO.inspect(run_simulation(example_1, 10))
    IO.inspect(run_simulation(example_2, 100))
    IO.inspect(run_simulation(input, 1000))
  end
end
