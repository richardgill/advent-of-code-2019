defmodule Mix.Tasks.AOC.Day2Part2 do
  use Mix.Task

  def executeOp(1, arg1, arg2) do
    arg1 + arg2
  end

  def executeOp(2, arg1, arg2) do
    arg1 * arg2
  end

  def runProgram(program) do
    instructionStartingIndexes =
      0..Integer.floor_div(length(program), 4)
      |> Enum.to_list()
      |> Enum.map(fn x -> x * 4 end)

    output =
      Enum.reduce(instructionStartingIndexes, {:running, program}, fn programIndex, {status, resultingProgram} ->
        if status === :halted || Enum.at(resultingProgram, programIndex) == 99 do
          {:halted, resultingProgram}
        else
          [op, arg1Index, arg2Index, resultIndex] = Enum.slice(resultingProgram, programIndex, 4)

          calculatedValue =
            executeOp(
              op,
              Enum.at(resultingProgram, arg1Index),
              Enum.at(resultingProgram, arg2Index)
            )

          {:running, List.replace_at(resultingProgram, resultIndex, calculatedValue)}
        end
      end)

    elem(output, 1)
  end

  def runProgramWithInput(program, arg1, arg2) do
    program
    |> List.replace_at(1, arg1)
    |> List.replace_at(2, arg2)
    |> runProgram()
    |> List.first()
  end

  def run(_) do
    # IO.inspect(runProgram([1,0,0,0,99]))
    # IO.inspect(runProgram([2,3,0,3,99]))
    # IO.inspect(runProgram([2,4,4,5,99,0]))
    # IO.inspect(runProgram([1,1,1,4,99,5,6,0,99]))

    program = FileUtils.splitFileToIntegers("./lib/mix/tasks/day2/input2.txt", ",")
    inputPairs = for noun <- 0..99, verb <- 0..99, do: {noun, verb}
    IO.inspect(inputPairs)

    {noun, verb} =
      inputPairs
      |> Enum.find(fn {noun, verb} -> runProgramWithInput(program, noun, verb) == 19_690_720 end)

    IO.puts("Noun: #{noun} Verb: #{verb}")

    IO.puts("Answer: #{100 * noun + verb}")
  end
end
