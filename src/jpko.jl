module jpko
    include("packets/auth.jl")
    include("packets/packets.jl")

    using .AuthPackets
    using .Packets

    using Sockets
    using Match

    function write_pko(buf, str::String)
        write(buf, hton(UInt16(length(str))))
        write(buf, str)
    end

    function build_universal(struct_type)
        new_buf = IOBuffer()

        for v in fieldnames(typeof(struct_type))
            field = getfield(struct_type, v)

            @match field begin
                ::Vector{UInt8} =>  write(new_buf, field)
                ::Vector        => for st in field build_universal(st) end
                ::String        => write_pko(new_buf, field)
                _               => write(new_buf, hton(field))
            end
        end

        new_buf
    end

    function build_final(packet::Packet)
        if packet === nothing
            return UInt8[]
        end
        
        buf = build_universal(packet)
        
        new_buf = IOBuffer()
        write(new_buf, hton(UInt16(buf.size + 6)))
        write(new_buf, hton(UInt32(2147483648)))
        write(new_buf, take!(buf))

        return take!(new_buf)
    end
  
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
            Threads.@spawn handle_client(client)
        end
    end

    tcp_server()
end

