defmodule Mix.Tasks.AOC.Day5Part2 do
  use Mix.Task

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

  def runInstruction({99, _, _, _}, _, instructions, _) do
    {:halted, 0, instructions}
  end

  def runInstruction({operation, mode_1, mode_2, _}, index, instructions, _) when operation in [5, 6] do
    {parameter_1_value, parameter_2_value, _} = parameters_for_modes(instructions, index, mode_1, mode_2)
    new_index = execute_jump_operation(operation, parameter_1_value, parameter_2_value, index)
    {:running, new_index, instructions}
  end

  def runInstruction({operation, mode_1, mode_2, _}, index, instructions, _) when operation in [1, 2, 7, 8] do
    {parameter_1_value, parameter_2_value, parameter_3_value} = parameters_for_modes(instructions, index, mode_1, mode_2)
    {skip_forward, output} = execute_operation(operation, parameter_1_value, parameter_2_value)
    new_instructions = List.replace_at(instructions, parameter_3_value, output)
    {:running, index + skip_forward, new_instructions}
  end

  def runInstruction({3, _, _, _}, index, instructions, input) do
    parameter = Enum.at(instructions, index + 1)
    new_instructions = List.replace_at(instructions, parameter, input)
    {:running, index + 2, new_instructions}
  end

  def runInstruction({4, mode_1, _, _}, index, instructions, _) do
    parameter = Enum.at(instructions, index + 1)
    output = if mode_1 == 0, do: Enum.at(instructions, parameter), else: parameter
    IO.puts("Output: #{output}")
    {:running, index + 2, instructions}
  end

  def step_through_program({:running, index, instructions}, input) do
    instructions
    |> calculate_operation(index)
    |> runInstruction(index, instructions, input)
  end

  def execute_program({:halted, _, instructions}, _) do
    instructions
  end

  def execute_program(state, input) do
    new_state = step_through_program(state, input)
    execute_program(new_state, input)
  end

  def run_program(input, program) do
    instructions =
      program
      |> String.trim()
      |> String.split(",")
      |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)

    execute_program({:running, 0, instructions}, input)
  end

  def run(_) do
    # IO.inspect(run_program(1, "1,5,5,0,99,3"))
    # IO.inspect(run_program(1, "2,5,5,0,99,3"))
    # IO.inspect(run_program(1, "11102,5,5,0,99,3"))
    # IO.inspect(run_program(1, "11102,5,5,0,11101,5,5,1,99,3"))
    # IO.inspect(run_program(1, "1102,5,5,0,1101,5,5,1,99,3"))
    # IO.inspect(run_program(78, "3,0,99"))
    # IO.inspect(run_program(1, "4,0,99"))
    # IO.inspect(run_program(1, "104,0,99"))
    # IO.inspect(run_program(1, "102,5,5,0,99,3"))
    # IO.inspect(run_program(1, "1001,5,20,0,99,3"))
    # IO.inspect(run_program(2, "3,9,8,9,10,9,4,9,99,-1,8"))
    # IO.inspect(run_program(0, "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"))
    input =
      "./lib/mix/tasks/day5/input5.txt"
      |> File.read!()
      |> String.trim()

    IO.puts("Answer:")
    run_program(5, input)
  end
end
