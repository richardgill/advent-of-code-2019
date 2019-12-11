defmodule StringUtils do
  def tuple_to_string(tuple) do
    "{#{Enum.join(Tuple.to_list(tuple), ", ")}}"
  end
end
