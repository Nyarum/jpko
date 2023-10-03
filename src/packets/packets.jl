module Packets

export Packet

abstract type Packet end

include("handler.jl")

using .Handler

include("auth.jl")

using .Auths

end