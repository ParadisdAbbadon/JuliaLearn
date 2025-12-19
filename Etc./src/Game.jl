module Game
import ..Types: Player
import ..Characters: create_character
import ..Display
import ..Enemies: generate_enemy
import ..Combat: combat
import ..Shop: shop
import ..Story: get_wake_story, get_dungeon_one_unlocked, print_story_slowly

export game_loop

function game_loop()
    println("═══════════════════════════════════")
    println("     /                    ")
    println("O===[====================-")
    println("     \\                    ")
    println("\n")
    println("~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~")
    println("----WELCOME TO DUNGEON RUNNER------")
    println("~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~")
    println("\n")
    println("     /                    ")
    println("O===[====================-")
    println("     \\                    ")

    println("═══════════════════════════════════\n")

    print("Enter your character name: ")
    char_name = readline()

    println("\n═══════════════════════════════════")
    println("         CHOOSE YOUR CLASS")
    println("═══════════════════════════════════")
    println()
    println("1. WARRIOR")
    println("   A stalwart fighter with high HP and defense.")
    println("   • Special: Power Strike (2x attack damage)")
    println("   • Unique: Can block attacks to reduce damage")
    println("   • Best for: Players who prefer a tanky playstyle")
    println()
    println("2. WARLOCK")
    println("   A dark mage wielding devastating magical power.")
    println("   • Special: Dark Bolt (2x attack, costs 15 mana)")
    println("   • Unique: Uses mana for spells, can buy mana potions")
    println("   • Best for: Players who want high burst damage")
    println()
    println("3. ARCHER")
    println("   A nimble ranger with deadly precision.")
    println("   • Special: Quick Shot (70% hit chance, bonus agility damage)")
    println("   • Unique: High agility increases special attack damage")
    println("   • Best for: Players who enjoy risk/reward gameplay")
    println()
    println("═══════════════════════════════════")
    print("Enter choice (1/2/3 or class name): ")

    class_names = ["Warrior", "Warlock", "Archer"]
    class_choice = 0
    confirmed = false

    while !confirmed
        # Get class selection
        while class_choice < 1 || class_choice > 3
            input = lowercase(strip(readline()))

            # Handle both number and name input
            if input == "1" || input == "warrior"
                class_choice = 1
            elseif input == "2" || input == "warlock"
                class_choice = 2
            elseif input == "3" || input == "archer"
                class_choice = 3
            else
                println("Invalid choice! Please enter 1, 2, 3 or the class name.")
                print("> ")
            end
        end

        # Confirm selection
        println("\nYou selected: $(class_names[class_choice])")
        print("Confirm? (yes/no): ")
        confirm_input = lowercase(strip(readline()))

        if confirm_input == "yes" || confirm_input == "y"
            confirmed = true
        else
            println("\nPlease choose again.")
            print("Enter choice (1/2/3 or class name): ")
            class_choice = 0
        end
    end

    character = create_character(class_choice, char_name)

    player = Player(character, 1, 0, 100, 0, 3, 0, 0, false)

    println("\n⚔️  Your adventure begins, $(char_name)!\n")

    # Display the story character by character
    story = get_wake_story(char_name)
    print_story_slowly(story)

    println("\nPress Enter to continue...")
    readline()

    while player.character.hp > 0
        Display.clear_screen()
        Display.display_stats(player)
        println("Actions: explore | stats | shop | quit")
        print("> ")
        action = lowercase(strip(readline()))

        if action == "explore"
            enemy = generate_enemy(player.level)
            player, won = combat(player, enemy)

            # Check for tier 1 mini-boss defeat to trigger dungeon story
            if won && !player.dungeon_one_unlocked &&
               player.level >= 7 && player.level <= 10 &&
               enemy.is_miniboss
                player.dungeon_one_unlocked = true
                println()
                print_story_slowly(get_dungeon_one_unlocked(enemy.name))
                println("\nPress Enter to continue...")
                readline()
            end

            if player.character.hp <= 0
                Display.clear_screen()
                println("\n═══════════════════════════════════")
                println("         GAME OVER")
                println("    Final Level: $(player.level)")
                println("═══════════════════════════════════")
                break
            end

        elseif action == "stats"
            Display.clear_screen()
            Display.display_stats(player)

        elseif action == "shop"
            Display.clear_screen()
            shop(player)

        elseif action == "quit"
            Display.clear_screen()
            println("\nThanks for playing!")
            break
        elseif startswith(action, "debug ") #-- debug command
            level_str = action[7:end]
            new_level = tryparse(Int, level_str)
            if new_level !== nothing && new_level >= 1
                player.level = new_level
                println("🔧 Debug: Level set to $new_level")
            else
                println("🔧 Debug: Invalid level")
            end
        else
            println("Invalid action!")
        end
    end
end
end