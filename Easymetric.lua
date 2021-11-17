-- PREVENT BUG
if not app.activeSprite then
	error("No Active File or Sprite")
end

-- INIT PARAMS IF NOT INSTANCED
if not Easymetric_params then

	Easymetric_params = {}
	Easymetric_params.cubeID = 0
	Easymetric_params.posx = app.activeSprite.width/2
	Easymetric_params.posy = app.activeSprite.height/2

	Easymetric_params.rotmode = true
	Easymetric_params.rotation = 45
	Easymetric_params.rotation2 = "45"
	Easymetric_params.x = 6
	Easymetric_params.y = 6
	Easymetric_params.z = 6

	Easymetric_params.color1 = Color(231, 210, 201, 255)
	Easymetric_params.color2 = Color(165, 152, 183, 255)
	Easymetric_params.color3 = Color(111, 113, 154, 255)
end

function start()
	app.transaction(
	function()

	local dlg = Dialog("Easymetric")

	-- UPDATE PARAMETERS
	function update_params()
		Easymetric_params.posx = dlg.data.posx
		Easymetric_params.posy = dlg.data.posy
		Easymetric_params.rotmode = dlg.data.rotmode
		Easymetric_params.rotation = dlg.data.rotation
		Easymetric_params.rotation2 = dlg.data.rotation2
		Easymetric_params.x = dlg.data.x
		Easymetric_params.y = dlg.data.y
		Easymetric_params.z = dlg.data.z
		Easymetric_params.color1 = dlg.data.color1
		Easymetric_params.color2 = dlg.data.color2
		Easymetric_params.color3 = dlg.data.color3
	end

	-- GENERATE CUBE
	function make_shape()
		local image = app.activeCel.image
		local copy = Image(app.activeSprite.width, app.activeSprite.height)
		local xlen = Easymetric_params.x
		local ylen = Easymetric_params.y
		local zlen = Easymetric_params.z
		local posx = Easymetric_params.posx
		local posy = Easymetric_params.posy
		local rotation = Easymetric_params.rotation + .0
		local rxlen = math.floor(xlen * math.cos(math.rad(rotation-90)))
		local rylen = math.floor(ylen * math.cos(math.rad(rotation)))
		if Easymetric_params.rotmode then
			rotation = tonumber(Easymetric_params.rotation2) + .0
		end

		if rotation > 0 and rotation < 90 then
			local ratio1 = 2*(rotation/45)
			local ratio2 = 2/(rotation/45)
			if rotation > 45 then
				ratio1 = 2/((90-rotation)/45)
				ratio2 = 2*((90-rotation)/45)
			end
			
			local topy = 0
			local boty = 0
			-- FACE TOP
			for x = 0, rxlen + rylen + 1 do
				if x <= rylen then
					topy = posy - x/ratio2 - rxlen/ratio1
				else 
					topy = posy + ((x+1)-rylen)/ratio1 - rylen/ratio2 - rxlen/ratio1
				end
				
				for y = topy, 100 do
					copy:drawPixel(x + posx - rxlen - 1, y, Color(255, 0, 0, 128))
				end
			end
			
			-- FACE LEFT
			for x = 1, rxlen+1 do
				for z = 1, zlen+1 do
					copy:drawPixel(-(x-1) + posx - 1, z + posy - x/ratio1, Easymetric_params.color2)
				end
			end
			
			-- FACE RIGHT
			for y = 1, rylen+1 do
				for z = 1, zlen+1 do
					copy:drawPixel((y-1) + posx, z + posy - y/ratio2, Easymetric_params.color3)
				end
			end
			
		end


		app.activeCel.image:drawImage(copy)
		app.refresh()
	end

	function update()
		update_params()
		make_shape()
	end

	function change_rotmode()
		if dlg.data.rotmode then
			dlg:modify{id="rotation", visible=false}
			dlg:modify{id="rotation2", visible=true}
		else
			dlg:modify{id="rotation", visible=true, value=tonumber(dlg.data.rotation2)}
			dlg:modify{id="rotation2", visible=false}
		end
		update()
	end

	function new_layer()
		-- INIT LAYER & PREVIEW
		Easymetric_params.cubeID = Easymetric_params.cubeID + 1
		local p1 = {0, 0}
		local p2 = {app.activeSprite.width, app.activeSprite.height}
		app.transaction( function()
			app.command.NewLayer()
			app.activeLayer.name = "Cube " .. Easymetric_params.cubeID
			app.useTool{
				tool="line",
				color=Color(255, 0, 255, 255),
				brush=Brush(1),
				points={p1, p2}
			}
			app.refresh()
			make_shape()
			end )
	end
	
	function generate()
		new_layer()
	end

	new_layer()
	
	-- CREATE DIALOG
	dlg:separator("Position")
	dlg:slider{id="posx", label="X Y", min=0, max=app.activeSprite.width, value=Easymetric_params.posx, onchange=update}
	dlg:slider{id="posy", min=0, max=app.activeSprite.height, value=Easymetric_params.posy, onchange=update}

	dlg:separator("Rotation")
	dlg:radio{id="rotmode", label="Mode", text="Essentials", selected=Easymetric_params.rotmode, onclick=function() change_rotmode() end}
	dlg:radio{id="rotmode2", text="Slider", selected=not Easymetric_params.rotmode, onclick=function() change_rotmode() end}
	dlg:combobox{id="rotation2", label="Rotation", option=Easymetric_params.rotation2, options={"0","11.25","22.5","45","67.5","78.75","90"}, onchange=update, visible=Easymetric_params.rotmode}
	dlg:slider{id="rotation", label="Rotation", min=0, max=90, value=Easymetric_params.rotation, onchange=update, visible=not Easymetric_params.rotmode}
				  
	dlg:separator("Size")
	dlg:slider{id="x", label="X Y Z", min=0, max=app.activeSprite.width / 2, value=Easymetric_params.x, onchange=update}
	dlg:slider{id="y", min=0, max=app.activeSprite.width / 2, value=Easymetric_params.y, onchange=update}
	dlg:slider{id="z", min=0, max=app.activeSprite.height / 2, value=Easymetric_params.z, onchange=update}

	dlg:separator("Colors")
	dlg:color {id = "color1", color = Easymetric_params.color1, onchange=update}
	dlg:color {id = "color2", color = Easymetric_params.color2, onchange=update}
	dlg:color {id = "color3", color = Easymetric_params.color3, onchange=update}

	dlg:separator()
	dlg:button{text="Generate",onclick=generate}
	dlg:show()
	
	app.command.RemoveLayer()
	Easymetric_params.cubeID = Easymetric_params.cubeID - 1
	
	end)
end

start()