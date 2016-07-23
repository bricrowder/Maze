function love.load()  
	--initilize the game variables
	game = {}
  game["scale"] = 32          -- how big each cell is drawn in pixels
	game["height"] = 16         -- how high the floorplan is 
	game["width"] = 24          -- how wide the floorplan is
  game["offset_w"] = 16       -- X pixel offset the floorplan is drawn
	game["offset_h"] = 72       -- Y pixel offset the floorplan is drawn
  game["max_room_size"] = 4	  -- the maximum cell size for a room

	--initialize the floorplan for the background
	floorplan_clear()
	--create floorplan for the background
	floorplan_generate(game.height, game.width)
      
end

function love.keyreleased(key)
  if (key == "escape") then
    love.event.quit()
  end

  if (key == "g") then
    floorplan_clear()
  	floorplan_generate(game.height, game.width)
  end
end

function love.draw()  
    floorplan_draw()
end

--initialize the game variables
function game_init()
	game = {}
  --start the game in the menu state
  game["scale"] = 0
	game["height"] = 0
	game["width"] = 0
  game["offset_w"] = 16
	game["offset_h"] = 72
  game["max_room_size"] = 0	
end

function game_newgame(scale, height, width, maxroomsize)
  game.scale = scale
  game.height = height
  game.width = width  
	game.max_room_size = maxroomsize
end

--resets the floorplan table
function floorplan_clear()
	floorplan = {}
end

