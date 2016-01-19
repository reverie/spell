defmodule Spell.User do
  @doc """
  Starts a user with the given ID.
  """

  def start_link(user_id) do
    Agent.start_link(fn -> [] end, name: user_id)
  end

  def get_state(user_id) do
    Agent.get(user_id, fn list -> list end)
  end

  def set_state(user_id, value) do
    Agent.update(user_id, fn state -> value end)
  end
end
