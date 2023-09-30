module jpko

    using Sockets
    using Dates
    using Parameters

    function write_pko(buf, str::String)
        write(buf, hton(UInt16(length(str))))
        write(buf, str)
    end

    abstract type Packet end

    using Match

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

    function get_current_time()
        time_now = now()
        return string("[", Dates.format(time_now, "mm-dd HH:MM:SS.sss"), "]")
    end

    @with_kw struct FirstDate <: Packet
        opcode::UInt16 = 940
        date::String = get_current_time()
    end

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
    
    @with_kw struct CharactersChoice <: Packet
        opcode::UInt16 = 931
        error_code::UInt16 = 0
        key_len::UInt16 = 8
        key::Vector{UInt8} = [0x7C, 0x35, 0x09, 0x19, 0xB2, 0x50, 0xD3, 0x49]
        character_len::UInt8 = 0
        characters::Vector{Character} = []
        pincode::UInt8 = 1
        encryption::UInt32 = 0
        dw_flag::UInt32 = 12820
    end

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

