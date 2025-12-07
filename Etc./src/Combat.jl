module Combat
import ..Types: Player, Enemy, Warrior, Warlock, Archer
import ..Characters: update_hp, update_mana, level_up_character
import ..Display

export combat, calculate_damage, player_attack, player_special
export enemy_attack, use_potion

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

function calculate_condition_damage(player::Player, condition_type::String)
    if condition_type == "bleed"
        return round(Int, player.character.max_hp * 0.10)
    end
    return 0
end

function deal_condition_damage(player::Player, condition_type::String)
    damage = calculate_condition_damage(player, condition_type)
    if damage > 0
        new_hp = max(0, player.character.hp - damage)
        player.character = update_hp(player.character, new_hp)
        println("🩸 You take $damage bleed damage!")
    end
    return player
end

function use_potion(player::Player)
    if player.potions > 0
        char = player.character
        heal_amount = min(50, char.max_hp - char.hp)
        new_hp = min(char.max_hp, char.hp + 50)
        player.character = update_hp(char, new_hp)
        player.potions -= 1
        println("\n🧪 You drink a potion and restore $heal_amount HP!")
    else
        println("\n❌ You don't have any potions!")
    end
    return player
end

function combat(player::Player, enemy::Enemy)
    Display.clear_screen()
    Display.display_enemy(enemy)

    player_damage = 0
    bleed_turns = 0

    while player.character.hp > 0 && enemy.hp > 0
        # Apply bleed damage at start of turn
        if bleed_turns > 0
            player = deal_condition_damage(player, "bleed")
            bleed_turns -= 1
            if bleed_turns == 0
                println("   The bleeding has stopped.")
            end
            if player.character.hp <= 0
                println("\n💀 You have bled out...")
                return player, false
            end
        end

        Display.display_combat_status(player, enemy)
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
            player = use_potion(player)
            player_damage = 0
        elseif action == "examine"
            println("\n🔍 $(enemy.name)")
            println("   HP: $(enemy.hp)/$(enemy.max_hp)")
            println("   Attack: $(enemy.attack)")
            println("   Defense: $(enemy.defense)")
            if enemy.name == "Goblin King"
                println("   Special: Vengeful Strike - deals half the damage you inflict back to you")
            elseif enemy.name == "Orc Chieftain"
                println("   Special: Serrated Blade - inflicts bleed for 3 turns (10% max HP per turn)")
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
        if enemy.name == "Goblin King" && player_damage > 0
            vengeful_damage = round(Int, player_damage / 2)
            new_hp = max(0, player.character.hp - vengeful_damage)
            player.character = update_hp(player.character, new_hp)
            println("👑 Goblin King uses Vengeful Strike for $vengeful_damage damage!")
        elseif enemy.name == "Orc Chieftain" && bleed_turns == 0
            bleed_turns = 3
            println("🩸 Orc Chieftain's Serrated Blade causes you to bleed!")
        end

        if player.character.hp <= 0
            println("\n💀 You have been defeated...")
            return player, false
        end
    end

    return player, false
end
end