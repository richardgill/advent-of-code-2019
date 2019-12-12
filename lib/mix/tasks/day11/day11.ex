defmodule Mix.Tasks.AOC.Day11 do
  use Mix.Task

  def permutations([]), do: [[]]
  def permutations(list), do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def calculate_operation(instructions, index) do
    start_instruction = Enum.at(instructions, index)
    operation = rem(start_instruction, 100)
    mode_1 = rem(Integer.floor_div(start_instruction, 100), 10)
    mode_2 = rem(Integer.floor_div(start_instruction, 1000), 10)
    mode_3_raw = rem(Integer.floor_div(start_instruction, 10000), 10)

    mode_3 = if mode_3_raw == 0, do: 1, else: mode_3_raw
    {operation, mode_1, mode_2, mode_3}
  end

  def execute_operation(1, parameter_1, parameter_2), do: {4, parameter_1 + parameter_2}

  def execute_operation(2, parameter_1, parameter_2), do: {4, parameter_1 * parameter_2}

  def execute_operation(7, parameter_1, parameter_2) when parameter_1 < parameter_2, do: {4, 1}
  def execute_operation(7, _, _), do: {4, 0}

  def execute_operation(8, parameter_1, parameter_2) when parameter_1 == parameter_2, do: {4, 1}
  def execute_operation(8, _, _), do: {4, 0}

  def execute_jump_operation(5, 0, _, index), do: index + 3
  def execute_jump_operation(5, _, parameter_2, _), do: parameter_2

  def execute_jump_operation(6, 0, parameter_2, _), do: parameter_2
  def execute_jump_operation(6, _, _, index), do: index + 3

  def parameter_index_for_mode(mode, parameter, relative_base_offset) do
    case mode do
      0 ->
        parameter

      1 ->
        parameter

      2 ->
        relative_base_offset + parameter
    end
  end

  def parameter_value_for_mode(instructions, mode, parameter, relative_base_offset) do
    case mode do
      0 ->
        Enum.at(instructions, parameter) || 0

      1 ->
        parameter

      2 ->
        Enum.at(instructions, relative_base_offset + parameter) || 0
    end
  end

  def replace_in_memory(instructions, index, value) do
    if index < length(instructions) do
      List.replace_at(instructions, index, value)
    else
      memory_to_add = index - length(instructions)
      instructions ++ Enum.map(0..memory_to_add, fn x -> if x == memory_to_add, do: value, else: 0 end)
    end
  end

  def parameters_for_modes(instructions, index, mode_1, mode_2, mode_3, relative_base_offset) do
    [parameter_1, parameter_2, parameter_3] = Enum.slice(instructions, index + 1, 3)
    parameter_1_value = parameter_value_for_mode(instructions, mode_1, parameter_1, relative_base_offset)
    parameter_2_value = parameter_value_for_mode(instructions, mode_2, parameter_2, relative_base_offset)
    parameter_3_value = parameter_index_for_mode(mode_3, parameter_3, relative_base_offset)
    {parameter_1_value, parameter_2_value, parameter_3_value}
  end

  def runInstruction({99, _, _, _}, _, instructions, _, output, inputIndex, relative_base_offset) do
    {:halted, 0, instructions, output, inputIndex, relative_base_offset}
  end

  def runInstruction({operation, mode_1, mode_2, mode_3}, index, instructions, _, output, inputIndex, relative_base_offset)
      when operation in [5, 6] do
    {parameter_1_value, parameter_2_value, _} = parameters_for_modes(instructions, index, mode_1, mode_2, mode_3, relative_base_offset)
    new_index = execute_jump_operation(operation, parameter_1_value, parameter_2_value, index)
    {:running, new_index, instructions, output, inputIndex, relative_base_offset}
  end

  def runInstruction({operation, mode_1, mode_2, mode_3}, index, instructions, _, output, inputIndex, relative_base_offset)
      when operation in [1, 2, 7, 8] do
    {parameter_1_value, parameter_2_value, parameter_3_value} =
      parameters_for_modes(instructions, index, mode_1, mode_2, mode_3, relative_base_offset)

    {skip_forward, result} = execute_operation(operation, parameter_1_value, parameter_2_value)
    new_instructions = replace_in_memory(instructions, parameter_3_value, result)
    {:running, index + skip_forward, new_instructions, output, inputIndex, relative_base_offset}
  end

  def runInstruction({3, mode_1, _, _}, index, instructions, inputs, output, inputIndex, relative_base_offset) do
    raw_parameter = Enum.at(instructions, index + 1)
    parameter = parameter_index_for_mode(mode_1, raw_parameter, relative_base_offset)
    new_instructions = replace_in_memory(instructions, parameter, Enum.at(inputs, inputIndex))
    {:running, index + 2, new_instructions, output, inputIndex + 1, relative_base_offset}
  end

  def runInstruction({4, mode_1, _, _}, index, instructions, _, _, inputIndex, relative_base_offset) do
    parameter = Enum.at(instructions, index + 1)
    output = parameter_value_for_mode(instructions, mode_1, parameter, relative_base_offset)
    # output = Enum.at(instructions, output_index)
    IO.puts("Output: #{output}")
    {:outputting, index + 2, instructions, output, inputIndex, relative_base_offset}
  end

  def runInstruction({9, mode_1, mode_2, mode_3}, index, instructions, _, output, inputIndex, relative_base_offset) do
    {parameter, _, _} = parameters_for_modes(instructions, index, mode_1, mode_2, mode_3, relative_base_offset)
    {:running, index + 2, instructions, output, inputIndex, relative_base_offset + parameter}
  end

  def step_through_program({:running, index, instructions, output, inputIndex, relative_base_offset}, inputs) do
    instructions
    |> calculate_operation(index)
    # |> IO.inspect()
    |> runInstruction(index, instructions, inputs, output, inputIndex, relative_base_offset)
  end

  def execute_program({:running, index, instructions, output, inputIndex, relative_base_offset}, inputs) do
    new_state = step_through_program({:running, index, instructions, output, inputIndex, relative_base_offset}, inputs)
    # IO.inspect(new_state)
    execute_program(new_state, inputs)
  end

  def execute_program({:outputting, index, instructions, output, inputIndex, relative_base_offset}, _) do
    {:running, index, instructions, output, inputIndex, relative_base_offset}
  end

  def execute_program({:halted, index, instructions, output, inputIndex, relative_base_offset}, _) do
    {:halted, index, instructions, output, inputIndex, relative_base_offset}
  end

  def parse_instructions(instructions) do
    instructions
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)
  end

  def has_halted(program_state), do: elem(program_state, 0) == :halted
  def get_output(program_state), do: elem(program_state, 3)

  def execute_program_until_halted(program_state, inputs) do
    state = execute_program(program_state, inputs)

    if has_halted(state) do
      state
    else
      execute_program_until_halted(state, inputs)
    end
  end

  def run_program(inputs, instructions_string) do
    instructions = parse_instructions(instructions_string)
    execute_program_until_halted({:running, 0, instructions, nil, 0, 0}, inputs)
  end

  def coordinate_for_direction({x, y}, direction) do
    case direction do
      0 ->
        {x, y + 1}

      1 ->
        {x + 1, y}

      2 ->
        {x, y - 1}

      3 ->
        {x - 1, y}
    end
  end

  def calculate_direction(direction, raw_turn) do
    turn  = if raw_turn == 0, do: -1, else: raw_turn
    new_direction = direction + turn

    case new_direction do
      4 ->
        0

      -1 ->
        3

      _ ->
        new_direction
    end
  end

  def calculate_hull_state(color, turn, {coordinates, robot_direction, robot_coordinate}) do
    direction = calculate_direction(robot_direction, turn)
    {coordinates ++ [{robot_coordinate, color}], direction, coordinate_for_direction(robot_coordinate, direction)}
  end

  def paint_hull(instructions_string) do
    instructions = parse_instructions(instructions_string)
    paint_hull_helper([0], {[], 0, {0, 0}}, {:running, 0, instructions, nil, 0, 0})
  end

  def find_color(coordinates, coordinate) do
    matching_coordinate = coordinates
    |> Enum.reverse()
    |> Enum.find(fn c -> elem(c, 0) == coordinate end)


    if matching_coordinate, do: elem(matching_coordinate, 1), else: 0

  end

  def paint_hull_helper(inputs, {coordinates, robot_direction, robot_coordinate}, program_state) do
    # :timer.sleep(2000)

    # IO.inspect(inputs)
    IO.inspect(coordinates)
    IO.puts("\n")
    # IO.inspect(robot_direction)
    # IO.inspect(robot_coordinate)
    new_state_1 = execute_program(program_state, inputs)
    new_state_2 = execute_program(new_state_1, inputs)

    if has_halted(new_state_2) do
      coordinates
    else
      color = get_output(new_state_1)
      turn = get_output(new_state_2)
      {new_coordinates, new_robot_direction, new_robot_coordinate} = calculate_hull_state(color, turn, {coordinates, robot_direction, robot_coordinate})
      next_color = find_color(new_coordinates, new_robot_coordinate)
      paint_hull_helper(inputs ++ [next_color], {new_coordinates, new_robot_direction, new_robot_coordinate}, new_state_2)
    end
  end

  def run(_) do
    # IO.inspect(run_program([], "1,5,5,0,99,3"))
    # IO.inspect(run_program(1, "2,5,5,0,99,3"))
    # IO.inspect(run_program(1, "11102,5,5,0,99,3"))
    # IO.inspect(run_program(1, "11102,5,5,0,11101,5,5,1,99,3"))
    # IO.inspect(run_program(1, "1102,5,5,0,1101,5,5,1,99,3"))
    # IO.inspect(run_program([1], "3,0,4,0,104,10,99"))
    # IO.inspect(run_program([], "104,0,99"))
    # IO.inspect(run_program([], "109,2,204,0,99"))
    # IO.inspect(run_program(1, "102,5,5,0,99,3"))
    # IO.inspect(run_program(1, "1001,5,20,0,99,3"))
    # IO.inspect(run_program(2, "3,9,8,9,10,9,4,9,99,-1,8"))
    # IO.inspect(run_program(0, "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"))
    # IO.inspect(run_program([], "109,1,204,-1,99"))
    # IO.inspect(run_program([], "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"))
    # IO.inspect(run_program([], "1102,34915192,34915192,7,4,7,99,0"))
    # IO.inspect(run_program([], "104,1125899906842624,99"))
    # IO.inspect(run_program([1], "3,0,99"))
    # IO.inspect(run_program([1], "103,0,99"))
    # IO.inspect(run_program([88], "109,2,203,-1,99"))
    # IO.inspect(run_program([], "109,2,204,-1,99"))
    # IO.inspect(run_program([], "109,2,104,-1,99"))
    # IO.inspect(run_program([], "109,2,4,0,99"))
    # IO.inspect(run_program([], "109,2,21102,0,1,0,99"))
    # IO.inspect(replace_in_memory([0,1,2,3], 3, 999))
    # IO.inspect(replace_in_memory([0,1,2,3], 4, 999))
    # IO.inspect(replace_in_memory([0,1,2,3], 5, 999))
    # IO.inspect(replace_in_memory([0,1,2,3], 7, 999))
    # instructions_string =
    #   "./lib/mix/tasks/day9/input9.txt"
    #   |> File.read!()
    #   |> String.trim()

    # IO.inspect(run_program([1], instructions_string))

    instructions_string =
      "./lib/mix/tasks/day11/input11.txt"
      |> File.read!()
      |> String.trim()

    coordinates = paint_hull(instructions_string)

    Enum.map(coordinates, fn c -> elem(c, 0) end)
    |> IO.inspect()
    |> MapSet.new()
    |> MapSet.size()
    |> IO.inspect()
  end
end