--generates a floor plan with the designated height and width
function floorplan_generate(mh, mw)
	--initialize some loop index counters
	local i, j  --(ROWxCOLUMN)
	local x, y  --(ROWxCOLUMN)
	local r		--random value
	
	--create initial floorplan with all walls and determine the borders (for a square floorplan)
	for i = 1, mh do
		--make a row of cells
		floorplan[i] = {}
		for j = 1, mw do
			--make the cell a copy of the template
			local c = {}
			c["visited"] = 0		--a flag to determine if it has been visited
			c["W"] = 1			--does it have a west wall
			c["S"] = 1			--does it have a south wall
			c["E"] = 1			--does it have an east wall
			c["N"] = 1			--does it have a north wall
			c["Wb"] = 0			--is the west wall a border
			c["Sb"] = 0			--is the south wall a border
			c["Eb"] = 0			--is the east wall a border
			c["Nb"] = 0			--is the north wall a border
			c["Wd"] = 0			--is the west wall a door
			c["Sd"] = 0			--is the south wall a door
			c["Ed"] = 0			--is the east wall a door
			c["Nd"] = 0			--is the north wall a door
			
						
			floorplan[i][j] = c
			--determine if we need to set a north border
			if i == 1 then
				floorplan[i][j].Nb = 1
			end
			--determine if we need to set a south border
			if i == mh then
				floorplan[i][j].Sb = 1
			end			
			--determine if we need to set a west border
			if j == 1 then
				floorplan[i][j].Wb = 1
			end
			--determine if we need to set a east border
			if j == mw then
				floorplan[i][j].Eb = 1
			end	
			--print(i.."x"..j..": N:"..floorplan[i][j].Nb.." S:"..floorplan[i][j].Sb.." E:"..floorplan[i][j].Eb.." W:"..floorplan[i][j].Wb.." V:"..floorplan[i][j].visited)
		end
	end

	--initialize the visited cell counters
	local cell_count = 0
	local cell_max = mh*mw
	
	--initialize the first random starting cell
	local start_cell = {}
	--insert the first start cell into the stack
	--position 3,4 = top/left of room once determined
	--position 5,6 = h/w of room once determined
	table.insert(start_cell,{math.random(1, mh),math.random(1,mw),0,0,0,0})
	
	--we will need to keep track of the doors
	local doors = {}
	
	while cell_count < cell_max do
		--print("visited cell count: "..cell_count)
		
		x = start_cell[#start_cell][1]		--ROW
		y = start_cell[#start_cell][2]		--COLUMN
		
		--print("start cell: "..x..","..y)
		
		--randomly select the maximum size of the room
		local room_size = love.math.random(game.max_room_size)
					
		--where the actual sizes are stored, start at 1,1 as it will always be at least 1,1 in size
		local h = 0		--# of ROWS
		local w = 0		--# of COLUMNS		
		
		--determine what direction to give the room build
		--if previous position is:
		--	above then give it South priority (row +)
		--	below then give it North priority (row -)
		--  left then give it East priority (column +)
		--  right then give it West priority (column -)
		--  if it is the first room (no cells visited) then we just go South
		
		local row_inc = 1
		local col_inc = 1
		
		--determine the room creation direction for rows and columns, based on orientation of door
		if cell_count > 0 then
			--door is above new room
			if doors[#doors][1] < x then
				--rows will drow down
				row_inc = 1
				--check to see if the cell to the right is a border and/or been visited, if so change our column grow direction
				if floorplan[x][y].Eb == 1 then
					col_inc = -1
				else
					if floorplan[x][y+1].visited == 1 then
						col_inc = -1
					end
				end
			end
			--below
			if doors[#doors][1] > x then 
				--grow up
				row_inc = -1
				--check to see if the cell to the right is a border and/or been visited, if so change our column grow direction
				if floorplan[x][y].Eb == 1 then
					col_inc = -1
				else
					if floorplan[x][y+1].visited == 1 then
						col_inc = -1
					end
				end
			end
			--left of room
			if doors[#doors][2] < y then 
				--grow right
				col_inc = 1
				--check to see if the cell below is a border and/or been visited, if so change our row grow direction
				if floorplan[x][y].Sb == 1 then
					row_inc = -1
				else
					if floorplan[x+1][y].visited == 1 then
						row_inc = -1
					end
				end
			end
			--right
			if doors[#doors][2] > y then 
				--grow left
				col_inc = -1 
				--check to see if the cell below is a border and/or been visited, if so change our row grow direction
				if floorplan[x][y].Sb == 1 then
					row_inc = -1
				else
					if floorplan[x+1][y].visited == 1 then
						row_inc = -1
					end
				end				
			end
		end
		
		--print("row/col direction: "..row_inc..","..col_inc)
		
		--create a table to store the row/column count results
		local counts = {}
		
		--NOTE: this creates rooms with a width priority
		
		for i = 1, room_size do
			w = 0
			for j = 1, room_size do
				if floorplan[x+((i-1)*row_inc)][y+((j-1)*col_inc)].visited == 0 then
					w = w + 1
				else
					break
				end
				
				--check for border bounds based on direction
				if col_inc == 1 then
					if floorplan[x+((i-1)*row_inc)][y+((j-1)*col_inc)].Eb == 1 then break end					
				else
					if floorplan[x+((i-1)*row_inc)][y+((j-1)*col_inc)].Wb == 1 then break end									
				end					
			end
			--add the count to the table
			table.insert(counts,w)

			--increment the row counter if the current row is >= to the first row (starts at 0 to pick up the first row which will be true)
			if counts[i] >= counts[1] then 
				h = h + 1
			else
				--it isn't so break
				break
			end
				
			--check the down bounds of the next row to make sure we can move to it
			if row_inc == 1 then
				if floorplan[x+((i-1)*row_inc)][y].Sb == 1 then break end			
			else
				if floorplan[x+((i-1)*row_inc)][y].Nb == 1 then break end			
			end
		end

		--set the actual width
		w = counts[1]

		--set the top/left cell x,y used for easier calculations later
		if row_inc == -1 then
			start_cell[#start_cell][3] = x+((h-1)*row_inc)		--ROW
		else
			start_cell[#start_cell][3] = x
		end
		if col_inc == -1 then
			start_cell[#start_cell][4] = y+((w-1)*col_inc)		--ROW
		else
			start_cell[#start_cell][4] = y
		end
		
		--reset the x, y values for easier calculations
		x = start_cell[#start_cell][3]
		y = start_cell[#start_cell][4]
		
		--record the cell h/w used for calculations later
		start_cell[#start_cell][5] = h
		start_cell[#start_cell][6] = w
		
		--print("actual size: "..h.."x"..w)		--ROWxCOLUMN
		
		--print("top/left: "..x..","..y)
		
		--mark the cells as visited
		for i = 1, h do
			for j = 1, w do
				floorplan[x+i-1][y+j-1].visited = 1
			end
		end
		
		--increment the cell count
		cell_count = cell_count + h*w
		
		--remove the interior walls
		for i = 1, h do
			for j = 1, w do
				--If it isn't the first row of the room then remove the N wall.
				if i ~= 1 then floorplan[x+i-1][y+j-1].N = 0 end
				--If it isn't the last row in the room then remove the S wall.
				if i ~= h then floorplan[x+i-1][y+j-1].S = 0 end
				--If it isn't the first column in he room then remove the W wall
				if j ~= 1 then floorplan[x+i-1][y+j-1].W = 0 end
				--If it isn't the last column in the room then remove the E wall
				if j ~= w then floorplan[x+i-1][y+j-1].E = 0 end
			end
		end
		
		--find a place for a door and new start cell
		local found_new_cell = 0
		
		while found_new_cell == 0 and cell_count < cell_max do
			--we need to obtain the top/left and h/w of the current start cell
			x = start_cell[#start_cell][3]
			y = start_cell[#start_cell][4]
			h = start_cell[#start_cell][5]
			w = start_cell[#start_cell][6]
			
			--print("start cell: "..x..","..y)
			--build a list of valid cells where we can put a door: off of any outer cell that isn't a border
			local valid_cells = {}
			
			--something is screwed up here... with the indexes?  From here or before??
			
			--check all columns on the north and south wall and add cells
			--checking for border and if cell isn't already visited
			--print("checking columns (HxW): "..h.."x"..w)
			for j = 1, w do
				--print("north border check: "..x..","..y+j-1)
				if floorplan[x][y+j-1].Nb == 0 then
					--print("pass - visited check: "..(x-1)..","..y+j-1)
					if floorplan[x-1][y+j-1].visited == 0 then table.insert(valid_cells,{x-1, y+j-1}) end
				end
				--print("south border check: "..(x+h-1)..","..y+j-1)
				if floorplan[x+h-1][y+j-1].Sb == 0 then
					--print("pass - visited check: "..(x+h)..","..y+j-1)
					if floorplan[x+h][y+j-1].visited == 0 then table.insert(valid_cells,{x+h, y+j-1}) end
				end
			end
			--check all rows on the west wall and add cells from the column to the left
			--print("checking rows (HxW): "..h.."x"..w)
			for i = 1, h do
				--print("west border check: "..(x+i-1)..","..y)
				if floorplan[x+i-1][y].Wb == 0 then
					--print("pass - visited check: "..(x+i-1)..","..y-1)
					if floorplan[x+i-1][y-1].visited == 0 then table.insert(valid_cells,{x+i-1, y-1}) end
				end
				--print("east border check: "..(x+i-1)..","..(y+w-1))
				if floorplan[x+i-1][y+w-1].Eb == 0 then
					--print("pass - visited check: "..(x+i-1)..","..y+w)
					if floorplan[x+i-1][y+w].visited == 0 then table.insert(valid_cells,{x+i-1, y+w}) end
				end
			end
			
			--[[if #valid_cells > 0 then
				for i = 1, #valid_cells do
					print("valid cell: "..valid_cells[i][1]..","..valid_cells[i][2])
				end
			end]]
				
			if #valid_cells > 0 then
				--we found a cell
				found_new_cell = 1

				--randomly select one
				r = math.random(#valid_cells)
				local x2 = valid_cells[r][1]
				local y2 = valid_cells[r][2]
				
				--add it to the start_cell table, again with 0,0 at the end which will be calculated in a different spot
				table.insert(start_cell, {x2,y2,0,0,0,0})
				
				--print("new cell: "..x2..","..y2)
				
				--determine its orientation to the room (above, below, left or right)
				--is it above?
				if x2 < x then
					--remove S from new start cell
					floorplan[x2][y2].S = 0
					--remove N from cell in room
					floorplan[x2+1][y2].N = 0
					--add it to the doors table
					table.insert(doors, {x2+1,y2})
					
				end
				--is it below?
				if x2 > x+h-1 then
					floorplan[x2][y2].N = 0
					floorplan[x2-1][y2].S = 0	
					--add it to the doors table
					table.insert(doors, {x2-1,y2})
				end
				--is it to the left?
				if y2 < y then
					floorplan[x2][y2].E = 0
					floorplan[x2][y2+1].W = 0
					--add it to the doors table
					table.insert(doors, {x2,y2+1})
				end
				--is it to the right?
				if y2 > y+w-1 then
					floorplan[x2][y2].W = 0
					floorplan[x2][y2-1].E = 0
					--add it to the doors table
					table.insert(doors, {x2,y2-1})
				end			
			else
				--print("no valid cells")
				--we didn't find any valid cells to move to from the current room, pop it off the start_cells stack and try again
				table.remove(start_cell)
				--we need to also pop a door record to be in line with the start_cells
				table.remove(doors)
			end
		end
	end	
	
end

function floorplan_draw()
	--loop through the floorplan table
	love.graphics.setColor(255,255,255,255)
	local i, j
	for i = 1, game.height do
		for j = 1, game.width do
			--draw walls based on scale and cell position
			--draw north wall			
			if floorplan[i][j].N == 1 then
				love.graphics.line((j-1)*game.scale+game.offset_w, (i-1)*game.scale+game.offset_h, j*game.scale+game.offset_w, (i-1)*game.scale+game.offset_h)
			end
			--draw south wall
			if floorplan[i][j].S == 1 then
				love.graphics.line((j-1)*game.scale+game.offset_w, i*game.scale+game.offset_h, j*game.scale+game.offset_w, i*game.scale+game.offset_h)
			end
			--draw west wall
			if floorplan[i][j].W == 1 then
				love.graphics.line((j-1)*game.scale+game.offset_w, (i-1)*game.scale+game.offset_h, (j-1)*game.scale+game.offset_w, i*game.scale+game.offset_h)
			end
			--draw east wall
			if floorplan[i][j].E == 1 then
				love.graphics.line(j*game.scale+game.offset_w, (i-1)*game.scale+game.offset_h, j*game.scale+game.offset_w, i*game.scale+game.offset_h)
			end			
		end
	end
end