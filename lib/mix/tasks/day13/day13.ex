defmodule Mix.Tasks.AOC.Day13 do
  use Mix.Task

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
    {:inputting, index + 2, new_instructions, output, inputIndex + 1, relative_base_offset}
  end

  def runInstruction({4, mode_1, _, _}, index, instructions, _, _, inputIndex, relative_base_offset) do
    parameter = Enum.at(instructions, index + 1)
    output = parameter_value_for_mode(instructions, mode_1, parameter, relative_base_offset)
    # output = Enum.at(instructions, output_index)
    # IO.puts("Output: #{output}")
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

  def execute_program({:inputting, index, instructions, output, inputIndex, relative_base_offset}, inputs) when inputIndex < length(inputs) do
    execute_program({:running, index, instructions, output, inputIndex, relative_base_offset}, inputs)
  end

  def execute_program({:inputting, index, instructions, output, inputIndex, relative_base_offset}, _) do
    {:inputting, index, instructions, output, inputIndex, relative_base_offset}
  end

  def execute_program({:outputting, index, instructions, output, inputIndex, relative_base_offset}, _) do
    {:outputting, index, instructions, output, inputIndex, relative_base_offset}
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

  def execute_program_until_halted(program_state, inputs, outputs) do
    state = execute_program(program_state, inputs)

    case state do
      {:halted, _, _, _, _, _} ->
        {state, outputs}
      {:outputting, index, instructions, output, inputIndex, relative_base_offset} ->
        execute_program_until_halted({:running, index, instructions, output, inputIndex, relative_base_offset}, inputs, outputs ++ [output])
      {:inputting, _, _, _, _, _} ->
        {state, outputs}
    end
  end

  def run_program(inputs, instructions_string) do
    instructions = parse_instructions(instructions_string)
    execute_program_until_halted({:running, 0, instructions, nil, 0, 0}, inputs, [])
  end

  def print_tile(tile_type) do
    to_print = case tile_type do
      0 -> " "
      1 -> "X"
      2 -> "B"
      3 -> "-"
      4 -> "O"
    end
    IO.write(to_print)
  end

  def print_game(tiles) do
    xs = tiles |> remove_score() |> Enum.map(fn t -> Enum.at(t, 0) end)
    ys = tiles |> remove_score() |> Enum.map(fn t -> Enum.at(t, 1) end)
    min_x = xs |> Enum.min()
    max_x = xs |> Enum.max()
    min_y = ys |> Enum.min()
    max_y = ys |> Enum.max()
    IO.puts("\n\nScore: #{get_score(tiles)}")

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        [_, _, tile_type] = (tiles |> Enum.find(fn [tx, ty, _] -> tx == x && ty == y end)) || [0,0, -1]
        print_tile(tile_type)
      end
      IO.write("\n")
    end
    :timer.sleep(100)

  end

  def is_score([-1,0, _]), do: true
  def is_score(_), do: false

  def get_score(tiles) do
    [_, _, score] = tiles |> Enum.find(&is_score/1)
    score
  end

  def remove_score(tiles) do
    tiles
    |> Enum.reject(&is_score/1)
  end

  def update_tiles([], new_tiles), do:  new_tiles

  def update_tiles(old_tiles, new_tiles) do
    old_tiles
    |> Enum.map(fn [x, y, tile_type] ->
      tile = new_tiles |> Enum.reverse() |> Enum.find(fn [new_tile_x, new_tile_y, _] -> new_tile_x == x && new_tile_y == y  end)
      tile || [x, y, tile_type]
    end)
  end

  def is_type_of_type?([_, _, tile_type], type) do
    tile_type === type
  end

  def find_tile_of_type(tiles, type) do
    tiles |> Enum.find(fn t -> is_type_of_type?(t, type) end)
  end

  def drop_last(xs), do: xs |> Enum.reverse() |> Enum.drop(1) |> Enum.reverse()

  # def calculate_next_ball_position(old_tiles, new_tiles) do
  #   [paddle_x, paddle_y, _] = find_type_of_type(new_tiles, 3)
  #   [old_paddle_x, old_paddle_y, _] = find_type_of_type(old_tiles, 3)
  #   [ball_x, ball_y, _] = find_type_of_type(new_tiles, 4) || [old_paddle_x, old_paddle_y, 4]
  #   [previous_ball_x, previous_ball_y, _] = find_type_of_type(old_tiles, 4) || [paddle_x, paddle_y, 4]

  #   going_right = ball_x > previous_ball_x
  #   going_left = !going_right
  #   going_up = ball_y < previous_ball_y
  #   going_down = !going_up

  #   next_x = if going_right, do: ball_x + 1, else: ball_x - 1
  #   next_y = if going_up, do: ball_y + 1, else: ball_y - 1

  #   [next_x, next_y]
  # end
  # def calculate_joystick_move([],_, _), do: 1
  # # def calculate_joystick_move(x, _), do: 0

  # def calculate_joystick_move(old_tiles, tiles, last_input) do
  #   [paddle_x, paddle_y, _] = find_type_of_type(tiles, 3)
  #   [old_paddle_x, old_paddle_y, _] = find_type_of_type(old_tiles, 3)
  #   [ball_x, ball_y, _] = find_type_of_type(tiles, 4) || [old_paddle_x, old_paddle_y, 4]
  #   [previous_ball_x, previous_ball_y, _] = find_type_of_type(old_tiles, 4) || [paddle_x, paddle_y, 4]
  #   IO.inspect(calculate_next_ball_position(old_tiles, tiles))
  #   [next_ball_x, next_ball_y] = calculate_next_ball_position(old_tiles, tiles)
  #   direction = if next_ball_x > ball_x, do: 1, else: -1
  #   # direction = if previous_ball_y < ball_y, do: -1 * direction, else: direction
  #   steps_until_cross_paddle = paddle_y - ball_y
  #   target_paddle_x =  ball_x + (steps_until_cross_paddle * direction)
  #   paddle_moving_left = last_input == -1
  #   paddle_moving_right = last_input == 1
  #   IO.puts("paddle_x #{paddle_x}")
  #   IO.puts("#{ball_x}, #{ball_y}")
  #   IO.puts("paddle_moving_right #{paddle_moving_right}")
  #   IO.puts("paddle_moving_left #{paddle_moving_left}")
  #   IO.puts("direction #{direction}")
  #   IO.puts("steps_until_cross_paddle #{steps_until_cross_paddle}")
  #   IO.puts("target_paddle_x #{target_paddle_x}")
  #   # cond do
  #   #   next_ball_x == target_paddle_x -> 0
  #   #   next_ball_x < target_paddle_x -> 1
  #   #   next_ball_x > target_paddle_x -> -1
  #   # end
  #   cond do
  #     paddle_x == target_paddle_x -> 0
  #     paddle_x < target_paddle_x -> 1
  #     paddle_x > target_paddle_x -> -1
  #   end
  #   # cond do
  #   #   target_paddle_x - paddle_x === 1 -> if paddle_moving_right, do: 0, else: 1
  #   #   target_paddle_x - paddle_x === -1 -> if paddle_moving_left, do: 0, else: -1
  #   #   paddle_x + 1 < target_paddle_x -> 1
  #   #   paddle_x - 1 > target_paddle_x -> -1
  #   #   paddle_x == target_paddle_x && !paddle_moving_left && !paddle_moving_right -> 0
  #   #   paddle_x == target_paddle_x && paddle_moving_left -> 1
  #   #   paddle_x == target_paddle_x && paddle_moving_right -> -1
  #   # end
  # end

  # Ball bounces when ball_y 20, 21, 20
  # ball_y below 20 is fail

  def step_through_game(program_state, input, old_tiles) do
    {{_, index, instructions, output, _, relative_base_offset}, outputs} = execute_program_until_halted(program_state, [input], [])
    new_tiles = outputs |> Enum.chunk_every(3)
    tiles = update_tiles(old_tiles, new_tiles)

    print_game(tiles)

    {{:running, index, instructions, output, 0, relative_base_offset}, tiles}
  end

  def has_missed_ball([]), do: false

  def has_missed_ball(tile_states) do
    [_, ball_y, _] = tile_states
    |> List.last()
    |> find_tile_of_type(4)

    # IO.puts("has missed ball result #{ball_y}")
    ball_y > 21
  end

  def has_hit_ball(tile_states) do
    if length(tile_states) >= 3 do
      [_, ball_y_1, _] = find_tile_of_type(tile_states |> Enum.reverse() |> Enum.drop(2) |> List.first(), 4)
      [_, ball_y_2, _] = find_tile_of_type(tile_states |> Enum.reverse() |> Enum.drop(1) |> List.first(), 4)
      [_, ball_y_3, _] = find_tile_of_type(tile_states |> Enum.reverse() |> List.first(), 4)
      ball_y_1 == 20 && ball_y_2 == 21 && ball_y_3 == 20
    else
      false
    end
  end



  def run_inputs(program_states, tile_states, []) do
    {List.last(program_states), List.last(tile_states)}
  end

  def run_inputs(program_states, tile_states, [input | rest_of_inputs]) do
    {new_program_state, tiles} = step_through_game(List.last(program_states), input, List.last(tile_states) || [])
    run_inputs(program_states ++ [new_program_state], tile_states ++ [tiles], rest_of_inputs)
  end

  def find_where_ball_hits(program_states, tile_states) do
    cond do
      has_hit_ball(tile_states)
        ->
          # IO.puts("has hit ball")
          [x_where_ball_hits, _, _] = find_tile_of_type(tile_states |> List.last(), 3)
          # IO.puts(x_where_ball_hits)
          {x_where_ball_hits, program_states |> drop_last() |> length(), program_states |> drop_last() |> List.last(), tile_states |> drop_last() |> List.last()}
        # -> inputs |> Enum.reverse() |> Enum.drop(1) |> Enum.reverse()
      has_missed_ball(tile_states)
        ->
          # IO.puts("has missed ball")
          [x_where_ball_hits, _, _] = find_tile_of_type(List.last(tile_states), 4)
          # IO.puts(x_where_ball_hits)
          {x_where_ball_hits, program_states |> drop_last() |> length(), program_states |> drop_last() |> List.last(), tile_states |> drop_last() |> List.last()}
      true ->

        {new_program_state, tiles} = step_through_game(List.last(program_states), 0, List.last(tile_states) || [])

        find_where_ball_hits(program_states ++ [new_program_state], tile_states ++ [tiles])
    end
  end

  def randomise_0_moves(moves) do
    zero_move_count = moves
    |> Enum.count(fn move -> move == 0 end)
    random_moves = if zero_move_count > 1 do
      1..Integer.floor_div(zero_move_count, 2)
      |> Enum.flat_map(fn _ -> [-1,1] end)
    else
      []
    end
    zeros = if rem(zero_move_count, 2) == 0, do: [], else: [0]
    non_zero_moves = moves |> Enum.filter(fn move -> move != 0 end)
    # IO.inspect(moves)
    # IO.inspect(zero_move_count)
    # IO.inspect(Integer.floor_div(zero_move_count, 2))
    # IO.inspect(random_moves)
    # IO.inspect(zeros)
    # IO.inspect(non_zero_moves)
    # IO.inspect(non_zero_moves ++ random_moves ++ zeros)
    result = Enum.shuffle(non_zero_moves ++ random_moves ++ zeros)
    # IO.inspect(result)
    # :timer.sleep(5000)

    result
  end

  def find_inputs_to_hit_ball(program_state, tile_states) do
    program_states = [program_state]
    {x_where_ball_hits, steps, _, new_tiles} = find_where_ball_hits(program_states, tile_states)
    [current_paddle_x, _, _] = find_tile_of_type(new_tiles, 3)

    has_repeated = length(tile_states) >= 2 && Enum.at(tile_states, length(tile_states) - 1 ) == Enum.at(tile_states, length(tile_states) - 2)

    move = x_where_ball_hits - current_paddle_x
    remaining_steps = steps - abs(move)
    input_moves = if move == 0, do: [], else: 1..abs(move) |> Enum.map(fn _ -> if move > 0, do: 1, else: -1 end)
    step_moves = if remaining_steps == 0, do: [], else: 1..remaining_steps |> Enum.map(fn _ -> 0 end)
    raw_inputs = drop_last(input_moves ++ step_moves)
    # IO.puts("Move is: #{move}")
    randomised_inputs = randomise_0_moves(raw_inputs)

    inputs = if blocks_remaining(tile_states) == 172, do: randomised_inputs, else: raw_inputs
    IO.inspect(raw_inputs)
    IO.inspect(randomised_inputs)
    IO.inspect(inputs)
    {new_program_state, after_input_tiles} = run_inputs(program_states, tile_states, inputs)

    {new_program_state, inputs, after_input_tiles}
  end

  def blocks_remaining(tile_states) do
    if Enum.empty?(tile_states) do
      nil
    else
      (tile_states |> List.last() |> Enum.filter(fn t -> is_type_of_type?(t, 2) end) |> length())
    end
  end

  def find_winning_inputs_helper(program_state, inputs, tile_states) do
    IO.inspect(Enum.join(inputs, ","))
    IO.inspect(blocks_remaining(tile_states))
    if !Enum.empty?(tile_states) && (tile_states |> List.last() |> find_tile_of_type(2)) == nil do
      inputs
    else
      {new_program_state, new_inputs, new_tiles} = find_inputs_to_hit_ball(program_state, tile_states)
      find_winning_inputs_helper(new_program_state, inputs ++ new_inputs, [new_tiles])
    end

  end

  def find_winning_inputs(instructions_string) do
    instructions = parse_instructions(instructions_string)
    find_winning_inputs_helper({:running, 0, instructions, nil, 0, 0}, [], [])
  end

  def play_game_helper(_, []) do
    nil
  end

  def play_game_helper(program_state, inputs, old_tiles) do
    {new_program_state, tiles} = step_through_game(program_state, List.first(inputs), old_tiles)
    play_game_helper(new_program_state, Enum.drop(inputs, 1), tiles)
  end

  def play_game(instructions_string, inputs) do
    instructions = parse_instructions(instructions_string)
    play_game_helper({:running, 0, instructions, nil, 0, 0}, inputs, [])
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
    # IO.inspect(update_tiles([[1, 1, 1], [0, 0, 4]], [[1,1,4]]))
    IO.inspect(randomise_0_moves([0,0,0]))
    IO.inspect(randomise_0_moves([0,0,0, 0]))
    IO.inspect(randomise_0_moves([1,0,0]))
    IO.inspect(randomise_0_moves([-1,0,0]))
    IO.inspect(randomise_0_moves([1,-1,0]))
    IO.inspect(randomise_0_moves([1,1,1]))
    IO.inspect(randomise_0_moves([1,1,1]))
    IO.inspect(randomise_0_moves([1,1,1,0,0,0]))
    IO.inspect(randomise_0_moves([1,1,1,0,0]))
    instructions_string =
      "./lib/mix/tasks/day13/input13.txt"
      |> File.read!()
      |> String.trim()

    # winning_inputs = find_winning_inputs(instructions_string)
    # IO.puts("winning_inputs: ")
    # IO.inspect(winning_inputs)
    play_game(instructions_string, [])
    # good_input = [0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    # |> Enum.filter(fn [x, y, tile] -> tile == 2 end)
    # |> length()
    # |> IO.inspect()

  end
end
