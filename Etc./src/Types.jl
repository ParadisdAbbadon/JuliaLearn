
module Types
    export CharacterClass, Warrior, Warlock, Archer
    export Enemy, Player

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
    end

    mutable struct Player
        character::CharacterClass
        level::Int
        xp::Int
        xp_to_next::Int
        gold::Int
        potions::Int
        weapon_tier::Int
    end
end
