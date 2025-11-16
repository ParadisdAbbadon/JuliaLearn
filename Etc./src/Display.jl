module Display

import ..Types: Player, Enemy, Warlock, Archer

export display_stats, display_enemy, display_combat_status

function display_stats(player::Player)
    char = player.character
    println("\n═══════════════════════════════════")
    println("  $(char.name) - Level $(player.level)")
    println("═══════════════════════════════════")
    println("  HP: $(char.hp)/$(char.max_hp)")

    if isa(char, Warlock)
        println("  Mana: $(char.mana)/$(char.max_mana)")
    elseif isa(char, Archer)
        println("  Agility: $(char.agility)")
    end

    println("  Attack: $(char.attack)")
    println("  Defense: $(char.defense)")
    println("  XP: $(player.xp)/$(player.xp_to_next)")
    println("  Gold: $(player.gold)")
    println("  Potions: $(player.potions)")
    println("═══════════════════════════════════\n")
end

function display_enemy(enemy::Enemy)
    println("\n⚔️  $(enemy.name) appears!")
    println("   HP: $(enemy.hp)/$(enemy.max_hp)")
end

function display_combat_status(player::Player, enemy::Enemy)
    println("\n[HP: $(player.character.hp)/$(player.character.max_hp)] | [Enemy HP: $(enemy.hp)/$(enemy.max_hp)]")
end
end
