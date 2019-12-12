defmodule Day11Tests do
  use ExUnit.Case
  doctest Mix.Tasks.AOC.Day11

  calculate_direction_cases = [
    {3, 0, 2},
    {2, 0, 1},
    {1, 0, 0},
    {0, 0, 3},
    {3, 1, 0},
    {2, 1, 3},
    {1, 1, 2},
    {0, 1, 1},
  ]

  describe "calculate_direction" do
    for {direction, turn, expected_result} <- calculate_direction_cases do
      @pair {direction, turn, expected_result}
      test "#{direction} and #{turn} should be #{expected_result}" do
        {direction, turn, expected_result} = @pair
        assert Mix.Tasks.AOC.Day11.calculate_direction(direction, turn) == expected_result
      end
    end
  end

  coordinate_for_direction_cases = [
    {{0, 0}, 0, {0, 1}},
    {{0, 1}, 0, {0, 2}},
    {{0, 7}, 0, {0, 8}},
    {{0, 7}, 1, {1, 7}},
    {{0, 7}, 2, {0, 6}},
    {{0, 7}, 3, {-1, 7}},
    {{0, 0}, 3, {-1, 0}},
    {{0, 0}, 2, {0, -1}},
  ]

  describe "coordinate_for_direction" do
    for {coordinate, direction, expected_result} <- coordinate_for_direction_cases do
      @pair {coordinate, direction, expected_result}
      coordinate_string = StringUtils.tuple_to_string(coordinate)
      expected_result_string = StringUtils.tuple_to_string(expected_result)
      test "#{coordinate_string} and #{direction} should be #{expected_result_string}" do
        {coordinate, direction, expected_result} = @pair
        assert Mix.Tasks.AOC.Day11.coordinate_for_direction(coordinate, direction) == expected_result
      end
    end
  end
end
