--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    local spawnedLock = false
    local spawnedKey = false
    lockAndKeyColour = math.random(4)  -- Randomised colour of the lock and key pair
    unlockedLock = false


    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if (math.random(7) == 1) and (x > 1) then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end
                

                -- Chance to generate key on pillar
                if spawnedKey == false and math.random(10) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'keys-and-locks',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            frame = LOCK_AND_KEY_IDs[lockAndKeyColour],
                            collidable = true,
                            consumable = true,
                            solid = false,
                            onConsume = function(player, object)
                                gSounds['pickup']:play()
                                player.hasKey = true
                            end
                        }
                    )
                    spawnedKey = true
                end


                -- Chance to generate lock on pillar
                if spawnedLock == false and math.random(10) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'keys-and-locks',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            frame = LOCK_AND_KEY_IDs[lockAndKeyColour+4],
                            collidable = true,
                            hit = false,
                            solid = true,
                            transitionAlpha = 255,
                        
                        onCollide = function(object)
                            object.solid = false
                            gSounds['pickup']:play()
                            -- Tween the alpha of the lock so it's disappearance looks nice
                            Timer.tween(1, {[object] = {transitionAlpha = 0}  })
                            unlockedLock = true
                            local flagDisplacement = width + math.random(-60, -20)  -- Distance the flag pole will be from the end of the screen

                            -- Add the three parts of the flagpole
                            local flagpole_top = GameObject {
                                        texture = 'flags-and-poles',
                                        x = (width - flagDisplacement) * TILE_SIZE,
                                        y = (blockHeight + 1) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = 2,
                                        collidable = false,
                                        consumable = true,  -- If consumable is true, then you have to define the onConsume function
                                        -- but if consumable is true, the texture never appears...
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            gStateMachine:change('play', {score = player.score, newLevelWidth = math.floor(1.1*width)})
                                        end
                                    }
                                    table.insert(objects, flagpole_top)
                            local flagpole_mid = GameObject {
                                        texture = 'flags-and-poles',
                                        x = (width - flagDisplacement) * TILE_SIZE,
                                        y = (blockHeight + 2) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = 11,
                                        collidable = false,
                                        consumable = true,  -- If consumable is true, then you have to define the onConsume function
                                        -- but if consumable is true, the texture never appears...
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            gStateMachine:change('play', {score = player.score, newLevelWidth = math.floor(1.1*width)})
                                        end
                                    }
                                    table.insert(objects, flagpole_mid)
                            local flagpole_base = GameObject {
                                        texture = 'flags-and-poles',
                                        x = (width - flagDisplacement) * TILE_SIZE,
                                        y = (blockHeight + 3) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = 20,
                                        collidable = false,
                                        consumable = true,  -- If consumable is true, then you have to define the onConsume function
                                        -- but if consumable is true, the texture never appears...
                                        solid = false,

                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            gStateMachine:change('play', {score = player.score, newLevelWidth = math.floor(1.1*width)})
                                        end
                                    }
                                    table.insert(objects, flagpole_base)
                            local flagpole_flag = GameObject {
                                        texture = 'flags-and-poles',
                                        x = (width - flagDisplacement) * TILE_SIZE + 8,
                                        y = (blockHeight + 1) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = 7,
                                        collidable = false,
                                        consumable = true,  -- If consumable is true, then you have to define the onConsume function
                                        -- but if consumable is true, the texture never appears...
                                        solid = false,

                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            gStateMachine:change('play', {score = player.score, newLevelWidth = math.floor(1.1*width)})
                                        end
                                    }
                                table.insert(objects, flagpole_flag)
                            end
                        }
                    )
                    spawnedLock = true
                end

                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )


            -- Chance to generate key
            elseif spawnedKey == false and math.random(10) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'keys-and-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = LOCK_AND_KEY_IDs[lockAndKeyColour],
                        collidable = true,
                        consumable = true,
                        solid = false,
                        onConsume = function(player, object)
                            gSounds['pickup']:play()
                            player.hasKey = true
                        end
                    }
                )
                spawnedKey = true


            -- Chance to generate lock
            elseif spawnedLock == false and math.random(10) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'keys-and-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = LOCK_AND_KEY_IDs[lockAndKeyColour + 4],
                        collidable = true,
                        hit = false,
                        solid = true,
                        transitionAlpha = 255,
                        --unlocked = false,
                        
                        onCollide = function(object)
                            object.solid = false
                            gSounds['pickup']:play()
                            -- Tween the alpha of the lock so it's disappearance looks nice
                            Timer.tween(1, {[object] = {transitionAlpha = 0}  })
                            unlockedLock = true
                            local flagDisplacement = width + math.random(-60, -20)  -- Distance the flag pole will be from the end of the screen

                            -- Add the three parts of the flagpole
                            local flagpole_top = GameObject {
                                        texture = 'flags-and-poles',
                                        x = (width - flagDisplacement) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = 2,
                                        collidable = false,
                                        consumable = true,  -- If consumable is true, then you have to define the onConsume function
                                        -- but if consumable is true, the texture never appears...
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            gStateMachine:change('play', {score = player.score, newLevelWidth = math.floor(1.1*width)})
                                        end
                                    }
                                    table.insert(objects, flagpole_top)
                            local flagpole_mid = GameObject {
                                        texture = 'flags-and-poles',
                                        x = (width - flagDisplacement) * TILE_SIZE,
                                        y = (blockHeight - 0) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = 11,
                                        collidable = false,
                                        consumable = true,  -- If consumable is true, then you have to define the onConsume function
                                        -- but if consumable is true, the texture never appears...
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            gStateMachine:change('play', {score = player.score, newLevelWidth = math.floor(1.1*width)})
                                        end
                                    }
                                    table.insert(objects, flagpole_mid)
                            local flagpole_base = GameObject {
                                        texture = 'flags-and-poles',
                                        x = (width - flagDisplacement) * TILE_SIZE,
                                        y = (blockHeight + 1) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = 20,
                                        collidable = false,
                                        consumable = true,  -- If consumable is true, then you have to define the onConsume function
                                        -- but if consumable is true, the texture never appears...
                                        solid = false,

                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            gStateMachine:change('play', {score = player.score, newLevelWidth = math.floor(1.1*width)})
                                        end
                                    }
                                    table.insert(objects, flagpole_base)
                            local flagpole_flag = GameObject {
                                        texture = 'flags-and-poles',
                                        x = (width - flagDisplacement) * TILE_SIZE + 8,
                                        y = (blockHeight - 1) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = 7,
                                        collidable = false,
                                        consumable = true,  -- If consumable is true, then you have to define the onConsume function
                                        -- but if consumable is true, the texture never appears...
                                        solid = false,

                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            gStateMachine:change('play', {score = player.score, newLevelWidth = math.floor(1.1*width)})
                                        end
                                    }
                                    table.insert(objects, flagpole_flag)

                        end
                    }
                )
                spawnedLock = true
            end


            


            

            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end