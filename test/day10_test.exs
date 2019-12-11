defmodule Day10Tests do
  use ExUnit.Case
  doctest Mix.Tasks.AOC.Day10

  line_of_sight_test_cases = [
    {{0,0}, {0,1}, [], true},
    {{1,0}, {0,1}, [], true},
    {{4,0}, {0,0}, [], true},
    {{3,4}, {3,2}, [], true},
    {{4,0}, {0,0}, [{3,0}], false},
    {{0,4}, {0,0}, [{0,3}], false},
    {{0,0}, {0,5}, [{0, 4}], false},
    {{0,0}, {0,5}, [{3, 4}], true},
    {{0,0}, {0,5}, [{0, 1}], false},
    {{0,0}, {1,1}, [{0, 1}], true},
    {{0,0}, {2,2}, [{1, 1}], false},
    {{0,0}, {5,5}, [{1, 1}], false},
    {{0,0}, {6,2}, [{3, 1}], false},
    {{0,0}, {6,2}, [{1, 1}], true},
    {{1,1}, {7,3}, [{1, 2}], true},
    {{1,1}, {7,3}, [{4, 2}], false},
    {{1, 0}, {4, 3}, [{3, 2}], false},
    {{1, 0}, {3, 2}, [{5, 4}], true},
    {{3, 2}, {1, 0}, [{4, 3}], true},
    {{2, 2}, {0, 4}, [{0, 3}], true},
  ]


  for {reference, target, coordinates, expected_result} <- line_of_sight_test_cases do
    @pair {reference, target, coordinates, expected_result}
    reference_string = StringUtils.tuple_to_string(reference)
    target_string = StringUtils.tuple_to_string(target)
    coordinates_string = coordinates |> Enum.map(fn x -> StringUtils.tuple_to_string(x) end) |> Enum.join(", ")
    test "#{reference_string} to #{target_string} with #{coordinates_string} should be #{expected_result}" do
      {reference, target, coordinates, expected_result} = @pair
      assert Mix.Tasks.AOC.Day10.has_direct_line_of_sight(reference, target, coordinates) == expected_result
    end
  end
end
