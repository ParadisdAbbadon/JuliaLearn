
module Types
export CharacterClass, Warrior, Warlock, Archer
export Enemy, Player
export Condition, ConditionConfig, CONDITION_CONFIGS

# Condition system for status effects
struct ConditionConfig
    name::String
    icon::String
    damage_percent::Float64  # % of max HP dealt per turn (0.0 if no damage)
    message::String          # Message when damage is dealt
end

mutable struct Condition
    type::Symbol
    turns::Int
end

# Define all condition types and their properties
const CONDITION_CONFIGS = Dict{Symbol, ConditionConfig}(
    :bleed => ConditionConfig("BLEEDING", "🩸", 0.10, "You take {damage} bleed damage!"),
    :burn => ConditionConfig("BURNING", "🔥", 0.08, "You take {damage} burn damage!"),
    :poison => ConditionConfig("POISONED", "☠️", 0.05, "You take {damage} poison damage!"),
    :freeze => ConditionConfig("FROZEN", "❄️", 0.0, "You are frozen and cannot act!"),
    :slow => ConditionConfig("SLOWED", "🐌", 0.0, "Your movements are slowed!")
)

abstract type CharacterClass end

struct Warrior <: CharacterClass
    name::String
    hp::Int
    max_hp::Int
    attack::Int
    defense::Int
    special_ability::String
end

struct Warlock <: CharacterClass
    name::String
    hp::Int
    max_hp::Int
    attack::Int
    defense::Int
    mana::Int
    max_mana::Int
    special_ability::String
end

struct Archer <: CharacterClass
    name::String
    hp::Int
    max_hp::Int
    attack::Int
    defense::Int
    agility::Int
    special_ability::String
end

mutable struct Enemy
    name::String
    hp::Int
    max_hp::Int
    attack::Int
    defense::Int
    xp_reward::Int
    is_miniboss::Bool
end

mutable struct Player
    character::CharacterClass
    level::Int
    xp::Int
    xp_to_next::Int
    gold::Int
    potions::Int
    mana_potions::Int
    weapon_tier::Int
    dungeon_one_unlocked::Bool
end
end
