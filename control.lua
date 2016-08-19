local storeinventories = { 
	defines.inventory.player_vehicle,
	defines.inventory.player_armor,
	defines.inventory.player_tools, 
	defines.inventory.player_guns,
	defines.inventory.player_ammo,
	defines.inventory.player_quickbar, 
	defines.inventory.player_main, 
	defines.inventory.player_trash, 
}

local storeinventoriesstring = { 
	"Vehicle",
	"Armor",
	"Tools", 
	"Guns",
	"Ammo",
	"Quickbar",
	"Main", 
	"Trash", 
}

function on_player_died(event)
	local transfered = 0	
	local chestId = 1
	local player = game.players[event.player_index]
	if player ~= nil then
		local playersurface = game.surfaces[player.surface.name]
		if playersurface ~= nil then
			local chestposition = playersurface.find_non_colliding_position("blackbox-chest", player.position, 100, 1)
			if chestposition ~= nil then
				local savechest = playersurface.create_entity({
					name = "blackbox-chest",
					position = chestposition,
					force = game.forces.neutral
				})
				if savechest ~= nil then
					savechest.destructible = false
					local chestitems = 0

					for i = 1, #storeinventories, 1 do
						local inventoryid = storeinventories[i]
						local playerinventory = player.get_inventory(inventoryid)
						if playerinventory ~= nil then
							local chestinventory = savechest.get_inventory(defines.inventory.chest)
							if chestinventory ~= nil then			
								player.print("Storing items from inventory '" .. storeinventoriesstring[i] .. "(" .. tostring(inventoryid) .. ")' to chest #" .. tostring(chestId))
								for j = 1, #playerinventory, 1 do
									if playerinventory[j].valid and playerinventory[j].valid_for_read then
										local item = playerinventory[j]
			
										if storeinventories[i] == defines.inventory.player_guns and item.name == "pistol" then

										else
											if storeinventories[i] == defines.inventory.player_ammo and item.name == "firearm-magazine" then
												if item.count > 10 then
													item.count = item.count - 10
												end
											end
											if chestinventory ~= nill and chestinventory.can_insert(item) then
												chestitems = chestitems + 1
												chestinventory[chestitems].set_stack(item)
												transfered = transfered + 1
											else
												chestposition = playersurface.find_non_colliding_position("blackbox-chest", player.position, 100, 1)
												if chestposition ~= nil then
													savechest = playersurface.create_entity({
														name = "blackbox-chest",
														position = chestposition,
														force = game.forces.neutral
													})
													if savechest ~= nil then
														chestitems = 0
														chestinventory = savechest.get_inventory(1)
														if chestinventory ~= nil then
															chestitems = 1
															chestinventory[chestitems].set_stack(item)
															transfered = transfered + 1
															chestId = chestId + 1
															player.print("Storing items from inventory '" .. storeinventoriesstring[i] .. "(" .. tostring(inventoryid) .. ")' to chest #" .. tostring(chestId))
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end						
					if chestitems == 0 then
						savechest.destroy()
					end
				end
			end
			local maininventory = player.get_inventory(defines.inventory.player_main)
			local toolbar = player.get_inventory(defines.inventory.player_quickbar)
			local queue = player.crafting_queue
			local craftchestId = 1
			local crafttransfered = 0
			if maininventory ~= nil and #queue > 0 then
				chestposition = playersurface.find_non_colliding_position("blackbox-craft-chest", player.position, 100, 1)
				if chestposition ~= nil then
					local savechest = playersurface.create_entity({
						name = "blackbox-craft-chest",
						position = chestposition,
						force = game.forces.neutral
					})
					if savechest ~= nil then
						savechest.destructible = false
						local chestitems = 0
						--[[ canceled craft resources and intermediates are returned to main inventory, except whole products (like pipes, factories, and so on), those are placed to quickbar, if there is space ]]--
						maininventory.clear()
						toolbar.clear()
						chestinventory = savechest.get_inventory(1)
						local cnt = player.crafting_queue_size
						while cnt > 0 do
							local craftitem = queue[cnt]
							player.print("Canceling craft of " .. tostring(craftitem.count) .. " piece(s) of " .. craftitem.recipe .. " , index #" .. tostring(craftitem.index))
							local cancelparam = { index = craftitem.index, count = craftitem.count }
							player.cancel_crafting(cancelparam)
							cnt = player.crafting_queue_size
						end
						maininventory = player.get_inventory(defines.inventory.player_main)
						player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
						for j = 1, #maininventory, 1 do
							if maininventory[j].valid and maininventory[j].valid_for_read then
								local item = maininventory[j]

								if chestinventory ~= nill and chestinventory.can_insert(item) then
									chestitems = chestitems + 1
									chestinventory[chestitems].set_stack(item)
									crafttransfered = crafttransfered + 1
								else
									chestposition = playersurface.find_non_colliding_position("blackbox-craft-chest", player.position, 100, 1)
									if chestposition ~= nil then
										savechest = playersurface.create_entity({
											name = "blackbox-craft-chest",
											position = chestposition,
											force = game.forces.neutral
										})
										if savechest ~= nil then
											chestitems = 0
											chestinventory = savechest.get_inventory(1)
											if chestinventory ~= nil then
												chestitems = 1
												chestinventory[chestitems].set_stack(item)
												crafttransfered = crafttransfered + 1
												craftchestId = craftchestId + 1
												player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
											end
										end
									end
								end
							end
						end
						local toolbar = player.get_inventory(defines.inventory.player_quickbar)
						for j = 1, #toolbar, 1 do
							if toolbar[j].valid and toolbar[j].valid_for_read then
								local item = toolbar[j]

								if chestinventory ~= nill and chestinventory.can_insert(item) then
									chestitems = chestitems + 1
									chestinventory[chestitems].set_stack(item)
									crafttransfered = crafttransfered + 1
								else
									chestposition = playersurface.find_non_colliding_position("blackbox-craft-chest", player.position, 100, 1)
									if chestposition ~= nil then
										savechest = playersurface.create_entity({
											name = "blackbox-craft-chest",
											position = chestposition,
											force = game.forces.neutral
										})
										if savechest ~= nil then
											chestitems = 0
											chestinventory = savechest.get_inventory(1)
											if chestinventory ~= nil then
												chestitems = 1
												chestinventory[chestitems].set_stack(item)
												crafttransfered = crafttransfered + 1
												craftchestId = craftchestId + 1
												player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
											end
										end
									end
								end
							end
						end
					end
				end
				local message = "No  craft queue items were saved"
				if crafttransfered > 0 then
					message = "Saved " .. tostring(crafttransfered) .. " craft queue item(s) into " .. tostring(craftchestId) .. " craft box(es)"
				end
				player.print(message)
			end
		end
	end
	
	local message = "No items were saved"
	if transfered > 0 then
		message = "Saved " .. tostring(transfered) .. " item(s) into " .. tostring(chestId) .. " box(es)"
	end
	player.print(message)
end


script.on_event(defines.events.on_player_died, on_player_died)