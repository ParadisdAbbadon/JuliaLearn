module Combat
import ..Types: Player, Enemy, Warrior, Warlock, Archer
import ..Types: Condition, ConditionConfig, CONDITION_CONFIGS
import ..Characters: update_hp, update_mana, level_up_character
import ..Display

export combat, calculate_damage, player_attack, player_special
export enemy_attack, use_potion, use_mana_potion
export apply_condition, tick_conditions, has_condition, get_condition

function calculate_damage(attacker_atk::Int, defender_def::Int)
    base_damage = max(1, attacker_atk - defender_def)
    variance = rand(-2:2)
    return max(1, base_damage + variance)
end

function player_attack(player::Player, enemy::Enemy)
    damage = calculate_damage(player.character.attack, enemy.defense)
    enemy.hp -= damage
    println("\n⚔️  You attack for $damage damage!")
    return enemy, damage
end

function player_special(player::Player, enemy::Enemy)
    char = player.character
    damage = 0

    if isa(char, Warrior)
        damage = calculate_damage(char.attack * 2, enemy.defense)
        enemy.hp -= damage
        println("\n💥 $(char.special_ability)! You deal $damage damage!")

    elseif isa(char, Warlock)
        if char.mana >= 15
            damage = calculate_damage(char.attack * 2, enemy.defense)
            enemy.hp -= damage
            new_char = update_mana(char, char.mana - 15)
            player.character = new_char
            println("\n🔮 $(char.special_ability)! You deal $damage damage! (15 mana used)")
        else
            println("\n❌ Not enough mana!")
        end

    elseif isa(char, Archer)
        if rand() < 0.7  # 70% hit chance
            damage = calculate_damage(char.attack + char.agility, enemy.defense)
            enemy.hp -= damage
            println("\n🏹 $(char.special_ability)! Critical hit for $damage damage!")
        else
            println("\n🏹 $(char.special_ability) missed!")
        end
    end

    return player, enemy, damage
end

function enemy_attack(player::Player, enemy::Enemy)
    char = player.character
    damage = calculate_damage(enemy.attack, char.defense)
    new_hp = max(0, char.hp - damage)
    player.character = update_hp(char, new_hp)
    println("👹 $(enemy.name) attacks for $damage damage!")
    return player
end

# Condition management functions
function apply_condition(conditions::Vector{Condition}, condition_type::Symbol, turns::Int)
    # Check if condition already exists, refresh duration if so
    for cond in conditions
        if cond.type == condition_type
            cond.turns = max(cond.turns, turns)
            return conditions
        end
    end
    # Add new condition
    push!(conditions, Condition(condition_type, turns))
    return conditions
end

function has_condition(conditions::Vector{Condition}, condition_type::Symbol)
    return any(c -> c.type == condition_type, conditions)
end

function get_condition(conditions::Vector{Condition}, condition_type::Symbol)
    idx = findfirst(c -> c.type == condition_type, conditions)
    return idx !== nothing ? conditions[idx] : nothing
end

function tick_conditions(player::Player, conditions::Vector{Condition})
    expired = Symbol[]

    for cond in conditions
        config = CONDITION_CONFIGS[cond.type]

        # Apply damage if condition deals damage
        if config.damage_percent > 0
            damage = round(Int, player.character.max_hp * config.damage_percent)
            new_hp = max(0, player.character.hp - damage)
            player.character = update_hp(player.character, new_hp)
            message = replace(config.message, "{damage}" => string(damage))
            println("$(config.icon) $message")
        end

        # Decrement turns
        cond.turns -= 1
        if cond.turns <= 0
            push!(expired, cond.type)
        end
    end

    # Remove expired conditions
    for cond_type in expired
        config = CONDITION_CONFIGS[cond_type]
        filter!(c -> c.type != cond_type, conditions)
        println("   The $(lowercase(config.name)) has worn off.")
    end

    return player, conditions
end

function use_potion(player::Player)
    if player.potions > 0
        char = player.character
        heal_amount = min(50, char.max_hp - char.hp)
        new_hp = min(char.max_hp, char.hp + 50)
        player.character = update_hp(char, new_hp)
        player.potions -= 1
        println("\n🧪 You drink a health potion and restore $heal_amount HP!")
    else
        println("\n❌ You don't have any health potions!")
    end
    return player
