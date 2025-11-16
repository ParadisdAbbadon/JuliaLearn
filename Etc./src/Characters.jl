module Characters

import ..Types: CharacterClass, Warrior, Warlock, Archer

export create_character, update_hp, update_mana, update_attack
export level_up_character

function create_character(class_choice::Int, name::String)
    if class_choice == 1
        return Warrior(name, 120, 120, 18, 12, "Power Strike")
    elseif class_choice == 2
        return Warlock(name, 80, 80, 22, 6, 50, 50, "Dark Bolt")
    elseif class_choice == 3
        return Archer(name, 100, 100, 20, 8, 15, "Quick Shot")
    end
end

# Update HP
function update_hp(char::Warrior, new_hp::Int)
    return Warrior(char.name, new_hp, char.max_hp, char.attack, char.defense, char.special_ability)
end

function update_hp(char::Warlock, new_hp::Int)
    return Warlock(char.name, new_hp, char.max_hp, char.attack, char.defense, char.mana, char.max_mana, char.special_ability)
end

function update_hp(char::Archer, new_hp::Int)
    return Archer(char.name, new_hp, char.max_hp, char.attack, char.defense, char.agility, char.special_ability)
end

# Update mana
function update_mana(char::Warlock, new_mana::Int)
    return Warlock(char.name, char.hp, char.max_hp, char.attack, char.defense, new_mana, char.max_mana, char.special_ability)
end

# Update attack
function update_attack(char::Warrior, new_attack::Int)
    return Warrior(char.name, char.hp, char.max_hp, new_attack, char.defense, char.special_ability)
end

function update_attack(char::Warlock, new_attack::Int)
    return Warlock(char.name, char.hp, char.max_hp, new_attack, char.defense, char.mana, char.max_mana, char.special_ability)
end

function update_attack(char::Archer, new_attack::Int)
    return Archer(char.name, char.hp, char.max_hp, new_attack, char.defense, char.agility, char.special_ability)
end

# Level up
function level_up_character(char::Warrior)
    return Warrior(char.name, char.max_hp + 20, char.max_hp + 20, char.attack + 3, char.defense + 2, char.special_ability)
end

function level_up_character(char::Warlock)
    return Warlock(char.name, char.max_hp + 15, char.max_hp + 15, char.attack + 4, char.defense + 1, char.max_mana + 10, char.max_mana + 10, char.special_ability)
end

function level_up_character(char::Archer)
    return Archer(char.name, char.max_hp + 18, char.max_hp + 18, char.attack + 3, char.defense + 2, char.agility + 2, char.special_ability)
end
end
