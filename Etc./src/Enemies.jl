module Enemies

import ..Types: Enemy

export generate_enemy

function generate_enemy(player_level::Int)
    # Basic enemies (levels 1-4)
    basic_enemies = [
        ("Goblin", 40, 8, 3, 15),
        ("Skeleton", 50, 10, 5, 20),
        ("Orc", 70, 12, 6, 30),
        ("Dark Mage", 60, 15, 4, 35),
        ("Troll", 90, 14, 8, 45)
    ]

    # Tier 1 enemies (levels 5-9)
    tier1_enemies = [
        ("Wraith", 110, 18, 7, 55),
        ("Blood Wolf", 100, 20, 9, 60)
    ]

    # Tier 2 enemies (levels 10-14)
    tier2_enemies = [
        ("Shadow Knight", 140, 24, 12, 75),
        ("Air Elemental", 120, 28, 8, 80)
    ]

    # Tier 3 enemies (levels 15-19)
    tier3_enemies = [
        ("Demon Lord", 180, 32, 15, 100),
        ("Baby Dragon", 200, 30, 18, 110)
    ]

    # Tier 4 enemies (levels 20+)
    tier4_enemies = [
        ("Void Titan", 240, 38, 20, 130),
        ("Lich King", 220, 42, 16, 140),
        ("Dragon", 260, 40, 22, 140)
    ]


    if player_level >= 20
        enemy_pool = vcat(basic_enemies, tier1_enemies, tier2_enemies, tier3_enemies, tier4_enemies)
    elseif player_level >= 15
        enemy_pool = vcat(basic_enemies, tier1_enemies, tier2_enemies, tier3_enemies)
    elseif player_level >= 10
        enemy_pool = vcat(basic_enemies, tier1_enemies, tier2_enemies)
    elseif player_level >= 5
        enemy_pool = vcat(basic_enemies, tier1_enemies)
    else
        enemy_pool = basic_enemies
    end

    name, base_hp, base_atk, base_def, base_xp = rand(enemy_pool)
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
end