end

function use_mana_potion(player::Player)
    char = player.character
    if !isa(char, Warlock)
        println("\n❌ Only Warlocks can use mana potions!")
        return player
    end
    if player.mana_potions > 0
        restore_amount = min(30, char.max_mana - char.mana)
        new_mana = min(char.max_mana, char.mana + 30)
        player.character = update_mana(char, new_mana)
        player.mana_potions -= 1
        println("\n🔮 You drink a mana potion and restore $restore_amount MP!")
    else
        println("\n❌ You don't have any mana potions!")
    end
    return player
end

function combat(player::Player, enemy::Enemy)
    Display.clear_screen()
    Display.display_enemy(enemy)

    player_damage = 0
    conditions = Condition[]

    while player.character.hp > 0 && enemy.hp > 0
        # Apply condition effects at start of turn
        if !isempty(conditions)
            player, conditions = tick_conditions(player, conditions)
            if player.character.hp <= 0
                println("\n💀 You have succumbed to your afflictions...")
                return player, false
            end
        end

        Display.display_combat_status(player, enemy; conditions=conditions)
        println("Actions: attack | special | potion | examine | run")
        print("> ")
        action = lowercase(strip(readline()))

        Display.clear_screen()
        Display.display_enemy(enemy)

        if action == "attack"
            enemy, player_damage = player_attack(player, enemy)
        elseif action == "special"
            player, enemy, player_damage = player_special(player, enemy)
        elseif action == "potion"
            print("  Potion type (health")
            if isa(player.character, Warlock)
                print(" | mana")
            end
            println(" | back):")
            print("  > ")
            potion_choice = lowercase(strip(readline()))
            if potion_choice == "health"
                player = use_potion(player)
            elseif potion_choice == "mana" && isa(player.character, Warlock)
                player = use_mana_potion(player)
            elseif potion_choice != "back"
                println("\n❌ Invalid potion choice!")
            end
            player_damage = 0
        elseif action == "examine"
            println("\n🔍 $(enemy.name)")
            println("   HP: $(enemy.hp)/$(enemy.max_hp)")
            println("   Attack: $(enemy.attack)")
            println("   Defense: $(enemy.defense)")
            if enemy.is_miniboss
                if enemy.name == "Goblin King"
                    println("   Special: Vengeful Strike - deals half the damage you inflict back to you")
                elseif enemy.name == "Orc Chieftain"
                    println("   Special: Serrated Blade - inflicts bleed for 3 turns (10% max HP per turn)")
                end
            end
            continue
        elseif action == "run"
            if rand() < 0.5
                println("\n🏃 You escaped!")
                return player, false
            else
                println("\n❌ Can't escape!")
            end
            player_damage = 0
        else
            println("Invalid action!")
            continue
        end

        if enemy.hp <= 0
            println("\n🎉 Victory! $(enemy.name) defeated!")
            player.xp += enemy.xp_reward
            gold_reward = rand(5:15)
            player.gold += gold_reward
            println("   +$(enemy.xp_reward) XP")
            println("   +$gold_reward Gold")

            # Level up check
            if player.xp >= player.xp_to_next
                player.level += 1
                player.xp -= player.xp_to_next
                player.xp_to_next = round(Int, player.xp_to_next * 1.5)
                player.character = level_up_character(player.character)
                println("\n⭐ LEVEL UP! You are now level $(player.level)!")
                println("   Stats increased!")
            end

            return player, true
        end

        # Enemy turn
        player = enemy_attack(player, enemy)

        # Mini-boss special attacks
        if enemy.is_miniboss
            if enemy.name == "Goblin King" && player_damage > 0
                vengeful_damage = round(Int, player_damage / 2)
                new_hp = max(0, player.character.hp - vengeful_damage)
                player.character = update_hp(player.character, new_hp)
                println("👑 Goblin King uses Vengeful Strike for $vengeful_damage damage!")
            elseif enemy.name == "Orc Chieftain" && !has_condition(conditions, :bleed)
                conditions = apply_condition(conditions, :bleed, 3)
                println("🩸 Orc Chieftain's Serrated Blade causes you to bleed!")
            end
        end

        if player.character.hp <= 0
            println("\n💀 You have been defeated...")
            return player, false
        end
    end

    return player, false
end
end