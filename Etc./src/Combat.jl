module Combat
    # Import from parent modules - NO include() here!
    import ..Types: Player, Enemy, Warrior, Warlock, Archer
    import ..Characters: update_hp, update_mana, level_up_character
    import ..Display: display_enemy, display_combat_status
    
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
        return enemy
    end

    function player_special(player::Player, enemy::Enemy)
        char = player.character

        if isa(char, Warrior)
            damage = calculate_damage(char.attack * 2, enemy.defense)
            enemy.hp -= damage
            println("\n💥 $(char.special_ability)! You deal $damage damage!")
            return player, enemy

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
            return player, enemy

        elseif isa(char, Archer)
            if rand() < 0.7  # 70% hit chance
                damage = calculate_damage(char.attack + char.agility, enemy.defense)
                enemy.hp -= damage
                println("\n🏹 $(char.special_ability)! Critical hit for $damage damage!")
            else
                println("\n🏹 $(char.special_ability) missed!")
            end
            return player, enemy
        end
    end

    function enemy_attack(player::Player, enemy::Enemy)
        char = player.character
        damage = calculate_damage(enemy.attack, char.defense)
        new_hp = max(0, char.hp - damage)
        player.character = update_hp(char, new_hp)
        println("👹 $(enemy.name) attacks for $damage damage!")
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
        display_enemy(enemy)

        while player.character.hp > 0 && enemy.hp > 0
            display_combat_status(player, enemy)
            println("Actions: attack | special | potion | examine | run")
            print("> ")
            action = lowercase(strip(readline()))

            if action == "attack"
                enemy = player_attack(player, enemy)
            elseif action == "special"
                player, enemy = player_special(player, enemy)
            elseif action == "potion"
                player = use_potion(player)
            elseif action == "examine"
                println("\n🔍 $(enemy.name)")
                println("   HP: $(enemy.hp)/$(enemy.max_hp)")
                println("   Attack: $(enemy.attack)")
                println("   Defense: $(enemy.defense)")
                continue
            elseif action == "run"
                if rand() < 0.5
                    println("\n🏃 You escaped!")
                    return player, false
                else
                    println("\n❌ Can't escape!")
                end
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

            if player.character.hp <= 0
                println("\n💀 You have been defeated...")
                return player, false
            end
        end

        return player, false
    end
end
