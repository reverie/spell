defmodule Spell do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    upa_agent = %Spell.User{
                  user_id: :upa_agent,
                  name: "Wompus",
                  current_room: nil
                }

    treehouse = %Spell.Room{
                  room_id: :treehouse,
                  name: "Treehouse",
                  exits: %{
                    :d => :dungeon
                  }
                }

    dungeon = %Spell.Room{
                  room_id: :dungeon,
                  name: "Ye Olde Dungeon",
                  exits: %{
                    :u => :treehouse
                  }
                }

    users = [upa_agent]
    rooms = [treehouse, dungeon]

    user_children = Enum.map(users, fn u -> worker(Spell.User, [u], [id: u.user_id]) end)
    room_children = Enum.map(rooms, fn r -> worker(Spell.Room, [r], [id: r.room_id]) end)
    children = Enum.concat([user_children, room_children])

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spell.Supervisor]
    result = Supervisor.start_link(children, opts)

    IO.puts ("User has: " <> to_string(Spell.User.get_state(:upa_agent)))
    action = IO.gets "Whatcha gonna do about it? >"
    Spell.User.set_state(:upa_agent, action)
    IO.puts ("User NOW has: " <> to_string(Spell.User.get_state(:upa_agent)))
    result
  end
end
