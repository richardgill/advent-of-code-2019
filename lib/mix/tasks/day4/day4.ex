defmodule Mix.Tasks.AOC.Day4 do
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

  def has_two_adajacent_digits(password) do
    password
      |> number_to_list()
      |> adjacent_pairs()
      |> Enum.any?(fn [x, y] -> x === y end)
  end

  def is_valid_password(password) do
    has_two_adajacent_digits(password) && is_never_decreasing(password)
  end

  def run(_) do
    valid_passwords = 172930..683082
    |> Enum.filter(fn x -> is_valid_password(x) end)

    IO.inspect(valid_passwords)
    IO.puts("Answer: #{length(valid_passwords)}")
  end
end
