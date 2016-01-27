defmodule Spell.User do
  @doc """
  Starts a user with the given ID.
  """

  defstruct user_id: nil, name: nil, current_room: nil

  def start_link(user) do
    Agent.start_link(fn -> user end, name: user.user_id)
  end

  def get_state(user_id) do
    Agent.get(user_id, fn user -> user end)
  end

  def set_state(user_id, new_user) do
    Agent.update(user_id, fn old_user -> new_user end)
  end
end

defimpl String.Chars, for: Spell.User do
    def to_string(user) do
       "User(#{user.user_id})"
    end
end
