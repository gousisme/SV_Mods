# Dialogue System in Wandering Spouses

## Overview

The Wandering Spouses mod uses a sophisticated dialogue system that allows spouses to have contextual conversations based on their wandering activities on the farm. The dialogue system supports multiple fallback levels and animation triggers.  It should be fully compatible with query strings, Content Patcher randomisation and other approaches used to increase the depth of the player experience.

### Where Spouses Can Wander

Your spouse can visit many different locations around your farm, including:

**Buildings & Structures:**
- Animal buildings (Barns, Coops, Slime Hutches)
- Farm Cave entrance
- Grandpa's Shrine
- The spouse patio area

**Natural Features:**
- Trees (both wild trees and fruit trees)
- Water features (ponds, rivers)
- Crop fields and garden areas
- General scenic spots around the farm

**Objects & Furniture:**
- Storage chests
- Seating furniture (chairs, benches)
- Broken fences that need repair
- Other decorative farm objects

**Social Interactions:**
- Approaching and talking with the farmer

Each of these locations can have specific dialogue, allowing for rich, contextual conversations that make your spouse feel more alive and engaged with farm life.

## Dialogue Tag Structure

Dialogue tags follow a hierarchical naming convention that allows for specific to general fallback behavior:

### Basic Format
```
Wander_[Specific]_[Detail]
Wander_[Specific]
Wander_[Category]
Wander_Default
```

### Dialogue Tag Hierarchy (Order of Precedence)

The mod searches for dialogue in the following order, using the first match it finds. This allows for very specific dialogue that gradually falls back to more general options:

1. **Crop-Specific with Item Name** (highest precedence)
   - Format: `Wander_[CropReason]_[CropName]`
   - Examples: `Wander_LovedCrop_Sunflower`, `Wander_LovedCrop_Pumpkin`, `Wander_MatureCrop_Blueberry`
   - Used when the spouse is near specific crops that are mature or that they love (of any maturity, could be seeds)
   - Falls back to generic crop reason if dialogue doesn't exist for the specific crop
   - Loved crop dialogue only makes sense for crops that character actually loves
   - Uses the standard English names for each crop (as found in the Objects.json data file)

2. **Animal-Specific Location Dialogue**
   - Format: 'Wander_[Building]_[Animal]`
   - Examples: 'Wander_Barn_Cow`, 'Wander_Coop_Chicken`, 'Wander_Barn_Ostrich`
   - Used when the spouse is standing outside a farm building of the specified type that is home to one or more of the specific animals
   - If the building houses more than one type of animal that has dialogue one is picked at random.
   - Can use generic options for 'Cow` and 'Chicken` or specific variants like 'BlueChicken` or 'WhiteCow`
   - Large and Deluxe barns are only referred to using the simplified name 'Barn` (as below) and the same for Coops and Sheds

3. **Generic Crop Type Dialogue**
   - Format: `Wander_[CropReason]`
   - Examples: `Wander_LovedCrop`, `Wander_MatureCrop`
   - Used when no specific crop name dialogue exists
   - Covers all loved / ready to pick (as appropriate) crops, except those that have specific lines
   - Typically characters have very few loved crops, so it makes more sense to do dialogue for them specifically

4. **Specific Location Dialogue**
   - Format: `Wander_[LocationName]`
   - Examples: `Wander_Barn`, `Wander_Coop`, `Wander_Cave`, `Wander_Patio`, `Wander_GrandpaShrine`, `Wander_Tree`, `Wander_FruitTree`, `Wander_Water`
   - Used for specific buildings or farm locations
   - For 'Big' and 'Deluxe' buildings this falls back to the simplified building types as below

5. **Simplified Building Names**
   - If the specific building name isn't found, the will also try simplified versions of complex building names:
     - `BigBarn` and `DeluxeBarn` → `Wander_Barn`
     - `BigCoop` and `DeluxeCoop` → `Wander_Coop` 
     - `BigShed` → `Wander_Shed`
   - This means you only need dialogue for the basic building types, but can specify different dialogue for the 'Big' and 'Deluxe' versions if desired.

