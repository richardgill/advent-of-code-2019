defmodule Mix.Tasks.AOC.Day5 do
  use Mix.Task

  def calculate_operation(instructions, index) do
    start_instruction = Enum.at(instructions, index)
    operation = rem(start_instruction, 100)
    mode_1 = rem(Integer.floor_div(start_instruction, 100), 10)
    mode_2 = rem(Integer.floor_div(start_instruction, 1000), 10)
    mode_3 = rem(Integer.floor_div(start_instruction, 10000), 10)
    {operation, mode_1, mode_2, mode_3}
  end

  def execute_operation(1, parameter_1, parameter_2) do
    parameter_1 + parameter_2
  end

  def execute_operation(2, parameter_1, parameter_2) do
    parameter_1 * parameter_2
  end

  def runInstruction({99, _, _, _}, _, instructions, _) do
    {:halted, 0, instructions}
  end

  def runInstruction({operation, mode_1, mode_2, mode_3}, index, instructions, _) when operation in [1, 2] do
    [parameter_1, parameter_2, parameter_3] = Enum.slice(instructions, index + 1, 3)
    parameter_1_value = if mode_1 == 0, do: Enum.at(instructions, parameter_1), else: parameter_1
    parameter_2_value = if mode_2 == 0, do: Enum.at(instructions, parameter_2), else: parameter_2
    parameter_3_value = if mode_3 == 0, do: Enum.at(instructions, parameter_3), else: parameter_3
    output = execute_operation(operation, parameter_1_value, parameter_2_value)
    new_instructions = List.replace_at(instructions, parameter_3, output)
    {:running, 3, new_instructions}
  end

  def runInstruction({3, _, _, _}, index, instructions, input) do
    parameter = Enum.at(instructions, index + 1)
    new_instructions = List.replace_at(instructions, parameter, input)
    {:running, 1, new_instructions}
  end

  def runInstruction({4, mode_1, _, _}, index, instructions, _) do
    parameter = Enum.at(instructions, index + 1)
    output = if mode_1 == 0, do: Enum.at(instructions, parameter), else: parameter
    IO.puts("Output: #{output}")
    {:running, 1, instructions}
  end

  def step_through_program(_, {:halted, 0, instructions}, _) do
    {:halted, 0, instructions}
  end

  def step_through_program(_, {:running, toSkip, instructions}, _) when toSkip > 0 do
    {:running, toSkip - 1, instructions}
  end

  def step_through_program(index, {:running, 0, instructions}, input) do
    instructions
    |> calculate_operation(index)
    |> runInstruction(index, instructions, input)
  end

  def run_program(input, program) do
    instructions =
      program
      |> String.trim()
      |> String.split(",")
      |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)

    0..(length(instructions) - 1)
    |> Enum.reduce({:running, 0, instructions}, fn index, state ->
      step_through_program(index, state, input)
    end)
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
    input =
      "./lib/mix/tasks/day5/input5.txt"
      |> File.read!()
      |> String.trim()

    IO.puts("Answer:")
    run_program(1, input)
  end
end
