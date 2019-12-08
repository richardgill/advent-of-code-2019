defmodule Mix.Tasks.AOC.Day8Part2 do
  use Mix.Task

  def parse_image(image_string) do
    image_string
    |> String.trim()
    |> String.split("")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)
  end

  def image_layers(image_string, width, height) do
    parse_image(image_string)
    |> Enum.chunk_every(width)
    |> Enum.chunk_every(height)
  end

  def merge_layers(layers, width, height) do
    Enum.map(0..(height - 1), fn height_index ->
      Enum.map(0..(width - 1), fn width_index ->
        Enum.map(layers, fn layer ->
          Enum.at(layer, height_index) |> Enum.at(width_index)
        end)
      end)
    end)
  end

  def calculate_pixel(pixel) do
    zero_index = Enum.find_index(pixel, fn x -> x == 0 end)
    one_index = Enum.find_index(pixel, fn x -> x == 1 end)
    if zero_index < one_index, do: 0, else: 1
  end

  def calculate_image_output(image) do
    Enum.map(image, fn row ->
      Enum.map(row, fn pixel ->
        calculate_pixel(pixel)
      end)
    end)
  end

  def print_image_output(image) do
    image
    |> Enum.map(fn row -> Enum.join(row, "") end)
    |> Enum.join("\n")
  end

  def print_image(image_string, width, height) do
    image_string
    |> image_layers(width, height)
    |> merge_layers(width, height)
    |> calculate_image_output()
    |> print_image_output()
  end

  def run(_) do
    # IO.puts(print_image("0222112222120000", 2, 2))
    # IO.inspect(print_image("012012012012", 3, 2))
    input =
      "./lib/mix/tasks/day8/input8.txt"
      |> File.read!()
      |> String.trim()

    answer = print_image(input, 25, 6)
    IO.puts(answer)
  end
end
