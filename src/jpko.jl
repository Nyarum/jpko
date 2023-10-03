module jpko
    include("packets/packets.jl")

    using .Packets.Auths
    using .Packets.Handler
    using Sockets
  
    function handle_client(client::IO)
        try
            while true
                write(client, build_final(FirstDate()))

                data = readavailable(client)

                if length(data) > 2
                    write(client, build_final(CharactersChoice()))
                elseif length(data) == 2
                    write(client, 0x00, 0x02)
                end

                println("Received: ", data)
            end
        catch e
            println("Client disconnected.", e)
        finally
            close(client)
        end
    end

    function tcp_server()
        server = listen(IPv4(0), 1973)
        println("Listening on port 1973...")
    
        while true
            client = accept(server)
    
            println("Accepted new client")
            @async handle_client(client)
        end
    end

    tcp_server()
end

