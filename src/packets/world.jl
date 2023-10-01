module WorldPackets

using Parameters

@with_kw mutable struct InstAttr
    # Определите поля для этой структуры
end

@with_kw mutable struct Attribute
    id::UInt8 = 0
    value::UInt32 = 0
end

@with_kw mutable struct Shortcut
    type::UInt8 = 0
    grid_id::UInt16 = 0
end

@with_kw mutable struct KitbagItem
    grid_id::UInt16 = 0
    id::UInt16 = 0
    num::UInt16 = 0
    endure::Vector{UInt16} = []
    energy::Vector{UInt16} = []
    forge_level::UInt8 = 0
    is_valid::Bool = false
    item_db_inst_id::UInt32 = 0
    item_db_forge::UInt32 = 0
    is_params::Bool = false
    inst_attrs::Vector{InstAttr} = []
end

@with_kw mutable struct CharacterShortcut
    shortcuts::Vector{Shortcut} = []
end

@with_kw mutable struct CharacterKitbag
    type::UInt8 = 0
    keybag_num::UInt16 = 0
    items::Vector{KitbagItem} = []
end

@with_kw mutable struct CharacterAttribute
    type::UInt8 = 0
    num::UInt16 = 0
    attributes::Vector{Attribute} = []
end

@with_kw mutable struct SkillState
    id::UInt8 = 0
    level::UInt8 = 0
end

@with_kw mutable struct CharacterSkillState
    states_len::UInt8 = 0
    states::Vector{SkillState} = []
end

@with_kw mutable struct Position
    x::UInt32 = 0
    y::UInt32 = 0
    radius::UInt32 = 0
end

@with_kw mutable struct CharacterSide
    side_id::UInt8 = 0
end

@with_kw mutable struct EntityEvent
    entity_id::UInt32 = 0
    entity_type::UInt8 = 0
    event_id::UInt16 = 0
    event_name::String = ""
end

@with_kw mutable struct CharacterPK
    pk_ctrl::UInt8 = 0
end

@with_kw mutable struct CharacterAppendLook
    look_id::UInt16 = 0
    is_valid::UInt8 = 0
end

@with_kw mutable struct CharacterLookBoat
    pos_id::UInt16 = 0
    boat_id::UInt16 = 0
    header::UInt16 = 0
    body::UInt16 = 0
    engine::UInt16 = 0
    cannon::UInt16 = 0
    equipment::UInt16 = 0
end

@with_kw mutable struct CharacterLookItemSync
    endure::UInt16 = 0
    energy::UInt16 = 0
    is_valid::UInt8 = 0
end

@with_kw mutable struct CharacterLookItemShow
    num::UInt16 = 0
    endure::Vector{UInt16} = [0, 0]
    energy::Vector{UInt16} = [0, 0]
    forge_level::UInt8 = 0
    is_valid::UInt8 = 0
end

@with_kw mutable struct CharacterLookItem
    id::UInt16 = 0
    item_sync::CharacterLookItemSync = CharacterLookItemSync()
    item_show::CharacterLookItemShow = CharacterLookItemShow()
    is_db_params::UInt8 = 0
    db_params::Vector{UInt32} = [0, 0]
    is_inst_attrs::UInt8 = 0
    inst_attrs::Vector{InstAttr} = [InstAttr() for _ in 1:5]  # Предполагается, что вы определили структуру InstAttr
end


@with_kw mutable struct CharacterLookHuman
    hair_id::UInt16 = 0
    item_grid::Vector{CharacterLookItem} = []
end

@with_kw mutable struct CharacterLook
    syn_type::UInt8 = 0
    type_id::UInt16 = 0
    is_boat::UInt8 = 0
    look_boat::CharacterLookBoat = CharacterLookBoat()
    look_human::CharacterLookHuman = CharacterLookHuman()
end

function guard(cl::CharacterLook)
    if cl.is_boat == 1
        return cl.look_boat
    else
        return cl.look_human
end

@with_kw mutable struct CharacterBase
    cha_id::UInt32 = 0
    world_id::UInt32 = 0
    comm_id::UInt32 = 0
    comm_name::String = ""
    gm_lvl::UInt8 = 0
    handle::UInt32 = 0
    ctrl_type::UInt8 = 0
    name::String = ""
    motto_name::String = ""
    icon::UInt16 = 0
    guild_id::UInt32 = 0
    guild_name::String = ""
    guild_motto::String = ""
    stall_name::String = ""
    state::UInt16 = 0
    position::Position
    angle::UInt16 = 0
    team_leader_id::UInt32 = 0
    side::CharacterSide
    entity_event::EntityEvent
    look::CharacterLook
    pk_ctrl::CharacterPK
    look_append::Vector{CharacterAppendLook} = []
end

@with_kw mutable struct CharacterBoat
    character_base::CharacterBase = CharacterBase()
    character_attribute::CharacterAttribute = CharacterAttribute()
    character_kitbag::CharacterKitbag = CharacterKitbag()
    character_skill_state::CharacterSkillState = CharacterSkillState()
end

@with_kw mutable struct EnterGame
    opcode::UInt16 = 516
    enter_ret::UInt16 = 0
    auto_lock::UInt8 = 0
    kitbag_lock::UInt8 = 0
    enter_type::UInt8 = 0
    is_new_char::UInt8 = 0
    map_name::String = ""
    can_team::UInt8 = 0
    character_base::CharacterBase = CharacterBase()
    character_skill_bag::CharacterSkillBag = CharacterSkillBag()
    character_skill_state::CharacterSkillState = CharacterSkillState()
    character_attribute::CharacterAttribute = CharacterAttribute()
    character_kitbag::CharacterKitbag = CharacterKitbag()
    character_shortcut::CharacterShortcut = CharacterShortcut()
    boat_len::UInt8 = 0
    character_boats::Vector{CharacterBoat} = []
    cha_main_id::UInt32 = 0
end


end