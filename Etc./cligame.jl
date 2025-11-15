using Printf

# Character classes
abstract type CharacterClass end

struct Warrior <: CharacterClass
    name::String
    hp::Int
    max_hp::Int
    attack::Int
    defense::Int
    special_ability::String
end

struct Warlock <: CharacterClass
    name::String
    hp::Int
    max_hp::Int
    attack::Int
    defense::Int
    mana::Int
    max_mana::Int
    special_ability::String
end

struct Archer <: CharacterClass
    name::String
    hp::Int
    max_hp::Int
    attack::Int
    defense::Int
    agility::Int
    special_ability::String
end

# Enemy types
mutable struct Enemy
    name::String
    hp::Int
    max_hp::Int
    attack::Int
    defense::Int
    xp_reward::Int
end

# Mutable player wrapper
mutable struct Player
    character::CharacterClass
    level::Int
    xp::Int
    xp_to_next::Int
    gold::Int
    potions::Int
end

# Create character based on class choice
function create_character(class_choice::Int, name::String)
    if class_choice == 1
        return Warrior(name, 120, 120, 18, 12, "Power Strike")
    elseif class_choice == 2
        return Warlock(name, 80, 80, 22, 6, 50, 50, "Dark Bolt")
    elseif class_choice == 3
        return Archer(name, 100, 100, 20, 8, 15, "Quick Shot")
    end
end

# Update character stats (returns new character instance)
function update_hp(char::Warrior, new_hp::Int)
    return Warrior(char.name, new_hp, char.max_hp, char.attack, char.defense, char.special_ability)
end

function update_hp(char::Warlock, new_hp::Int)
    return Warlock(char.name, new_hp, char.max_hp, char.attack, char.defense, char.mana, char.max_mana, char.special_ability)
end

function update_hp(char::Archer, new_hp::Int)
    return Archer(char.name, new_hp, char.max_hp, char.attack, char.defense, char.agility, char.special_ability)
end

function update_mana(char::Warlock, new_mana::Int)
    return Warlock(char.name, char.hp, char.max_hp, char.attack, char.defense, new_mana, char.max_mana, char.special_ability)
end

# Level up character
function level_up_character(char::Warrior)
    return Warrior(char.name, char.max_hp + 20, char.max_hp + 20, char.attack + 3, char.defense + 2, char.special_ability)
end

function level_up_character(char::Warlock)
    return Warlock(char.name, char.max_hp + 15, char.max_hp + 15, char.attack + 4, char.defense + 1, char.max_mana + 10, char.max_mana + 10, char.special_ability)
end

function level_up_character(char::Archer)
    return Archer(char.name, char.max_hp + 18, char.max_hp + 18, char.attack + 3, char.defense + 2, char.agility + 2, char.special_ability)
end

# Display functions
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

# Generate random enemy
function generate_enemy(player_level::Int)
    enemies = [
        ("Goblin", 40, 8, 3, 15),
        ("Skeleton", 50, 10, 5, 20),
        ("Orc", 70, 12, 6, 30),
        ("Dark Mage", 60, 15, 4, 35),
        ("Troll", 90, 14, 8, 45)
    ]

    name, base_hp, base_atk, base_def, base_xp = rand(enemies)
    level_mult = 1 + (player_level - 1) * 0.3

    return Enemy(
        name,
        round(Int, base_hp * level_mult),
        round(Int, base_hp * level_mult),
        round(Int, base_atk * level_mult),
        round(Int, base_def * level_mult),
        round(Int, base_xp * level_mult)
    )
end

# Combat functions
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

# Combat loop
function combat(player::Player, enemy::Enemy)
    display_enemy(enemy)

    while player.character.hp > 0 && enemy.hp > 0
        println("\n[HP: $(player.character.hp)/$(player.character.max_hp)] | [Enemy HP: $(enemy.hp)/$(enemy.max_hp)]")
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

# Main game loop
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

    class_choice = parse(Int, readline())
    character = create_character(class_choice, char_name)

    player = Player(character, 1, 0, 100, 0, 3)

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
            println("\n🏪 Shop")
            println("1. Health Potion - 20 Gold")
            println("2. Leave")
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
            end

        elseif action == "quit"
            println("\nThanks for playing!")
            break
        else
            println("Invalid action!")
        end
    end
end

# Start the game
game_loop()