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


    children = [
      # Define workers and child supervisors to be supervised
      worker(Spell.User, [upa_agent]),
      worker(Spell.Room, [treehouse]),
      worker(Spell.Room, [dungeon]),
    ]

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
