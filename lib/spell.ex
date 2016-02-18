defmodule Spell do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    pid = spawn(Spell, :init, [])
    {:ok, pid}
  end

  def init do
    import Supervisor.Spec, warn: false
    Process.flag(:trap_exit, true)
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

    # TODO: room called Jeffrey

    users = [upa_agent]
    rooms = [treehouse, dungeon]
    user_children = Enum.map(users, fn u -> worker(Spell.User, [u], [id: u.user_id]) end)
    room_children = Enum.map(rooms, fn r -> worker(Spell.Room, [r], [id: r.room_id]) end)
    children = Enum.concat([user_children, room_children])

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spell.Supervisor]
    result = Supervisor.start_link(children, opts)
    loop([])
  end

  def loop(clients) do
    receive do
      {sender, :connect, username} ->
        Process.link(sender)
        IO.puts(Atom.to_string(username) <> " joined!")
        broadcast({:info, Atom.to_string(username) <> " joined the chat"}, clients)
        loop([{username, sender} | clients])
      {sender, :broadcast, msg} ->
        broadcast({:new_msg, find(sender, clients), msg}, clients)
        loop(clients)
      {:EXIT, pid, _} ->
        broadcast({:info, Atom.to_string(find(pid, clients)) <> " left the chat."}, clients)
        IO.puts("caught an exit")
        loop(clients |> Enum.filter(fn {_, rec} -> rec != pid end))
      _ -> raise "Unexpected message in Spell receive loop"
    end
    #IO.puts ("User has: " <> to_string(Spell.User.get_state(:upa_agent)))
    #action = IO.gets "Whatcha gonna do about it? >"
    #Spell.User.set_state(:upa_agent, action)
    #IO.puts ("User NOW has: " <> to_string(Spell.User.get_state(:upa_agent)))
    #result
  end

  defp broadcast(msg, clients) do
    Enum.each clients, fn {_, receiver_pid} -> send(receiver_pid, msg) end
  end

  defp find(sender, [{u, p} | _]) when p == sender, do: u
  defp find(sender, [_ | t]), do: find(sender, t)
end
