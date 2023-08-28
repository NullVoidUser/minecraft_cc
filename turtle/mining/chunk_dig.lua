--retrun to position under chest
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

--return to height under chest
local function return_to_y_origin(y_start, y)
    local diff = math.abs(y_start + math.abs(y))
    for i = diff, 1, -1 do
        turtle.up()
    end
end

--dumps the inventory of the turtle in a chest
local function dump_inventory()
    local is_block = turtle.inspectUp()
    if(is_block == false) then
        print("Please place a chest above the turtle")
        while turtle.inspectUp() == false do
            sleep(5)
        end
    end
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.dropUp()
    end
    turtle.select(1)
end

--gets the remaining empty inventory slots
local function get_empty_slots()
    local num = 0
    for i = 1, 16, 1 do
        turtle.select(i)
        local count = turtle.getItemCount()
        if (count ~= nil) and (count ~= 0) then
            num = num + 1
        end
    end
    turtle.select(1)
    return 16 - num
end

--returns to last position
local function return_to_pos(y_start, y_target)
    local diff = math.abs(y_start + math.abs(y))
    for i = diff, 1, -1 do
        turtle.down()
    end
    return y_target
end


local params = {...}
local y_start = tonumber(params[1])
local x_size = tonumber(params[2]) -1
local z_size = tonumber(params[3]) -1

--chest pos is on 0 1 0
local x = 0
local z = 0
local y = y_start

--for chanching directions
local area_x = 0
local area_z = 0
local dir = 1

-- fuel level to garantee a trip to origin

while y > -60  do
    -- dig layer
    while area_z < z_size do
        while area_x < x_size do
            turtle.dig("right")
            turtle.forward()
            area_x = area_x + 1
            x = x + dir
        end

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

        area_z = area_z + 1
        z = z + 1
        area_x = 0
    end

    if(area_z == z_size) then
        if (dir == 1) then
            turtle.turnRight()
            dir = -1
        else
            turtle.turnRight()
            dir = 1
        end
        turtle.forward()
        turtle.turnRight()
    end
    area_z = 0

    -- prepare for new layer
    return_to_xz_origin(dir, x, z)
    x = 0
    z = 0
    dir = 1
    local y_prev = y
    -- low fuel
    if (turtle.getFuelLevel() < (math.abs(y_start + math.abs(y)) + 600)) then
        return_to_y_origin(y_start, y)
        y = y_start
        dump_inventory()
        print("Refuel needed")
        while (turtle.getFuelLevel() < (math.abs(y_start + math.abs(y)) + 600)) do
            turtle.refuel()
            sleep(5)
        end
    end
    
    --full inventory
    if(get_empty_slots() < 4) then
        return_to_y_origin(y_start, y)
        y = y_start
        dump_inventory()
        if(get_empty_slots() ~= 16) then
            print("Please empty chest")
        end
        while get_empty_slots() ~= 16 do
            dump_inventory()
            sleep(10)
        end
    end

    y = return_to_pos(y_start, y_prev)
    if y > -60 then
        turtle.digDown()
        turtle.down()
    end

end

