module Story

export get_wake_story, print_story_slowly

"""
    get_wake_story(char_name::String)

Returns the wake story with the character's name interpolated.
"""
function get_wake_story(char_name::String)
    return """You awaken in a dimly lit forest, your head throbbing with pain.
The last thing you remember is being separated from your party during a long battle
against a fierce foe, but you've forgotten your own name and the names of your comrades.
You look around you, and find your weapon, and a leather traveling pack with a name
etched into the outer surface. The name reads: $char_name. You feel a sense of
familiarity when reading the name. This must be yours, right? You search the traveling
pack and find a few health potions, a map, and a scroll with the name of a tavern written
on it. You find the tavern on the map, and head out to find it.

Before nightfall, you find the Tavern. As you approach, you are greeted by the strong aroma
of smoked meat, warm bread, and ale. You push open the heavy wooden doors and walk inside.

The tavern is bustling with activity. Patrons are laughing, drinking, and sharing stories of
their adventures. The warmth from the fireplace and the lively atmosphere make you feel at ease.
You make your way to the bar and order a drink, hoping to gather information about your
lost memories and your missing party members.

As you approach, the barkeep's face lights up. He's happy to see you, though you aren't sure why.
After greeting you, he slides a mug of ale across the counter and says,
"It's good to see you, $char_name, but where are your friends?" You explain your situation, and
his expression turns grim. "Ah, I feared as much. Many adventurers have gone missing in these parts recently.
You must be tired and hungry. Why don't you rest here for the night? We can talk more in the morning."

You nod in agreement, grateful for the hospitality.

In the morning, you wake up feeling refreshed. You leave the room and head to the common area.
Before you can find a seat, the barkeep approaches you with a hearty breakfast and a pint of ale.
He guides you to an empty table and sits down across from you. "Listen, $char_name," he begins,
"there's been rumors of a dark force rising in the nearby dungeons. All but the bravest adventurers
have been too scared to investigate. If you're looking for your friends, those dungeons might hold
the key."

You finish your meal and thank the barkeep for the information. You know that in order to find your
friends, and perhaps your lost memories, you must venture into the dungeons. With renewed determination,
you gather your belongings and prepare to face the challenges ahead.\n"""
end

"""
    print_story_slowly(story::String, delay::Float64=0.03)

Prints the story one character at a time with a delay between each character.
Default delay is 0.03 seconds (30ms) for a typewriter effect.
"""
function print_story_slowly(story::String, delay::Float64=0.03)
    for char in story
        print(char)
        flush(stdout)
        sleep(delay)
    end
    println()
end

end