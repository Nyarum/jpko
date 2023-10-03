module Auths

export FirstDate, CharactersChoice

using Dates
using Parameters
using ..Packets

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
    endure::NTuple{2,UInt16}
    energy::NTuple{2,UInt16}
    forge_lv::UInt8
    db_params::NTuple{2,UInt32}
    inst_attrs::NTuple{5,InstAttr}
    item_attrs::NTuple{40,ItemAttr}
    is_change::Bool
end

struct Look
    ver::UInt16
    type_id::UInt16
    item_grids::NTuple{10,ItemGrid}
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

end