defmodule Mix.Tasks.AOC.Day8 do
  use Mix.Task

  def parse_image(image_string) do
    image_string
    |> String.trim()
    |> String.split("")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)
  end


  def image_layers(image_string, width, height) do
    image_input = parse_image(image_string)
    image_input
    |> Enum.chunk(width)
    |> Enum.chunk(height)
  end

  def count_occurences_in_layer(layer, digit) do
    layer
    |> List.flatten()
    |> Enum.count(fn x -> x == digit end)
  end

  def layer_with_least_0s(layers) do
    layers
    |> Enum.sort_by(fn layer -> count_occurences_in_layer(layer, 0) end)
    |> List.first()
  end

  def calculate_checksum(image_string, width, height) do
    layers = image_layers(image_string, width, height)
    layer = layer_with_least_0s(layers)
    count_occurences_in_layer(layer, 1) * count_occurences_in_layer(layer, 2)
  end

  def run(_) do
    IO.inspect(calculate_checksum("123456789012", 3, 2))
    IO.inspect(calculate_checksum("122216789012", 3, 2))
    input =
      "./lib/mix/tasks/day8/input8.txt"
      |> File.read!()
      |> String.trim()
    answer = calculate_checksum(input, 25, 6)
    IO.puts("Answer: #{answer}")
  end
end
