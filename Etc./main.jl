module DungeonRPG
# src
include("src/Types.jl")
include("src/Characters.jl")
include("src/Display.jl")
include("src/Enemies.jl")
include("src/Combat.jl")
include("src/Shop.jl")
include("src/Game.jl")

# Assets
include("assets/Story.jl")

using .Game
export game_loop
end

using .DungeonRPG
game_loop()
