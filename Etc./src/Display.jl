module Display
import ..Types: Player, Enemy, Warlock, Archer

export display_stats, display_enemy, display_combat_status, clear_screen, progress_bar

function clear_screen()
    if Sys.iswindows()
        run(`cmd /c cls`)
    else
        run(`clear`)
    end
end

function progress_bar(current::Int, max::Int; width::Int=10, filled::Char='█', empty::Char='░')
    ratio = clamp(current / max, 0.0, 1.0)
    filled_count = round(Int, ratio * width)
    empty_count = width - filled_count
    return "[" * repeat(filled, filled_count) * repeat(empty, empty_count) * "]"
end

function display_stats(player::Player)
    char = player.character
    println("\n═══════════════════════════════════")
    println("  $(char.name) - Level $(player.level)")
    println("═══════════════════════════════════")
    println("  HP:  $(progress_bar(char.hp, char.max_hp)) $(char.hp)/$(char.max_hp)")

    if isa(char, Warlock)
        println("  MP:  $(progress_bar(char.mana, char.max_mana)) $(char.mana)/$(char.max_mana)")
    elseif isa(char, Archer)
        println("  Agility: $(char.agility)")
    end

    println("  Attack: $(char.attack)")
    println("  Defense: $(char.defense)")
    println("  XP:  $(progress_bar(player.xp, player.xp_to_next)) $(player.xp)/$(player.xp_to_next)")
    println("  Gold: $(player.gold)")
    println("  Potions: $(player.potions)")
    println("═══════════════════════════════════\n")
end

function display_enemy(enemy::Enemy)
    println("\n⚔️  $(enemy.name) appears!")
    println("   HP: $(enemy.hp)/$(enemy.max_hp)")
end

function display_combat_status(player::Player, enemy::Enemy; bleed_turns::Int=0)
    char = player.character
    println("\n═══════════════════════════════════")
    print("\n  You: $(progress_bar(char.hp, char.max_hp)) $(char.hp)/$(char.max_hp) HP")
    if isa(char, Warlock)
        print("  $(progress_bar(char.mana, char.max_mana)) $(char.mana)/$(char.max_mana) MP")
    end
    println()


    println("  $(enemy.name): $(progress_bar(enemy.hp, enemy.max_hp)) $(enemy.hp)/$(enemy.max_hp) HP")
    println("\n═══════════════════════════════════")
    println(" ")

    if bleed_turns > 0
        println("  ⚠️  Status: [BLEEDING - $bleed_turns turn(s)]")
        println(" ")
    end
end
end