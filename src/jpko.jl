module jpko

    using Sockets
    using Dates

    function write_pko(buf, str::String)
        write(buf, hton(UInt16(length(str))))
        write(buf, str)
    end

    abstract type Packet end

    function build_final(packet::Packet)
        if packet === nothing
            return UInt8[]
        end
        
        buf = build(packet)

        println("test")
        
        new_buf = IOBuffer()
        write(new_buf, hton(UInt16(buf.size + 6)))
        write(new_buf, hton(UInt32(2147483648)))
        write(new_buf, take!(buf))

        return take!(new_buf)
    end

    struct FirstDate <: Packet
        opcode::UInt16
        date::String
    end

    function get_current_time()
        time_now = now()
        return string("[", Dates.format(time_now, "mm-dd HH:MM:SS.sss"), "]")
    end

    FirstDate() = FirstDate(940, get_current_time())

    function build(packet::FirstDate)
        new_buf = IOBuffer()
        write(new_buf, hton(packet.opcode))
        write_pko(new_buf, packet.date)

        return new_buf
    end

    using Serialization

    struct Auth
        key_len::UInt16
        key::Vector{UInt8}
        login::String
        password_len::UInt16
        password::Vector{UInt8}
        mac::String
        is_cheat::UInt16
        client_version::UInt16
    end
    
    struct AuthError
        error_code::UInt16
    end
    
    struct InstAttr
        id::UInt16
        value::UInt16
    end
    
    struct ItemAttr
        attr::UInt16
        is_init::Bool
    end
    
    struct ItemGrid
        id::UInt16
        num::UInt16
        endure::NTuple{2, UInt16}
        energy::NTuple{2, UInt16}
        forge_lv::UInt8
        db_params::NTuple{2, UInt32}
        inst_attrs::NTuple{5, InstAttr}
        item_attrs::NTuple{40, ItemAttr}
        is_change::Bool
    end
    
    struct Look
        ver::UInt16
        type_id::UInt16
        item_grids::NTuple{10, ItemGrid}
        hair::UInt16
    end
    
    struct Character
        is_active::Bool
        name::String
        job::String
        map::String
        level::UInt16
        look_size::UInt16
        look::Look
    end
    
    struct CharactersChoice <: Packet
        opcode::UInt16
        error_code::UInt16
        key_len::UInt16
        key::Vector{UInt8}
        character_len::UInt8
        characters::Vector{Character}
        pincode::UInt8
        encryption::UInt32
        dw_flag::UInt32
    end

    CharactersChoice() = CharactersChoice(
        931, 0, 8, Vector{UInt8}([0x7C, 0x35, 0x09, 0x19, 0xB2, 0x50, 0xD3, 0x49]),
        0, Vector{Character}(), 1, 0, 12820
    )

    function build(packet::CharactersChoice)
        new_buf = IOBuffer()
        write(new_buf, hton(packet.opcode))
        write(new_buf, hton(packet.error_code))
        write(new_buf, hton(packet.key_len))
        write(new_buf, packet.key)
        write(new_buf, hton(packet.character_len))
        write(new_buf, hton(packet.pincode))
        write(new_buf, hton(packet.encryption))
        write(new_buf, hton(packet.dw_flag))

        return new_buf
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

            println("accepted new client")
            @async handle_client(client)
        end
    end

    tcp_server()
end

