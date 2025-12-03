module DungeonRPG
# Assets
include("assets/Story.jl")
# src
include("src/Types.jl")
include("src/Characters.jl")
include("src/Display.jl")
include("src/Enemies.jl")
include("src/Combat.jl")
include("src/Shop.jl")
include("src/Game.jl")

using .Game
export game_loop
end

using .DungeonRPG
game_loop()
