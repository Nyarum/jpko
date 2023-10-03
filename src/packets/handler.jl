module Handler

export build_final

using Match
using ..Packets

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
    buf = build_universal(packet)
    
    new_buf = IOBuffer()
    write(new_buf, hton(UInt16(buf.size + 6)))
    write(new_buf, hton(UInt32(2147483648)))
    write(new_buf, take!(buf))

    return take!(new_buf)
end

end