defmodule Mix.Tasks.AOC.Day10Part2 do
  use Mix.Task

  def read_input_from_file(file) do
    file
    |> File.read!()
    |> parse_input()
  end

  def drop_first_and_last(list) do
    list
    |> Enum.drop(1)
    |> Enum.reverse()
    |> Enum.drop(1)
    |> Enum.reverse()
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.trim()
      |> String.split("")
      |> drop_first_and_last()
    end)
  end

  def coordinates_of_asteroids(map) do
    map
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {position, column_index} ->
        if position == "#" do
          {column_index, row_index}
        else
          nil
        end
      end)
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  def make_relative({reference_x, reference_y}, {x, y}) do
    {x - reference_x, y - reference_y}
  end

  def has_direct_line_of_sight(reference, target, coordinates) do
    relative_coordinates = Enum.map(coordinates, fn c -> make_relative(reference, c) end)
    {target_x, target_y} = make_relative(reference, target)

    not (relative_coordinates
         |> Enum.any?(fn {x, y} ->
           case {target_x, target_y} do
             {0, target_y} ->
               x == 0 && y > 0 == target_y > 0 && abs(y) < abs(target_y)

             {target_x, 0} ->
               y == 0 && x > 0 == target_x > 0 && abs(x) < abs(target_x)

             {target_x, target_y} ->
               distance_to_target = abs(target_x) + abs(target_y)
               distance_other = abs(x) + abs(y)

               x != 0 && y != 0 && distance_other < distance_to_target && target_x > 0 == x > 0 && target_y > 0 == y > 0 &&
                 target_x / x == target_y / y
           end
         end))
  end

  def calculate_direct_lines_of_sight(start_coordinate, coordinates) do
    coordinates
    |> Enum.filter(fn target_coordinate ->
      has_direct_line_of_sight(start_coordinate, target_coordinate, List.delete(coordinates, target_coordinate))
    end)
  end

  def calculate_direct_line_of_sights(coordinates) do
    coordinates
    |> Enum.map(fn coordinate ->
      {coordinate, calculate_direct_lines_of_sight(coordinate, List.delete(coordinates, coordinate)) |> length()}
    end)
  end

  def coordinates_with_most_detections(file) do
    file
    |> read_input_from_file()
    |> coordinates_of_asteroids()
    |> calculate_direct_line_of_sights()
    |> Enum.max_by(fn x -> elem(x, 1) end)
  end

  def sort_clockwise(coordinates, center_coordinate) do
    coordinates
    |> Enum.sort_by(fn c -> angle_of_coordinate(center_coordinate, c) end)
  end

  def angle_of_coordinate(from, to) do
    {to_y, to_x} = make_relative(from, to)
    raw_angle = :math.atan2(to_y, to_x) * (180 / :math.pi())

    if raw_angle > 0 do
      180 - raw_angle
    else
      180 + abs(raw_angle)
    end
  end

  def vaporise_asteroids(_, []) do
    []
  end

  def vaporise_asteroids(laser_coordinate, coordinates) do
    vaporised =
      calculate_direct_lines_of_sight(laser_coordinate, coordinates)
      |> sort_clockwise(laser_coordinate)

    remaining_asteroids =
      MapSet.difference(MapSet.new(coordinates), MapSet.new(vaporised))
      |> MapSet.to_list()

    vaporised ++ vaporise_asteroids(laser_coordinate, remaining_asteroids)
  end

  def vaporise_asteroids_from_file(file) do
    coordinates =
      file
      |> read_input_from_file()
      |> coordinates_of_asteroids()

    laser_coordinate =
      calculate_direct_line_of_sights(coordinates)
      |> Enum.max_by(fn x -> elem(x, 1) end)
      |> elem(0)

    vaporise_asteroids(laser_coordinate, List.delete(coordinates, laser_coordinate))
  end

  def run(_) do
    {x, y} = Enum.at(vaporise_asteroids_from_file("./lib/mix/tasks/day10/input10.txt"), 199)
    IO.inspect(x * 100 + y)
  end
end
