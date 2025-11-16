module Game

import ..Types: Player
import ..Characters: create_character
import ..Display: display_stats
import ..Enemies: generate_enemy
import ..Combat: combat
import ..Shop: shop

export game_loop

function game_loop()
    println("═══════════════════════════════════")
    println("    WELCOME TO THE DUNGEON RPG")
    println("═══════════════════════════════════\n")

    print("Enter your character name: ")
    char_name = readline()

    println("\nChoose your class:")
    println("1. Warrior - High HP and Defense")
    println("2. Warlock - Powerful magic attacks")
    println("3. Archer - Quick and agile")
    print("> ")

    class_choice = 0
    while class_choice < 1 || class_choice > 3
        input = lowercase(strip(readline()))


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

    character = create_character(class_choice, char_name)

    player = Player(character, 1, 0, 100, 0, 3, 0)

    println("\n⚔️  Your adventure begins, $(char_name)!")

    while player.character.hp > 0
        display_stats(player)
        println("Actions: explore | stats | shop | quit")
        print("> ")
        action = lowercase(strip(readline()))

        if action == "explore"
            enemy = generate_enemy(player.level)
            player, won = combat(player, enemy)

            if player.character.hp <= 0
                println("\n═══════════════════════════════════")
                println("         GAME OVER")
                println("    Final Level: $(player.level)")
                println("═══════════════════════════════════")
                break
            end

        elseif action == "stats"
            display_stats(player)

        elseif action == "shop"
            shop(player)

        elseif action == "quit"
            println("\nThanks for playing!")
            break
        else
            println("Invalid action!")
        end
    end
end
end