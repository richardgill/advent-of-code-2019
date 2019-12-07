defmodule Mix.Tasks.AOC.Day7Part2 do
  use Mix.Task

  def permutations([]), do: [[]]
  def permutations(list), do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def calculate_operation(instructions, index) do
    start_instruction = Enum.at(instructions, index)
    operation = rem(start_instruction, 100)
    mode_1 = rem(Integer.floor_div(start_instruction, 100), 10)
    mode_2 = rem(Integer.floor_div(start_instruction, 1000), 10)
    mode_3 = rem(Integer.floor_div(start_instruction, 10000), 10)
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

  def parameters_for_modes(instructions, index, mode_1, mode_2) do
    [parameter_1, parameter_2, parameter_3] = Enum.slice(instructions, index + 1, 3)
    parameter_1_value = if mode_1 == 0, do: Enum.at(instructions, parameter_1), else: parameter_1
    parameter_2_value = if mode_2 == 0, do: Enum.at(instructions, parameter_2), else: parameter_2
    {parameter_1_value, parameter_2_value, parameter_3}
  end

  def runInstruction({99, _, _, _}, _, instructions, _, output, inputIndex) do
    {:halted, 0, instructions, output, inputIndex}
  end

  def runInstruction({operation, mode_1, mode_2, _}, index, instructions, _, output, inputIndex) when operation in [5, 6] do
    {parameter_1_value, parameter_2_value, _} = parameters_for_modes(instructions, index, mode_1, mode_2)
    new_index = execute_jump_operation(operation, parameter_1_value, parameter_2_value, index)
    {:running, new_index, instructions, output, inputIndex}
  end

  def runInstruction({operation, mode_1, mode_2, _}, index, instructions, _, output, inputIndex) when operation in [1, 2, 7, 8] do
    {parameter_1_value, parameter_2_value, parameter_3_value} = parameters_for_modes(instructions, index, mode_1, mode_2)
    {skip_forward, result} = execute_operation(operation, parameter_1_value, parameter_2_value)
    new_instructions = List.replace_at(instructions, parameter_3_value, result)
    {:running, index + skip_forward, new_instructions, output, inputIndex}
  end

  def runInstruction({3, _, _, _}, index, instructions, inputs, output, inputIndex) do
    parameter = Enum.at(instructions, index + 1)
    new_instructions = List.replace_at(instructions, parameter, Enum.at(inputs, inputIndex))
    {:running, index + 2, new_instructions, output, inputIndex + 1}
  end

  def runInstruction({4, mode_1, _, _}, index, instructions, _, _, inputIndex) do
    parameter = Enum.at(instructions, index + 1)
    output = if mode_1 == 0, do: Enum.at(instructions, parameter), else: parameter
    IO.puts("Output: #{output}")
    {:outputting, index + 2, instructions, output, inputIndex}
  end

  def step_through_program({:running, index, instructions, output, inputIndex}, inputs) do
    instructions
    |> calculate_operation(index)
    |> runInstruction(index, instructions, inputs, output, inputIndex)
  end

  def execute_program({:running, index, instructions, output, inputIndex}, inputs) do
    new_state = step_through_program({:running, index, instructions, output, inputIndex}, inputs)
    execute_program(new_state, inputs)
  end

  def execute_program({:outputting, index, instructions, output, inputIndex}, _) do
    {:running, index, instructions, output, inputIndex}
  end

  def execute_program({:halted, index, instructions, output, inputIndex}, _) do
    {:halted, index, instructions, output, inputIndex}
  end

  def parse_instructions(instructions) do
    instructions
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)
  end

  def run_program(inputs, instructions_string) do
    instructions = parse_instructions(instructions_string)
    execute_program({:running, 0, instructions, nil, 0}, inputs)
  end

  def has_halted(program_state), do: elem(program_state, 0) == :halted

  def get_output(program_state), do: elem(program_state, 3)

  def run_amplifiers_with_phases(instructions, phases, amplifier_program_states, amplifier_index, overall_counter) do
    {amplifier_program_state, inputs} = Enum.at(amplifier_program_states, amplifier_index)
    previous_index = if amplifier_index == 0, do: length(phases) - 1, else: amplifier_index - 1
    last_output = Enum.at(amplifier_program_states, previous_index) |> elem(0) |> get_output() || 0
    new_inputs = inputs ++ [last_output]
    new_state = execute_program(amplifier_program_state, new_inputs)

    if has_halted(new_state) && amplifier_index == length(phases) - 1 do
      get_output(new_state)
    else
      run_amplifiers_with_phases(
        instructions,
        phases,
        List.replace_at(amplifier_program_states, amplifier_index, {new_state, new_inputs}),
        rem(amplifier_index + 1, length(phases)),
        overall_counter + 1
      )
    end
  end

  def find_largest_amplifier_output(instructions_string, phases \\ [5, 6, 7, 8, 9]) do
    instructions = parse_instructions(instructions_string)

    permutations(phases)
    |> Enum.map(fn ps ->
      run_amplifiers_with_phases(instructions, ps, Enum.map(ps, fn phase -> {{:running, 0, instructions, nil, 0}, [phase]} end), 0, 0)
    end)
    |> Enum.max()
  end

  def run(_) do
    # IO.inspect(run_program(1, "1,5,5,0,99,3"))
    # IO.inspect(run_program(1, "2,5,5,0,99,3"))
    # IO.inspect(run_program(1, "11102,5,5,0,99,3"))
    # IO.inspect(run_program(1, "11102,5,5,0,11101,5,5,1,99,3"))
    # IO.inspect(run_program(1, "1102,5,5,0,1101,5,5,1,99,3"))
    # IO.inspect(run_program(1, "104,0,99"))
    # IO.inspect(run_program(1, "102,5,5,0,99,3"))
    # IO.inspect(run_program(1, "1001,5,20,0,99,3"))
    # IO.inspect(run_program(2, "3,9,8,9,10,9,4,9,99,-1,8"))
    # IO.inspect(run_program(0, "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"))
    # IO.inspect(permutations([1,2,3,4,0]))
    # x = run_program([78, 88], "3,0,4,0,3,1,4,1,99")
    # IO.inspect(x)
    # y = execute_program(x, [78, 88])
    # IO.inspect(y)
    # IO.inspect(execute_program(y, [78, 88]))
    # IO.inspect(run_program([1], "4,0,99"))

    # IO.inspect(find_largest_amplifier_output("3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"))
    # IO.inspect(find_largest_amplifier_output("3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"))
    # i = parse_instructions("3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5")
    # phases = [9,8,7,6,5]
    # run_amplifiers_with_phases(i, phases, Enum.map(phases, fn phase -> {{:running, 0, instructions, nil, 0}, [phase]} end), 0, 0)

    # IO.inspect(find_largest_amplifier_output("3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"))

    # IO.inspect(
    #   find_largest_amplifier_output("3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0")
    # )

    input =
      "./lib/mix/tasks/day7/input7.txt"
      |> File.read!()
      |> String.trim()

    answer = find_largest_amplifier_output(input)
    IO.puts("Answer: #{answer}")
  end
end
