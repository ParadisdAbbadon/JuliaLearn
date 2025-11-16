module DungeonRPG
    # Include each file exactly once - order matters!
    include("src/Types.jl")
    include("src/Characters.jl")
    include("src/Display.jl")
    include("src/Enemies.jl")
    include("src/Combat.jl")
    include("src/Shop.jl")
    include("src/Game.jl")
    
    # Make game_loop available
    using .Game
    export game_loop
end

# Run the game
using .DungeonRPG
game_loop()
