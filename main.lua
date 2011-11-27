require('math_snippet')
require('tiles')
require('camera')
require('savetabletofile')

function love.load()

    tiles, map = init_tiles()
    selectedTile = 1
    speed = 250
    is_menu = true
    menu = {}
    menu.item = 1    
    menu.saving = false
    menu.titleset = false
    key_disable = { --keys to disable in case they are not in use.
      "up","down","left","right","home","end","pageup","pagedown",--Navigation keys
      "insert","tab","clear","delete",--Editing keys
      "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15",--Function keys
      "backspace","rshift","lshift","numlock","scrollock","ralt","lalt","rmeta","lmeta","lsuper","rsuper","mode","compose","lctrl","rctrl", --Modifier keys
      "pause","escape","help","print","sysreq","break","menu","power","euro","undo"--Miscellaneous keys
    }
    save_text = "Save map"
    load_text = "Load map"
    cursorS = ""
    cursorL = ""
    blink = 0
    
    mx = 0
    my = 0
    
    camera:setBounds(0, 0, tiles.w - 512, tiles.h - 512)
    love.graphics.setFont(love.graphics.newFont("Adler.ttf", 20))
    
end

function in_table(t,s)
  for i,v in pairs(t) do
    if (v==s) then 
      return true
    end
  end
end

function update_start_menu(key, button)
         -- ups and downs selection
	if key== "up" and menu.item > 1 then
          menu.item = menu.item - 1 
	elseif key == "down" and menu.item < 4 then
          menu.item = menu.item + 1
	elseif key== "w" and menu.item > 1 then
          menu.item = menu.item - 1
	elseif key == "s" and menu.item < 4 then
          menu.item = menu.item + 1
	end
	-- mouse selection
	if my > camera:getY() + 400 then
	    menu.item = 4
	elseif my > camera:getY() + 350 then
	    menu.item = 3
	elseif my > camera:getY() + 300 then
	    menu.item = 2
	elseif my > camera:getY() + 250 then
	    menu.item = 1
	end
        --  edit
        if menu.item == 1 and (button == "l" or key=="return") then
            is_menu = false
        -- save
	elseif menu.item == 2 and (button == "l"  or key=="return") then
            menu.saving = true
            menu.loading = false
            save_text = ""
            cursorS = "_"
            is_menu = false
        -- load map
	elseif menu.item == 3 and (button == "l"  or key=="return") then
            menu.loading = true
            menu.saving = false
            load_text = ""
            cursorL = "_"
            is_menu = false
        -- exit
	elseif menu.item == 4 and (button == "l"  or key=="return") then
            love.event.push('q') -- Exit
	end
end

function update_save(key)
        if key == "return" then
                save_tile(save_text)
                save_text = "Save map"
                cursorS = ""
                menu.saving = false
                is_menu = true
        elseif in_table(key_disable,key) then 
        else
                save_text = save_text..key
        end
end

function update_load(key)
        if key == "return" then
                load_map(tiles, load_text)
                load_text = "Load map"
                cursorL = ""
                menu.loading = false
                is_menu = true
        elseif in_table(key_disable,key) then 
        else
                load_text = load_text..key
        end
end


function love.update(dt)


    mx, my = camera:mousePosition()
    x = math.floor(mx / tiles.tileW)
    y = math.floor(my / tiles.tileH)

    if is_menu  then
        update_start_menu()
    elseif menu.saving then
        if blink > 0.2 then 
                if cursorS == "_" then cursorS = ""
                else cursorS = "_" end
                blink = 0
        else
                blink = blink + dt
        end
    elseif menu.loading then
        if blink > 0.2 then 
                if cursorL == "_" then cursorS = ""
                else cursorL = "_" end
                blink = 0
        else
                blink = blink + dt
        end
    else -- edit map    
    
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
                camera:move(speed*dt, 0)
        elseif love.keyboard.isDown("left") or love.keyboard.isDown("a")then
                camera:move(-speed*dt, 0)
        end

        if love.keyboard.isDown("down") or love.keyboard.isDown("s")then
                camera:move(0, speed*dt)
        elseif love.keyboard.isDown("up") or love.keyboard.isDown("w")then
                camera:move(0, -speed*dt)
        end
    end
    
end


function modify_tile(selectedTile)
    tiles.tileTable[x+1][y+1] = tiles.chars[selectedTile]
end

function save_tile(filename)
    local str = ''
    reversed = {}
    
    for k = 1, #tiles.tileTable[1] do
        reversed[k] = {}
    end
    
     for i = 1, #tiles.tileTable do
        for j = 1, #tiles.tileTable[i] do
            reversed[j][i] = tiles.tileTable[i][j]
        end
    end 
    
    for i = 1, #reversed do
        for j = 1, #reversed[i] do
            str = str .. reversed[i][j]
        end
        str = str  .. '\n'
    end 
    map.tileString = str
    table.save( map , filename)
end

function love.mousepressed(x, y, button)
   if button == 'wd' then
      if selectedTile < #tiles.chars then
            selectedTile = selectedTile + 1
      else 
            selectedTile = 1
      end
   elseif button == 'wu' then
        if selectedTile > 1 then
            selectedTile = selectedTile - 1
      else 
            selectedTile = #tiles.chars
      end
   end
   
   
   if button == 'l' then
        if is_menu then
                update_start_menu(_, button)
        else        
                modify_tile(selectedTile)
        end
   elseif button == 'r' then
        is_menu = true
   end
   
end


function love.keypressed( key )
        if is_menu then
                update_start_menu(key)
        elseif menu.saving then
                update_save(key)
        elseif menu.loading then
                update_load(key)
        end
end


function draw_menu(menu)
      -- fill the camera with dark semitransparent background
      love.graphics.setColor(10, 10, 10, 170)
      love.graphics.circle("fill", camera:getX(), camera:getY(), 1500)
      
      love.graphics.setColor(200, 0, 0)
      love.graphics.circle("line", mx, my, 10)
      
      -- title
      love.graphics.setColor(200, 200, 200)
      love.graphics.print("Love for zombies Mapper", camera:getX() + 10, camera:getY() + 10, 0, 2, 2 )
      
      -- if selected, color is red, else is white
      -- really unefficient here
      if menu.item == 1 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print("Edit map", camera:getX() + 200, camera:getY() + 250 )
      love.graphics.setColor(200, 200, 200)
      if menu.item == 2 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print(save_text..cursorS, camera:getX() + 200, camera:getY() + 300)
      love.graphics.setColor(200, 200, 200)
      if menu.item == 3 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print(load_text..cursorL, camera:getX() + 200, camera:getY() + 350)
      love.graphics.setColor(200, 200, 200)
      if menu.item == 4 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print("Exit", camera:getX() + 200, camera:getY() + 400)
      love.graphics.setColor(200, 200, 200)
      
end


function love.draw()

    camera:set()

    draw_tiles(tiles)    
 
    if is_menu or menu.saving or menu.loading then
        draw_menu(menu)
    else
        love.graphics.setColor(200, 200, 200)
        love.graphics.drawq(tiles.tileset, tiles.quads[tiles.chars[selectedTile]], x * tiles.tileW, y * tiles.tileH)
        love.graphics.setColor(200, 0, 0)
        love.graphics.rectangle("line", x * tiles.tileW, y * tiles.tileH, tiles.tileW, tiles.tileH)
        love.mouse.setVisible(false)
    end
    
    camera:unset()
end