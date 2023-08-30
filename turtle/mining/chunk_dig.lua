--retrun to position next to chest
local function return_to_xz_origin(chest_dir, x, z)
    if(chest_dir == 1) then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    for i = z, 1, -1 do
        turtle.forward()
    end

    turtle.turnRight()
    for i = x, 1, -1 do
        turtle.forward()
    end
    
    turtle.turnLeft()
    turtle.turnLeft()
end


--get block difference
local function diff_calc(y_target, y)
    local y_target_offset = y_target + math.abs(y)
    local y_offset = y + math.abs(y)
    return y_target_offset - y_offset
end

--return to height on chest layer
local function return_to_y_origin(y_target, y)
    local diff = diff_calc(y_target, y)
    for i = diff, 1, -1 do
        turtle.up()
    end
end

--returns to last position
local function return_to_pos(y, y_target)
    local diff = diff_calc(y, y_target)
    for i = diff, 1, -1 do
        turtle.down()
    end
    return y_target
end

--refuels all slots
local function refuel_all()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.refuel()
    end
    turtle.select(1)
end

--searches for a block
local function search_block(block_name)
    print("searching for " .. block_name)
    local exists, block = turtle.inspect()
    local count = 0
    while exists == false and string.find(block.name, block_name) == false do
        turtle.turnRight()
        exists, block = turtle.inspect()
        count = count + 1
        if count >= 3 then
            sleep(5)
            count = 0
        end
    end
    print(block_name .. " found")
end

--dumps the inventory of the turtle in a chest
local function dump_inventory()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

--gets the remaining empty inventory slots
local function get_empty_slots()
    local num = 0
    for i = 1, 16, 1 do
        local count = turtle.getItemCount(i)
        if (count ~= nil) and (count ~= 0) then
            num = num + 1
        end
    end
    return 16 - num
end


local params = {...}
local y_start = tonumber(params[1])
local x_size = tonumber(params[2]) -1
local z_size = tonumber(params[3]) -1

--chest pos is on 0 1 0
local x = 0
local z = 0
local y = y_start

--able to start at a lower height
local start_at_lower = params[4]
if start_at_lower ~= nil then
    y = tonumber(params[4])
    return_to_pos(y_start, y)
end

--for chanching directions
local area_x = 0
local area_z = 0
local dir = 1

while y > -60  do
    -- dig layer
    while area_z <= z_size do
        area_x = 0
        --dig x
        while area_x < x_size do
            turtle.dig("right")
            turtle.forward()
            area_x = area_x + 1
            x = x + dir
        end
        --dig z
        area_z = area_z + 1
        if area_z <= z_size then
            if dir == 1 then
                turtle.turnLeft()
            else
                turtle.turnRight()
            end
            
            turtle.dig("right")
            turtle.forward()
    
            if(dir == 1) then
                turtle.turnLeft()
                dir = -1
            else
                turtle.turnRight()
                dir = 1
            end
            z = z + 1
        end

    end

    area_z = 0
    -- prepare for new layer
    return_to_xz_origin(dir, x, z)
    x = 0
    z = 0
    dir = 1
    local y_prev = y

    -- low fuel
    if (turtle.getFuelLevel() < (2*diff_calc(y_start, y) + 2*(z_size * x_size))) then
        return_to_y_origin(y_start, y)
        y = y_start

        --might as well dump the inventory
        search_block("chest")
        dump_inventory()

        --refuel
        print("Refuel needed")
        print("insert fuel and then press any button")
            
        while (turtle.getFuelLevel() < (math.abs(y_start + math.abs(y)) + 600)) do
            repeat
                local event, key, is_held = os.pullEvent("key")
            until is_held == false and string.find(keys.name(key), "Shift") == false
            refuel_all()
            print("Fuel level is " ..turtle.getFuelLevel())
        end
        
        --dump exess fuel
        search_block("barrel")
        dump_inventory()
        turtle.turnLeft()

    end
    
    --full inventory
    if(get_empty_slots() < 4) then
        return_to_y_origin(y_start, y)
        y = y_start

        search_block("chest")
        dump_inventory()
        if(get_empty_slots() ~= 16) then
            print("Please empty chest")
        end
        while get_empty_slots() ~= 16 do
            dump_inventory()
            sleep(10)
        end
        
        turtle.turnRight()
        turtle.turnRight()
    end
    if(y ~= y_prev) then
        y = return_to_pos(y_start, y_prev)
    end
    y = y - 1
    if y > -60 then
        turtle.digDown()
        turtle.down()
    end

end

if y == -60 then
    y = y + 1
end

return_to_xz_origin(dir, x, z)
return_to_y_origin(y_start, y)
