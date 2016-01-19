defmodule Spell.Room do
  @doc """
  Starts a room with the given name.
  """

  def start_link(room_id) do
    Agent.start_link(fn -> [] end, name: room_id)
  end

  def get(room_id) do
    Agent.get(room_id, fn list -> list end)
  end


  def push(room_id, value) do
    Agent.update(room_id, fn list -> [value|list] end)
  end

  @doc """
  Returns `{:ok, value}` if there is a value
  or `:error` if the hole is currently empty.
  """
  def pop(room_id) do
    Agent.get_and_update(room_id, fn
      []    -> {:error, []}
      [h|t] -> {{:ok, h}, t}
    end)
  end
end