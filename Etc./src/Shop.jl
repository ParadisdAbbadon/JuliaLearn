module Shop

import ..Types: Player, CharacterClass, Warrior, Warlock, Archer
import ..Characters: update_attack

export shop, get_weapon_info

function get_weapon_info(char::CharacterClass, tier::Int)
    if isa(char, Warrior)
        weapons = ["Iron Sword", "Steel Greatsword", "Dragonbone Blade", "Excalibur"]
        costs = [100, 250, 500, 1000]
    elseif isa(char, Warlock)
        weapons = ["Oak Staff", "Obsidian Rod", "Staff of the Archmage", "Void Scepter"]
        costs = [100, 250, 500, 1000]
    elseif isa(char, Archer)
        weapons = ["Longbow", "Composite Bow", "Elven Bow", "Shadowstrike"]
        costs = [100, 250, 500, 1000]
    end

    if tier >= 1 && tier <= 4
        return weapons[tier], costs[tier]
    else
        return nothing, 0
    end
end

function shop(player::Player)
    println("\n🏪 ═══════════════ SHOP ═══════════════")
    println("Your Gold: $(player.gold)")
    println("\n1. Health Potion - 20 Gold (Restores 50 HP)")

    # Calculate available weapon tier based on level
    available_tier = div(player.level - 1, 5) + 1

    # Show weapon upgrade if player qualifies and hasn't bought it yet
    if player.level >= 5 && player.weapon_tier < available_tier
        weapon_name, weapon_cost = get_weapon_info(player.character, player.weapon_tier + 1)
        if weapon_name !== nothing
            println("2. $weapon_name - $weapon_cost Gold (+5 Attack)")
            println("   ⭐ Unlocked at level $(5 * player.weapon_tier + 5)!")
        end
        println("3. Leave")
    else
        println("2. Leave")
    end

    print("> ")
    shop_choice = readline()

    if shop_choice == "1"
        if player.gold >= 20
            player.gold -= 20
            player.potions += 1
            println("✅ Purchased Health Potion!")
        else
            println("❌ Not enough gold!")
        end
    elseif shop_choice == "2"
        # Check if option 2 is a weapon or leave
        if player.level >= 5 && player.weapon_tier < available_tier
            wpn_name, wpn_cost = get_weapon_info(player.character, player.weapon_tier + 1)
            if wpn_name !== nothing && player.gold >= wpn_cost
                player.gold -= wpn_cost
                player.weapon_tier += 1
                new_attack = player.character.attack + 5
                player.character = update_attack(player.character, new_attack)
                println("✅ Purchased $wpn_name! Attack increased to $(new_attack)!")
            elseif wpn_name !== nothing
                println("❌ Not enough gold!")
            end
        end
    elseif shop_choice == "3" && player.level >= 5 && player.weapon_tier < available_tier
        # Leave shop (only option 3 if weapon is available)
        return
    end
end
end