6. **Category-Based Dialogue**
   - Format: `Wander_[Category]`
   - Categories are:
     - `Building` - Any farm building without specific dialogue
     - `Scenic` - Beautiful farm features (trees, water, crops, etc.)
     - `Seat` - When sitting on a bench or chair (only Abigail, Elliott, Maru and Penny can sit)
     - `Object` - Interactive objects like chests
     - `Farmer` - When approaching the player

7. **Default Dialogue** (lowest precedence)
   - Format: `Wander_Default`
   - The final fallback used when no other dialogue matches
   - Should always be included as a safety net

If no dialogue is found for any of those, the characters will remain silent while walking around the farm.

## Animation System ($z Tags)

The dialogue system supports animation triggers using the special `$z` tag format:

### $z Tag Format
```
$z [animation_name] [minimum_wait]#[rest of dialogue]
```

### How $z Tags Work

The `$z` tag can only be included at the start of a dialogue line. When you include `$z`, the spouse will perform the specified animation when they reach their destination when that dialogue is active. 

You can optionally include a minimum wait (in minutes) which will force the character to remain in that animation for at least that long before wandering again (unless it hits 5pm). By default spouses will remain in each location for a minimum of 30 minutes. You can only specify a minimum wait if you also specify an animation.

1. **Format**: The dialogue line should start with `$z [animation_name]#` followed by the dialogue text as normal
2. **Timing**: The animation plays when the spouse arrives at their wandering destination
3. **Flexibility**: You can use any animation name that exists in the game, or 'patio' to play that spouse's patio animation

### Special Animations

#### Patio Animation
- **Trigger**: `$z patio`
- **Effect**: The spouse will perform their special Saturday patio behavior
- **Example**: (for Haley) `"$z patio#There are so many things on this farm that need their photo taken."`

#### Other Animations
- **Examples**: `$z emily_exercise#I love this dance`, `$z penny_wave_left#Just waving at the air here`
- **Effect**: The spouse will perform the specified animation
- **Note**: Use any valid Stardew Valley animation name. You should however restrict yourself to animations defined for that character, and specifically listing the 'sleep' or 'sit_down' animations does not give good results.

## Implementation Details

### Dialogue Resolution Process

1. **Context Analysis**: The mod determines what the spouse is near (crop, building, object, etc.)
2. **Dialogue Search**: Searches the character's dialogue for matches following the precedence order
3. **Animation Parsing**: If dialogue starts with a `$z` tag, extracts and prepares the animation
4. **Execution**: The spouse walks to their destination, performs any animation, and speaks the dialogue

### Example Fallback Chain

Here's how the system might work for a spouse near a parsnip crop they love:

1. First tries: `Wander_LovedCrop_Parsnip` (most specific)
2. If not found: `Wander_LovedCrop` (generic loved crop)
3. If not found: `Wander_Scenic` (category for crops)
4. If not found: `Wander_Default` (final fallback)

This ensures there's always appropriate dialogue while allowing for very specific customization.

## Content Pack Integration

Content packs should include dialogue files with rows that follow this naming convention. The mod will automatically detect and use appropriately named dialogue entries.

**Important:** Add these dialogue entries to the character's main dialogue file (e.g., `Abigail.json`), not their marriage-specific dialogue file. This ensures the dialogue is available when the spouse is wandering around the farm.

### Recommended Dialogue Keys for Content Packs

```
Wander_Default
Wander_Building
Wander_Scenic  
Wander_Farmer
Wander_Barn
Wander_Barn_Cow
Wander_Coop
Wander_Shed
Wander_Cave
Wander_Patio
Wander_Tree
Wander_FruitTree
Wander_LovedCrop
Wander_MatureCrop
Wander_Water
Wander_Chest
Wander_BrokenFence
Wander_GrandpaShrine
Wander_Seat
```

This hierarchical system ensures that spouses have meaningful, contextual dialogue that enhances the immersive farm experience while providing sensible fallbacks for any situation.
