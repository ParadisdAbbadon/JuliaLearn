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
    println("\nAvailable Items:")
    println("  health  - Health Potion (20 Gold) - Restores 50 HP")

    # Show mana potion for Warlocks
    if isa(player.character, Warlock)
        println("  mana    - Mana Potion (25 Gold) - Restores 30 MP")
    end

    # Calculate available weapon tier based on level
    available_tier = div(player.level - 1, 5) + 1

    # Show weapon upgrade if player qualifies and hasn't bought it yet
    if player.level >= 5 && player.weapon_tier < available_tier
        weapon_name, weapon_cost = get_weapon_info(player.character, player.weapon_tier + 1)
        if weapon_name !== nothing
            println("  weapon  - $weapon_name ($weapon_cost Gold) - +5 Attack")
            println("            ⭐ Unlocked at level $(5 * player.weapon_tier + 5)!")
        end
    end

    println("  back    - Return to town")

    print("> ")
    shop_choice = lowercase(strip(readline()))

    if shop_choice == "health"
        if player.gold >= 20
            player.gold -= 20
            player.potions += 1
            println("✅ Purchased Health Potion!")
        else
            println("❌ Not enough gold!")
        end
    elseif shop_choice == "mana" && isa(player.character, Warlock)
        if player.gold >= 25
            player.gold -= 25
            player.mana_potions += 1
            println("✅ Purchased Mana Potion!")
        else
            println("❌ Not enough gold!")
        end
    elseif shop_choice == "weapon"
        if player.level >= 5 && player.weapon_tier < available_tier
            wpn_name, wpn_cost = get_weapon_info(player.character, player.weapon_tier + 1)
            if wpn_name !== nothing && player.gold >= wpn_cost
                player.gold -= wpn_cost
                player.weapon_tier += 1
                new_attack = player.character.attack + 5
                player.character = update_attack(player.character, new_attack)
                println("✅ Purchased $(wpn_name)! Attack increased to $(new_attack)!")
            elseif wpn_name !== nothing
                println("❌ Not enough gold!")
            else
                println("❌ No weapon available!")
            end
        else
            println("❌ No weapon upgrade available at your level!")
        end
    elseif shop_choice == "back"
        return
    else
        println("❌ Invalid choice!")
    end
end
end

