defmodule Spell do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false


    children = [
      # Define workers and child supervisors to be supervised
      worker(Spell.Room, [:treehouse]),
      worker(Spell.User, [:upa_agent]),
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
