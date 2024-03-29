defmodule Mix.Tasks.AOC.Day3 do
  use Mix.Task

  def parseInstructions(instructions) do
    instructions
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x, ",") end)
  end

  def nextCoordinatesForInstruction(direction, magnitude, coordinates) do
    {x, y} = List.last(coordinates) || {0, 0}

    1..magnitude
    |> Enum.map(fn steps ->
      cond do
        direction == "R" ->
          {x + steps, y}

        direction == "L" ->
          {x - steps, y}

        direction == "U" ->
          {x, y + steps}

        direction == "D" ->
          {x, y - steps}
      end
    end)
  end

  def instructionsToCoordinates(instructions) do
    instructions
    |> Enum.reduce([], fn instruction, coordinates ->
      {direction, magnitudeString} = String.split_at(instruction, 1)
      magnitude = magnitudeString |> String.trim() |> Integer.parse() |> elem(0)
      coordinates ++ nextCoordinatesForInstruction(direction, magnitude, coordinates)
    end)
  end

  def manhattenDistance({x, y}) do
    abs(x) + abs(y)
  end

  def distanceFromOriginToClosestIntersection(instructions) do
    [coordinates1, coordinates2] =
      instructions
      |> parseInstructions()
      |> Enum.map(fn x -> instructionsToCoordinates(x) end)

    crossCoordinates = MapSet.intersection(MapSet.new(coordinates1), MapSet.new(coordinates2))

    crossCoordinates
    |> Enum.map(fn coordinate -> manhattenDistance(coordinate) end)
    |> Enum.sort()
    |> List.first()
  end

  def run(_) do
    IO.inspect(distanceFromOriginToClosestIntersection("R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83"))

    IO.inspect(distanceFromOriginToClosestIntersection("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7"))

    input =
      "./lib/mix/tasks/day3/input3.txt"
      |> File.read!()
      |> String.trim()

    IO.puts("Answer: #{distanceFromOriginToClosestIntersection(input)}")
  end
end
