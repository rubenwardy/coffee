


--
-- Formspecs
--

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("fuel") and inv:is_empty("dst") and inv:is_empty("src")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local inactive_formspec =
	"size[8,8.5]" ..
	--default.gui_bg or "" ..
	--default.gui_bg_img or "" ..
	--default.gui_slots or "" ..
	"list[current_name;src;2.75,0.5;1,1;]" ..
	--"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]" ..
	"list[current_name;dst;4.75,0.96;2,2;]" ..
	"list[current_player;main;0,4.25;8,1;]" ..
	"list[current_player;main;0,5.5;8,3;8]" ..
	"listring[current_name;dst]" ..
	"listring[current_player;main]" ..
	"listring[current_name;src]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0, 4.25)

minetest.register_node("coffee:espresso_machine", {
	-- General definitions
	description = "Espresso Machine",
	groups = {snappy=3},
	sounds = default.node_sound_stone_defaults(),

	-- Drawtype and shape
	tiles = {"default_stone.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.25, -0.3125, 0.5, 0.5, 0.5}, -- top
			{-0.5, -0.25, 0.125, 0.5, 0.25, 0.5}, -- back
			{-0.5, -0.5, -0.3125, 0.5, -0.25, 0.5}, -- base
			{-0.375, 0.125, -0.1875, 0.25, 0.25, 0.125}, -- attached
			{-0.0625, 0.0625, -0.5, 0.0625, 0.1875, 0.0625}, -- handle
			{-0.1875, 0, -0.125, -0.0625, 0.125, 0}, -- spout_left
			{0.0625, 0, -0.125, 0.1875, 0.125, 0}, -- spout_right
		}
	},

	-- Actions and Callbacks
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec)
	end,
})

--
-- Ingredients
--

food.support("milk", {
	"animalmaterials:milk",
	"my_mobs:milk_glass_cup",
	"jkanimals:bucket_milk",
	"mobs:bucket_milk"
})

food.module("milk", function()
	minetest.register_craftitem(":food:milk", {
		description = "Milk",
		image = "food_milk.png",
		on_use = food.item_eat(1),
		groups = { eatable=1, food_milk = 1 },
		stack_max=10
	})
	food.craft({
		output = "food:milk",
		recipe = {
			{"default:sand"},
			{"bucket:bucket_water"}
		},
		replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}},
	})
end, true)

food.module("coffee_bean", function()
	minetest.register_craftitem("coffee:bean", {
		description = "Coffee Bean",
		inventory_image = "coffee_bean.png",
		groups = { food_coffee_bean=1 }
	})
end, true)

food.module("steamed_milk", function()
	minetest.register_craftitem("coffee:steamed_milk", {
		description = "Steamed Milk",
		inventory_image = "coffee_steamed_milk.png"
	})

	minetest.register_craft({
		type = "cooking",
		output = "coffee:steamed_milk",
		recipe = "group:food_milk",
		cooktime = 3,
	})
end)


--
-- Drinks
--


food.module("espresso", function()
	minetest.register_craftitem("coffee:espresso", {
		description = "Espresso",
		inventory_image = "coffee_espresso.png",
		groups = { coffee=1, food_coffee=1, food_espresso=1, food_espresso_single=1 }
	})
end)

food.module("espresso_doppio", function()
	minetest.register_craftitem("coffee:espresso_doppio", {
		description = "Espresso Doppio (Double Espresso)",
		inventory_image = "coffee_espresso_doppio.png",
		groups = { coffee=1, food_coffee=1, food_espresso=1, food_espresso_doppio=1 }
	})

	minetest.register_craft({
		type = "shapeless",
		output = "coffee:espresso_doppio",
		recipe = {
			"coffee:espresso 2"
		}
	})
end)

food.module("latte", function()
	minetest.register_craftitem("coffee:latte", {
		description = "Latte",
		inventory_image = "coffee_latte.png",
		groups = { coffee=1, food_latte=1 }
	})

	minetest.register_craft({
		output = "coffee:latte",
		recipe = {
			{"coffee:steamed_milk"},
			{"coffee:espresso_doppio"},
			{"vessels:drinking_glass"},
		}
	})

	minetest.register_craft({
		output = "coffee:latte",
		recipe = {
			{"coffee:steamed_milk", ""},
			{"coffee:espresso", "coffee:espresso"},
			{"vessels:drinking_glass", ""},
		}
	})

	minetest.register_craft({
		output = "coffee:latte",
		recipe = {
			{"", "coffee:steamed_milk"},
			{"coffee:espresso", "coffee:espresso"},
			{"", "vessels:drinking_glass"},
		}
	})

	minetest.register_craft({
		output = "coffee:latte",
		recipe = {
			{"", "coffee:steamed_milk", ""},
			{"coffee:espresso", "", "coffee:espresso"},
			{"", "vessels:drinking_glass", ""},
		}
	})
end)


--
-- ABM
--

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

minetest.register_abm({
	nodenames = {"coffee:espresso_machine"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node)
		-- Get metadata
		local meta = minetest.get_meta(pos)
		local cook_time = meta:get_float("cook_time") or 0
		meta:set_string("formspec", inactive_formspec)

		-- Initialise inventory
		local inv = meta:get_inventory()
		for listname, size in pairs({
				src = 1,
				dst = 4
		}) do
			if inv:get_size(listname) ~= size then
				inv:set_size(listname, size)
			end
		end

		-- Check whether there's enough beans
		if inv:contains_item("src", ItemStack("coffee:bean 3")) then
			meta:set_string("infotext", "Making espresso")
			meta:set_float("cook_time", cook_time + 1)
		else
			meta:set_string("infotext", "Out of coffee beans")
			meta:set_float("cook_time", 0)
			return
		end

		-- Time to cook
		-- WARNING: cook_time is taken from before it was set above
		if cook_time < 1 then
			return
		end

		-- Create espresso
		inv:remove_item("src", ItemStack("coffee:bean 3"))
		local is = ItemStack("coffee:espresso")
		local remainder = inv:add_item("dst", is)
		if remainder:get_count() > 0 then
			minetest.spawn_item({
					x = pos.x,
					y = pos.y + 1,
					z = pos.z
				}, remainder)
		end

		-- Check for remaining beans
		meta:set_float("cook_time", 0)
		if not inv:contains_item("src", ItemStack("coffee:bean 3")) then
			meta:set_string("infotext", "Out of coffee beans")
			return
		end
	end
})
