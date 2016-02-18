defmodule Client do
  def connect(username, server) do
    spawn(Client, :init, [username, server])
  end

  def init(username, server) do
    pid = self()
    send server, {pid, :connect, username}
    loop(username, server)
  end


  def loop(username, server) do
    receive do
      {:info, msg} ->
        IO.puts(~s{[#{username}'s client] - #{msg}})
        loop(username, server)
      {:new_msg, from, msg} ->
        IO.puts(~s{[#{username}'s client] - #{from}: #{msg}})
        loop(username, server)
      {:send, msg} ->
        send server, {self, :broadcast, msg}
        loop(username, server)
      {:user_command, command_name} ->
        IO.puts("Got a command from the user: " <> command_name)
        loop(username, server)
      :disconnect ->
        IO.puts("Disconnecting")
        exit(0)
    end
  end
end
