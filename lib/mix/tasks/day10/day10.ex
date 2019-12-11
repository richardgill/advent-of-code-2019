defmodule Mix.Tasks.AOC.Day10 do
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
      x |> String.trim()
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
    not (relative_coordinates |>
    Enum.any?(fn {x, y} ->
      case {target_x, target_y} do
        {0, target_y} ->
          x == 0 && (y > 0 == target_y > 0) && abs(y) < abs(target_y)
        {target_x, 0} ->
          y == 0 && (x > 0 == target_x > 0) && abs(x) < abs(target_x)
        {target_x, target_y} ->
          distance_to_target = abs(target_x) + abs(target_y)
          distance_other = abs(x) + abs(y)
          x != 0 && y != 0 && distance_other < distance_to_target && target_x > 0 == x > 0 && target_y > 0 == y > 0 && (target_x / x == target_y / y)
      end
    end))
  end

  def count_direct_lines_of_sight(start_coordinate, coordinates) do
    coordinates
    |> Enum.filter(fn target_coordinate ->
      has_direct_line_of_sight(start_coordinate, target_coordinate, List.delete(coordinates, target_coordinate))
    end)
    |> length()
  end

  def calculate_direct_line_of_sights(coordinates) do
    coordinates
    |> Enum.map(fn coordinate -> {coordinate, count_direct_lines_of_sight(coordinate, List.delete(coordinates, coordinate))} end)
    |> Enum.max_by(fn x -> elem(x, 1) end)
  end

  def coordinates_with_most_detections(file) do
    file
    |> read_input_from_file()
    |> coordinates_of_asteroids()
    |> calculate_direct_line_of_sights()
  end

  def run(_) do
    IO.inspect(coordinates_with_most_detections("./lib/mix/tasks/day10/example1.txt"))
    IO.inspect(coordinates_with_most_detections("./lib/mix/tasks/day10/example2.txt"))
    IO.inspect(coordinates_with_most_detections("./lib/mix/tasks/day10/example3.txt"))
    IO.inspect(coordinates_with_most_detections("./lib/mix/tasks/day10/example4.txt"))
    IO.inspect(coordinates_with_most_detections("./lib/mix/tasks/day10/example5.txt"))
    IO.inspect(coordinates_with_most_detections("./lib/mix/tasks/day10/input10.txt"))
  end
end
