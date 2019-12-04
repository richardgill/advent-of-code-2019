defmodule Mix.Tasks.AOC.Day4Part2 do
  use Mix.Task

  def number_to_list(0) do
    []
  end

  def number_to_list(number) do
    number_to_list(Integer.floor_div(number, 10)) ++ [rem(number, 10)]
  end

  def only_pairs(pairs) do
    Enum.filter(pairs, fn pair -> length(pair) == 2 end)
  end

  def adjacent_pairs(numberList) do
    (Enum.chunk_every(numberList, 2)
     |> only_pairs()) ++ (Enum.drop(numberList, 1) |> Enum.chunk_every(2) |> only_pairs())
  end

  def is_never_decreasing(password) do
    password
    |> number_to_list()
    |> adjacent_pairs()
    |> Enum.all?(fn [x, y] -> x <= y end)
  end

  def adjacent_numbers([]) do
    []
  end

  def adjacent_numbers(number_list) do
    {adjacent_numbers, rest} = Enum.split_while(number_list, fn n -> n == List.first(number_list) end)
    [adjacent_numbers] ++ adjacent_numbers(rest)
  end

  def has_two_adajacent_digits_not_in_larger_group(password) do
    password
    |> number_to_list()
    |> adjacent_numbers()
    |> Enum.any?(fn adjacent_nums -> length(adjacent_nums) == 2 end)
  end

  def is_valid_password(password) do
    has_two_adajacent_digits_not_in_larger_group(password) && is_never_decreasing(password)
  end

  def run(_) do
    valid_passwords =
      172_930..683_082
      |> Enum.filter(fn x -> is_valid_password(x) end)

    IO.inspect(valid_passwords)
    IO.puts("Answer: #{length(valid_passwords)}")
  end
end
