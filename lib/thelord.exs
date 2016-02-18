import Client
import Spell

server_id = spawn_link(Spell, :init, [])
client_id = spawn_link(Client, :init, [:wolfram, server_id])

IO.puts("Starting things up")

defmodule Main do
    def io_loop(client_id) do
        text = IO.gets(":: ")
        if String.starts_with?(String.downcase(text), "exit") do
            IO.puts("Exiting")
            exit(0)
        end
        send client_id, {:user_command, text}
        io_loop(client_id)
    end
end

Main.io_loop(client_id)
