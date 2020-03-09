pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

bullets = {}
particles = {}
enemies = {}
scrap_part = {}

player = {
	weapon = 1,
	health = 5,
	peas = 100,
	carrots = 10,
	juice = 5,
	scraps = 40,
	founds = 1,
}

weapons = {
	pea_cd = 0.5,
	pea_ns = 0.5,
	pea_burst_cd = 0.03,
	pea_burst_ns = 0.03,
	pea_do_burst = false,
	pea_burst = 0,
	carrot_cd = 0.85,
	carrot_ns = 0.85,
	juice_cd = 3,
	juice_ns = 0,
	pea_can_shoot = true,
	carrot_can_shoot = true,
	juice_can_shoot = true
}

fly = {
	x = 88,
	y = 64
}

drone = {
	x = 16,
	y = 40,
	moving = 0
}

shop_indicatior = {
	x = 0,
	y = 0,
	cost = 0
}

plant_indicator = {
	pos = 1,
	tp = 1,
	got_space = true
}

build_indicator = {
	pos = 1,
	tp = 1,
	got_space = true
}

weapon_ui = 0
next_spawn = 0
spawn_time = 1

level_info = {
	wave = 0,
	enemies = 20,
	leftover_enemy = 20,
	already_spawned = 0,
	kills = 0,
	clear = false,
	time_between = 8,
	next_in = 20,
	can_spawn = true,
	timer = 0,
	t = 0
}
plants = {}
buildings = {}
state = 0 -- 0 menu, 1 gameplay, 2 help, 3 death screen
shop = 0
help_page = 0

function _init()
	music(0)
	--init_level()
	--add_enemy(10)
	--add_enemy(9)
end

function reset()
	weapon_ui = 0
	next_spawn = 0
	spawn_time = 1
	plants = {}
	level_info.wave = 0
	level_info.enemies = 20
	level_info.leftover_enemy = 20
	level_info.already_spawned = 0
	level_info.kills = 0
	level_info.clear = false
	level_info.time_between = 8
	level_info.next_in = 20
	level_info.can_spawn = true
	level_info.timer = 0
	player.weapon = 1
	player.health = 5
	player.peas = 100
	player.carrots = 10
	player.juice = 5
	player.scraps = 40
	player.founds = 1
	weapons.pea_cd = 0.5
	weapons.pea_ns = 0
	weapons.pea_burst_cd = 0.03
	weapons.pea_burst_ns = 0
	weapons.pea_do_burst = false
	weapons.pea_burst = 0
	weapons.carrot_cd = 0.85
	weapons.carrot_ns = 0
	weapons.juice_cd = 3
	weapons.juice_ns = 0
	weapons.pea_can_shoot = true
	weapons.carrot_can_shoot = true
	weapons.juice_can_shoot = true
	bullets = {}
	particles = {}
	enemies = {}
	scrap_part = {}
end

function init_level()

	if (level_info.wave % 10) == 0 then
		player.health+=1
	end
	menuitem(1,"shop", shop_menu)
	menuitem(2,"plant", plant_menu)
	menuitem(3,"build", build_menu)
	level_info.wave += 1
	level_info.enemies = flr(level_info.wave * (5 + (rnd(8))))
	level_info.leftover_enemy = level_info.enemies
	level_info.clear = false
	level_info.next_in = 5
	level_info.can_spawn = true
	level_info.kills = 0
	level_info.already_spawned = 0
	level_info.timer = 0
end

function shop_menu()
	shop = 1
end

function plant_menu()
	shop = 2
end

function build_menu()
	shop = 3
end

function add_bullet(_x,_y,_tp)
	local speed
	local damage
	if _tp == 1 then
		speed = 4
		damage = 10
	elseif _tp == 2 then
		speed = 3
		damage = 20
	elseif _tp == 3 then
		speed = 3
		damage = 1
	end
	local bullet = {
		x = _x,
		y = _y,
		tp = _tp,
		spd = speed,
		dmg = damage
	}
	add(bullets,bullet)
end

function add_enemy(_type)
	local _sprite
	local sprite_count
	local speed 
	local _hp
	local _anispeed

	if _type == 0 then --burger
		_sprite = 64
		sprite_count = 4
		speed = 0.4
		_anispeed = 4
		_hp = 60
	elseif _type == 1 then --hotdog
		_sprite = 80
		sprite_count = 4
		speed = 0.6
		_anispeed = 6
		_hp = 40
	elseif _type == 2 then --fries
		_sprite = 96
		sprite_count = 4
		speed = 0.8
		_anispeed = 6
		_hp = 20
	elseif _type == 3 then --drumstick
		_sprite = 112
		sprite_count = 4
		speed = 0.55
		_anispeed = 6
		_hp = 50
	elseif _type == 4 then --cola
		_sprite = 68
		sprite_count = 4
		speed = 0.5
		_anispeed = 6
		_hp = 60
	elseif _type == 5 then --fanta
		_sprite = 84
		sprite_count = 4
		speed = 0.7
		_anispeed = 6
		_hp = 40
	elseif _type == 6 then --sprite
		_sprite = 100
		sprite_count = 4
		speed = 0.9
		_anispeed = 6
		_hp = 20
	elseif _type == 7 then --dew
		_sprite = 116
		sprite_count = 4
		speed = 0.45
		_anispeed = 4
		_hp = 50
	elseif _type == 8 then --mcshake
		_sprite = 72
		sprite_count = 4
		speed = 1.1
		_anispeed = 6
		_hp = 10
	elseif _type == 9 then
		_sprite = 104
		sprite_count = 4
		speed = 0.3
		_anispeed = 3
		_hp = 200
	elseif _type == 10 then
		_sprite = 76
		sprite_count = 4
		speed = 0.4
		_anispeed = 3
		_hp = 100
	end


	local enemy = {
		x = 128,
		y = 64,
		tp = _type,
		spd = speed,
		sp = _sprite,
		spr_count = sprite_count,
		animation_speed = _anispeed,
		hp = _hp,
		max_hp = _hp
	}
	add(enemies,enemy)
end

function add_part(_x,_y,_maxage,_color,_type)
	local particle = {
		x = _x,
		y = _y,
		lifetime = 0,
		maxage = _maxage,
		color_range = _color,
		clr = _color[1],
		tpe = _type
	}
	add(particles,particle)
end

function add_plant(_type)
	local _lifetime = 1800
	local _gain = 40
	if _type == 2 then
		lifetime = 1200
		gain = 20
	end
	local plant = {
		tp = _type,
		gain = _gain,
		lifetime = _lifetime,
		max_lifetime = _lifetime
	}
	add(plants,plant)
end

function add_buildplant(_tpye)
local _lifetime = 600
	local dmg = 5
	if _type == 2 then
		lifetime = 1200
		dmg = 10
	end
	local plant = {
		tp = _type,
		dmg = _dmg,
		lifetime = _lifetime,
		max_lifetime = _lifetime
	}
	add(plants,plant)
end

function to_rect(sp,w,h)
 local r = {}
 r.x1 = flr(sp.x * 8)
 r.y1 = sp.y * 8
 r.x2 = flr(sp.x * 8 + w - 1)
 r.y2 = sp.y * 8 + h - 1
 return r
end

function collide_rect(r1,r2)
 if((r1.x1 > r2.x2) or
    (r2.x1 > r1.x2) or
    (r1.y1 > r2.y2) or
    (r2.y1 > r1.y2)) then
  return false
 end
 return true
end

function animate(object,starting_frame,number_of_frames,speed,to_be_flipped)
	if(not object.a_ct) object.a_ct=0
	if(not object.a_st)	object.a_st=0

	object.a_ct+=1

	if(object.a_ct%(30/speed)==0) then

		if (not (object.tp == nil )) and (object.tp == 9) then
			object.a_st+=2
			if(object.a_st==number_of_frames*2) object.a_st=0
		else
			object.a_st+=1
			if(object.a_st==number_of_frames) object.a_st=0
		end
	end

	object.actualframe=starting_frame+object.a_st
	if (not (object.tp == nil )) and (object.tp == 9) then
		spr(object.actualframe,object.x-8,object.y-8,2,2,to_be_flipped)
	elseif (not (object.tp == nil )) and (object.tp == 10) then
		spr(object.actualframe,object.x,object.y-8,1,2,to_be_flipped)
	else
		spr(object.actualframe,object.x,object.y,1,1,to_be_flipped)
	end
	--printh(object.actualframe)
end

function draw_foreground()
	for obj in all(foreground_elements) do
		spr(obj.spr,obj.x,obj.y)
	end
end

log10_table = {
 0, 0.3, 0.475,
 0.6, 0.7, 0.775,
 0.8375, 0.9, 0.95, 1
}

function log10(n)
 if (n < 1) return nil
 local t = 0
 while n > 10 do
  n /= 10
  t += 1
 end
 return log10_table[flr(n)] + t
end

function burst_fire()
	if (weapons.pea_burst < 3) and (time() > weapons.pea_burst_ns) then
		weapons.pea_burst += 1
		add_bullet(16,68,1)
		sfx(3)
	end
	if weapons.pea_burst == 3 then
		weapons.pea_do_burst = false
		weapons.pea_burst = 0
	end
end

function _update()
	if state == 0 then
		update_menu()
	elseif state == 1 then
		update_game()
	elseif state == 2 then
		update_help()
	elseif state == 3 then
	 	update_endscreen()
	end
end

function update_menu()
	cls()
	if btnp(4) then
		sfx(0)
		init_level()
		state = 1
		music(-1)
		enemies = {}
	end
	if btnp(5) then
		sfx(0)
		state = 2
	end
	if rnd() < 0.03 then
		add_enemy(flr(rnd(11)))
	end
	update_enemies()
end

function update_help()
	cls()
	if btnp(4) then
		sfx(0)
		if (help_page < 2) then 
			help_page += 1
		end
	elseif btnp(5) then
		sfx(0)
		help_page -= 1
		if help_page < 0 then
			help_page = 0
			state = 0
		end
	end

end

function update_endscreen()
	cls()
	if btnp(5) then
		reset()
		state = 0
	end
end

function update_game()
	if not (player.health < 0) then
		if shop == 0 then
			cls()
			if not level_info.clear then
				if weapons.pea_do_burst then
					burst_fire()
				end
				if level_info.leftover_enemy == 0 then
					level_info.clear = true
					level_info.next_in = time() + level_info.time_between
				end
				if (time() > next_spawn) and level_info.can_spawn then
					if level_info.enemies > level_info.already_spawned then

						level_info.already_spawned += 1
						next_spawn = time() + spawn_time
						printh((0.1+ (level_info.wave/100)))
						if rnd() < (0.1+ (level_info.wave/100)) then
							if rnd() < 0.5 then
								add_enemy(9)
							else
								add_enemy(10)
							end
						else
							add_enemy(flr(rnd(8)))
						end
					else

						level_info.can_spawn = false
					end
				end
				weapon_ui = 0
				if btnp(4) then
					if player.weapon == 1 then
						
						
						if (player.peas > 0) and (weapons.pea_can_shoot) then
							weapons.pea_do_burst = true
							player.peas -= 3
							weapons.pea_can_shoot = false
						end
					elseif player.weapon == 2 then
						if (player.carrots > 0) and (weapons.carrot_can_shoot)then
							add_bullet(16,68,2)
							add_part(16,68,10,{6,5,1},0)
							add_part(12,68,20,{6,5},2)
							add_part(11,68,20,{6,5},2)
							sfx(1)
							player.carrots -= 1
							weapons.carrot_can_shoot = false
						end
					elseif player.weapon == 3 then
						if (player.juice > 0) and (weapons.juice_can_shoot) then
							add_bullet(16,68,3)
							add_part(16,68,10,{9},0)
							sfx(2)
							player.juice -= 1
							weapons.juice_can_shoot = false
						end
					end
					weapon_ui = 1
				end
				if btnp(3) then
					player.weapon += 1
					if player.weapon > 3 then
						player.weapon = 1
					end
					sfx(0)
				elseif btnp(2) then
					player.weapon -= 1
					if player.weapon < 1 then
						player.weapon = 3
					end
					sfx(0)
				end
				update_particle()
				update_enemies()
				update_bullets()
				--update_drone()
				update_scrap()
				update_plants()
				update_weapon_cooldown()
				level_info.leftover_enemy = level_info.enemies - level_info.kills
				
				--function animate(object,starting_frame,number_of_frames,speed,to_be_flipped)
				--animate(fly,130,4,6,false)
			else
				level_info.timer = flr(level_info.next_in - time())	
				update_particle()
				update_enemies()
				update_bullets()
				--update_drone()
				update_scrap()
				update_plants()
				update_weapon_cooldown()
				if time() > level_info.next_in then
					level_info.clear = false
					level_info.can_spawn = true
					init_level()
				end
			end
		elseif shop == 1 then
			update_shop()
		elseif shop == 2 then
			update_planting()
		else
			update_building()
		end
	else
		level_info.t = time()
		state = 3
	end
end

function update_weapon_cooldown()
		if time() > weapons.pea_burst_ns then
			weapons.pea_burst_ns = time() + weapons.pea_burst_cd
		end

		if time() > weapons.pea_ns then
			weapons.pea_ns = time() + weapons.pea_cd
			weapons.pea_can_shoot = true
		end
		if time() > weapons.carrot_ns then
			weapons.carrot_ns = time() + weapons.carrot_cd
			weapons.carrot_can_shoot = true
		end
		if time() > weapons.juice_ns then
			weapons.juice_ns = time() + weapons.juice_cd
			weapons.juice_can_shoot = true
		end
end

function update_bullets()
	for bullet in all(bullets) do
		if bullet.tp == 1 then
			bullet.x += bullet.spd
			--add_part(bullet.x,bullet.y,3,{9,6,5},1)
			for enemy in all(enemies) do
				if (bullet.x > flr(enemy.x)) then
					enemy.hp -= bullet.dmg
					del(bullets,bullet)
				end
			end
		elseif bullet.tp == 2 then
			bullet.x += bullet.spd
			add_part(bullet.x,bullet.y,10,{11,9,8,2},0)
			for enemy in all(enemies) do
				if (bullet.x > flr(enemy.x)) then
					enemy.hp -= bullet.dmg
					add_part(enemy.x+4,enemy.y+4,15,{10,9,8,2},3)
					for e in all(enemies) do
						if (bullet.x + 10 > enemy.x) then	
							enemy.hp -= bullet.dmg
						end
					end
					del(bullets,bullet)

				end
			end
		elseif bullet.tp == 3 then
			bullet.x += bullet.spd
			bullet.y += 0.1
			add_part(bullet.x,bullet.y,20,{9},1)
			add_part(bullet.x-1,bullet.y,20,{9},1)
			add_part(bullet.x-2,bullet.y,20,{9},1)
			for enemy in all(enemies) do
				if (bullet.x > flr(enemy.x)) then
					enemy.hp -= bullet.dmg
					add_part(enemy.x+4,enemy.y+4,15,{10,9,8,2},4)
				end
			end
			if bullet.x > 150 then
				del(bullets,bullet)
			end
		end
	end
end

function update_particle()
	for particle in all(particles) do
		if particle.tpe == 0 then
			particle.x = particle.x + sin(rnd())
			particle.y = particle.y + cos(rnd())
			particle.lifetime += 1
			if particle.lifetime > particle.maxage then
				del(particles,particle)
			else
				if #particle.color_range == 1 then
					particle.clr = particle.color_range[1]
				else
					local idx = particle.lifetime / particle.maxage
					idx = 1 + flr(idx*#particle.color_range)
					particle.clr = particle.color_range[idx] 
				end
			end
		elseif particle.tpe == 1 then
			particle.lifetime += 1
			if particle.lifetime > particle.maxage then
				del(particles,particle)
			else
				if #particle.color_range == 1 then
					particle.clr = particle.color_range[1]
				else
					local idx = particle.lifetime / particle.maxage
					idx = 1 + flr(idx*#particle.color_range)
					particle.clr = particle.color_range[idx] 
				end
			end
		elseif particle.tpe == 2 then
			particle.lifetime += 1
			if particle.lifetime > particle.maxage then
				del(particles,particle)
			else
				if particle.y > 72 then
					particle.x = particle.x + sin(rnd())
				else
					particle.y += 0.3
				end
			end
		elseif particle.tpe == 3 then
			particle.x = particle.x + sin(rnd())
			particle.y = particle.y + cos(rnd())
			particle.lifetime += 1
			if particle.lifetime > particle.maxage then
				del(particles,particle)
			else
				if #particle.color_range == 1 then
					particle.clr = particle.color_range[1]
				else
					local idx = particle.lifetime / particle.maxage
					idx = 1 + flr(idx*#particle.color_range)
					particle.clr = particle.color_range[idx] 
				end
			end
		elseif particle.tpe == 4 then
			particle.x = particle.x + sin(rnd())
			particle.y = particle.y + cos(rnd())
			particle.lifetime += 1
			if particle.lifetime > particle.maxage then
				del(particles,particle)
			else
				if #particle.color_range == 1 then
					particle.clr = particle.color_range[1]
				else
					local idx = particle.lifetime / particle.maxage
					idx = 1 + flr(idx*#particle.color_range)
					particle.clr = particle.color_range[idx] 
				end
			end
		end
	end
end

function update_enemies()
	local deleted = false
	for enemy in all(enemies) do
		if enemy.hp <= 0 then
			add_part(enemy.x+4,enemy.y+4,15,{3,4,2,1},4)
			add_part(enemy.x+4,enemy.y+4,15,{3,4,2,1},4)
			add_part(enemy.x+4,enemy.y+4,15,{3,4,2,1},4)
			local scr = {
				x = enemy.x + 4,
				y = enemy.y + 4,
				val = flr(enemy.max_hp/20 + (rnd(enemy.max_hp/20)))
			}
			level_info.kills += 1
			add(scrap_part,scr)
			del(enemies,enemy)
			--player.scraps += flr(enemy.max_hp/10 + sin(rnd(2)))
			deleted = true
		end
		if (not deleted) then
			enemy.x -= enemy.spd
	--function animate(object,starting_frame,number_of_frames,speed,to_be_flipped)
			animate(enemy,enemy.sp,enemy.spr_count,enemy.animation_speed,false)
			if enemy.x < 0 then
				level_info.kills += 1
				del(enemies,enemy)
				player.health -= 1
			end
		end
	end
end

function update_drone()
	if btnp(1) then
		drone.moving = 1
		add_part(drone.x,drone.y+4,20,{12,13,5,2},0)
		add_part(drone.x,drone.y+4,20,{12,13,5,2},0)
		drone.x += 0.7
	else
		drone.moving = 0
	end
end

function update_shop()
	local base = 0
	local multiplier = 0
	if btnp(1) then
		sfx(0)
		shop_indicatior.x += 1
		if shop_indicatior.x > 5 then
			shop_indicatior.x = 0
		end
	elseif btnp(0) then
		sfx(0)
	 	shop_indicatior.x -= 1
		if shop_indicatior.x < 0 then
			shop_indicatior.x = 5
		end
	elseif btnp(2) then
		sfx(0)
		shop_indicatior.y -= 1
		if shop_indicatior.y < 0 then
			shop_indicatior.y = 4
		end
	elseif btnp(3) then
		sfx(0)
		shop_indicatior.y += 1
		if shop_indicatior.y > 4 then
			shop_indicatior.y = 0
		end
	end
	if (shop_indicatior.x == 0) base = 1
	if (shop_indicatior.x == 1) base = 2
	if (shop_indicatior.x == 2) base = 5
	if (shop_indicatior.x == 3) base = -1
	if (shop_indicatior.x == 4) base = -2
	if (shop_indicatior.x == 5) base = -5

	if (shop_indicatior.y == 0) multiplier = 1
	if (shop_indicatior.y == 1) multiplier = 5
	if (shop_indicatior.y == 2) multiplier = 10
	if (shop_indicatior.y == 3) multiplier = 20
	if (shop_indicatior.y == 4) multiplier = 50

	shop_indicatior.cost = base * multiplier

	if btnp(4) then
		if shop_indicatior.x < 3 then --buying
			if player.scraps < shop_indicatior.cost then
				sfx(5)
				player.founds = 0
			else
				sfx(6)
				player.founds = 1
				player.scraps -= shop_indicatior.cost
				if shop_indicatior.x == 0 then
					player.peas += multiplier
				elseif shop_indicatior.x == 1 then
					player.carrots += multiplier
				elseif shop_indicatior.x == 2 then
					player.juice += multiplier
				end
			end
		else --selling
			if (shop_indicatior.x == 3) and (player.peas >= multiplier) then
				player.scraps += multiplier
				player.peas -= multiplier
				sfx(6)
			elseif (shop_indicatior.x == 4) and (player.carrots >= multiplier) then
				player.scrsps += multiplier
				player.carrots -= multiplier
				sfx(6)
			elseif (shop_indicatior.x == 5) and (player.juice >= multiplier) then
				player.scraps += multiplier
				player.juice -= multiplier
				sfx(6)
			else
				player.founds = 2
				sfx(5)
			end
		end
	end
	if btnp(5) then
		if (player.founds == 0) or (player.founds == 2) then
			player.founds = 1
		else
			shop = 0
			level_info.next_in = time() + level_info.timer
			player.founds = 1
		end
	end

end

function update_scrap()
	--printh("sajtocska")
	for scrap in all(scrap_part) do
		speed_per_tick = 3
		delta_x = 68 - scrap.x
		delta_y = 84 - scrap.y
		goal_dist = sqrt( (delta_x * delta_x) + (delta_y * delta_y) )
		if (goal_dist > speed_per_tick) then
		    ratio = speed_per_tick / goal_dist
		    x_move = ratio * delta_x  
		    y_move = ratio * delta_y
		    new_x_pos = x_move + scrap.x  
		    new_y_pos = y_move + scrap.y
		else
			sfx(4)
			add_part(scrap.x,scrap.y,10,{15,7,6},3)
			player.scraps += scrap.val
			del(scrap_part,scrap)
		end
		scrap.x = new_x_pos
		scrap.y = new_y_pos
		add_part(scrap.x,scrap.y,10,{3,4,2,1},1)
		add_part(scrap.x+sin(rnd()),scrap.y+sin(rnd()),10,{3,4,2,1},1)
	end
end

function update_plants()
	for i=1,#plants,1 do
		if not (plants[i] == nil) then
			plants[i].lifetime -= 1
			if (plants[i].lifetime == 0) then
				local x
				if i == 1 then
					x = 8
				elseif i == 2 then
				 	x = 32
				elseif i == 3 then
					x = 88
				elseif i == 4 then
					x = 112
				end
				local scr = {
					x = x,
					y = 16,
					val = plants[i].gain
				}
				if plants[i].lifetime < plants[i].max_lifetime * 0.9 then
					add(scrap_part,scr)
				end			
			elseif plants[i].lifetime <= -3 then
				del(plants,plants[i])
			end
		end
	end
	if #plants == 4 then
		plant_indicator.got_space = false
	else
		plant_indicator.got_space = true
	end
end

function update_planting()
	if btnp(1) then
		sfx(0)
		plant_indicator.tp += 1
		if plant_indicator.tp > 2 then
			plant_indicator.tp = 1
		end
	elseif btnp(0) then
		sfx(0)
		plant_indicator.tp -= 1
		if plant_indicator.tp < 1 then
			plant_indicator.tp = 2
		end
	end

	if btnp(5) then
		sfx(0)
		if (player.founds == 0) or (player.founds == 2) then
			player.founds = 1
		else
			shop = 0
			level_info.next_in = time() + level_info.timer
			player.founds = 1
		end
	end

	if btnp(4) then
		--printh(#plants)
		sfx(0)
		if (#plants < 4) then
			if player.scraps < 40/plant_indicator.tp then
				player.founds = 0
				sfx(5)
			else
				if plant_indicator.got_space then
					player.scraps -= 40/plant_indicator.tp
					add_plant(plant_indicator.tp)
					sfx(6)
				else
					sfx(5)
				end
			end
		end
	end
end

function update_building()
	if btnp(1) then
		build_indicator.tp += 1
		if build_indicator.tp > 2 then
			build_indicator.tp = 1
		end
	elseif btnp(0) then
		build_indicator.tp -= 1
		if build_indicator.tp < 1 then
			build_indicator.tp = 2
		end
	end

	if btnp(5) then
		sfx(0)
		if (player.founds == 0) or (player.founds == 2) then
			player.founds = 1
		else
			shop = 0
			level_info.next_in = time() + level_info.timer
			player.founds = 1
		end
	end

	if btnp(4) then
		printh(#plants)
		if (#plants < 4) then
			if player.scraps < 20*build_indicator.tp then
				player.founds = 0
			else
				if build_indicator.got_space then
					player.scraps -= 20*build_indicator.tp
					add_plant(build_indicator.tp)
				end
			end
			sfx(0)
		end
	end
end

function update_plantbuilds()
	for i=1,#plants,1 do
		if not (plants[i] == nil) then
			plants[i].lifetime -= 1
			if (plants[i].lifetime == 0) then
				local x
				if i == 1 then
					x = 8
				elseif i == 2 then
				 	x = 32
				elseif i == 3 then
					x = 88
				elseif i == 4 then
					x = 112
				end
				local scr = {
					x = x,
					y = 16,
					val = plants[i].gain
				}
				if plants[i].lifetime < plants[i].max_lifetime * 0.9 then
					add(scrap_part,scr)
				end			
			elseif plants[i].lifetime <= -3 then
				del(plants,plants[i])
			end
		end
	end
	if #plants == 4 then
		plant_indicator.got_space = false
	else
		plant_indicator.got_space = true
	end
end

function _draw()
	if state == 0 then
		draw_menu()
	elseif state == 1 then
		draw_game()
	elseif state == 2 then
		draw_help()
	elseif state == 3 then
	 	draw_endscreen()
	end
end

function draw_menu()

	map(20,0)
	for i=0,10,1 do
		timer = time() % 1

		if timer < 0.25 then
			spr(192,12,88,13,1)
		elseif (timer  >= 0.25) and (timer < 0.5) then
			spr(208,12,88,13,1)
		elseif (timer  >= 0.5) and (timer < 0.75) then
			spr(224,12,88,13,1)
		elseif (timer  >= 0.75) then
			spr(240,12,88,13,1)
		end
	end
	if timer > 0.5 then
		print("press \142 to play",32,98,2)
	end
		print("press \151 for help",30,106,2)
		print("fantasy console jam #4 - food",6,114,1)
		print("made by: bela toth - achie72",8,122,1)
end

function draw_game()
	if shop == 0 then
		map()
		draw_bullets()
		draw_part()
		draw_player()
		draw_ui()
		--draw_drone()
	elseif shop == 1 then
		draw_shop()
	elseif shop == 2 then
		draw_planting()
	else
		draw_building()
	end
	draw_plants()
end


function draw_player()
	spr(48+player.weapon,8,64)
end

function draw_bullets()
	for bullet in all(bullets) do
		if bullet.tp == 1 then
			pset(bullet.x,bullet.y,11)
		elseif bullet.tp == 2 then
			spr(47,bullet.x,bullet.y-4)
		elseif bullet.tp == 3 then
			pset(bullet.x,bullet.y,12)
		end
	end
end

function draw_part()
	for particle in all(particles) do
		if (particle.tpe == 3) then
			circfill(particle.x, particle.y, rnd(6)+1, particle.clr)
		else
	 		pset(particle.x,particle.y,particle.clr)
		end
	end
end

function draw_ui()
	spr(58+weapon_ui,8,80+(player.weapon*8))

	--health
	for idx=1,player.health,1 do
		if player.health < 5 then
			spr(43,16+(idx*8),80)
		else
			print(" x"..player.health,24,82,8)
		end
	end
	--peas
	for idx=1,player.peas,1 do
		print(" x"..player.peas,24,90,11)
	end

	--carrots
	for idx=1,player.carrots,1 do
		if player.carrots < 14 then
			spr(45,16+(idx*8),96)
		else
			print(" x"..player.carrots,24,98,9)
		end
	end

	--juice
	for idx=1,player.juice,1 do
		if player.juice < 14 then
			spr(46,16+(idx*8),104)
		else
			print(" x"..player.juice,24,106,12)
		end
	end
	--scraps
	print(" x"..player.scraps,72,81,15)

	rectfill(8,116,120,116,1)

	--level indicator
	rectfill(45,0,82,27,1)
	rectfill(46,1,81,26,0)

	print("wave "..level_info.wave,47,2,13)
	print("enemies",47,14,13)
	print(level_info.enemies.."/"..level_info.leftover_enemy,52,20,8)

	--countdown
	if level_info.clear then
		print("next wave in:", 16,120,1)
		if time()%1 > 0.5 then
			print(flr(level_info.next_in - time()),72,120,8)
		end
	end
end

function draw_drone()
	animate(drone,12,4,6,false)
end

function draw_shop()
	if player.founds == 0 then
		rectfill(32,42,96,74,1)
		rectfill(33,43,95,73,0)
		print("not enough",46,44,8)
		print("scraps",54,52,8)

		if time()%1 > 0.5 then
			print("- \151 -",54,63,8)
		end
	elseif player.founds == 2 then
		rectfill(32,42,96,74,1)
		rectfill(33,43,95,73,0)
		print("not enough",46,44,8)
		print("ammo to sell",44,52,8)

		if time()%1 > 0.5 then
			print("- \151 -",54,63,8)
		end
	else
		--frame
		rectfill(24,24,104,112,1)
		rectfill(25,25,103,111,0)
		--headline
		rectfill(24,32,104,32,1)
		if player.scraps > 0 then
			print("scraps:   "..player.scraps,26,26,11)
		else
			print("no scraps",48,26,8)
		end
		--buy/sell
		print("buy",26,34,6)
		print("sell",88,34,6)
		for idx=0,2,1 do
			spr(44+idx,26+(idx*10),42)
		end
		for idx=0,2,1 do
			spr(44+idx,73+(idx*10),42)
		end
		--ammounts
		for idx=0,2,1 do
			print("1",29+(idx*10),52,1)
			print("5",29+(idx*10),60,1)
			print("10",28+(idx*10),68,1)
			print("20",28+(idx*10),76,1)
			print("50",28+(idx*10),84,1)
		end
		for idx=0,2,1 do
			print("1",76+(idx*10),52,1)
			print("5",76+(idx*10),60,1)
			print("10",76+(idx*10),68,1)
			print("20",76+(idx*10),76,1)
			print("50",76+(idx*10),84,1)
		end
		--indicator
		if shop_indicatior.x < 3 then
			spr(59,28+shop_indicatior.x*10,50+shop_indicatior.y*8)
		else
			spr(59,45+shop_indicatior.x*10,50+shop_indicatior.y*8)
		end
		--footer
		rectfill(24,93,104,93,1)
		if shop_indicatior.cost > 0 then
			print("cost:   "..shop_indicatior.cost,26,96,8)
		else
			print("profit:   "..shop_indicatior.cost,26,96,11)
		end
		--controls
		rectfill(24,102,104,102,1)
		print("ok-".."\142",26,105,11)
		print("exit-".."\151",76,105,8)
	end
end

function draw_plants()
	for i=1,#plants,1 do
		local x
		local sprite
		if i == 1 then
			x = 8
		elseif i == 2 then
		 	x = 32
		elseif i == 3 then
			x = 88
		elseif i == 4 then
			x = 112
		end
		if plants[i].lifetime <= (plants[i].max_lifetime * 0.25) then
			if plants[i].tp == 1 then
				sprite = 11
			else
				sprite = 27
			end
		elseif (plants[i].lifetime > (plants[i].lifetime * 0.25)) and (plants[i].lifetime < (plants[i].max_lifetime * 0.5)) then
			if plants[i].tp == 1 then
				sprite = 10
			else
				sprite = 26
			end
		elseif (plants[i].lifetime >= (plants[i].lifetime * 0.5)) and (plants[i].lifetime < (plants[i].max_lifetime * 0.75)) then
			if plants[i].tp == 1 then
				sprite = 9
			else
				sprite = 25
			end
		elseif  plants[i].lifetime >= (plants[i].max_lifetime * 0.75) then
			if plants[i].tp == 1 then
				sprite = 8
			else
				sprite = 24
			end
		end
		spr(sprite,x,16)
	end
end

function draw_planting()

	if player.founds == 0 then
		rectfill(32,42,96,74,1)
		rectfill(33,43,95,73,0)
		print("not enough",46,44,8)
		print("scraps",54,52,8)

		if time()%1 > 0.5 then
			print("- \151 -",54,63,8)
		end
	elseif not plant_indicator.got_space then
		rectfill(32,42,96,74,1)
		rectfill(33,43,95,73,0)
		print("not enough",46,44,8)
		print("space",54,52,8)

		if time()%1 > 0.5 then
			print("- \151 -",54,63,8)
		end
	else
		--frame
		rectfill(24,24,104,112,1)
		rectfill(25,25,103,111,0)
		--headline
		rectfill(24,32,104,32,1)
		if plant_indicator.got_space == false then
			print("no more space",26,26,11)
		else
			if player.scraps > 0 then
				print("scraps:   "..player.scraps,26,26,11)
			else
				print("no scraps",48,26,8)
			end
		end
		print("which to plant",36,34,6)

		--wheat
		spr(11,40,40)
		print("cost 40",26,50,1)
		print("gain 60",26,58,1)
		print("60 sec",26,72,1)
		--carrot
		spr(27,80,40)
		print("cost 20",66,50,1)
		print("gain 30",66,58,1)
		print("40 sec",66,72,1)
		
		if plant_indicator.tp == 1 then
			spr(59,40,40)
		else
			spr(59,80,40)
		end
		--footer
		rectfill(24,93,104,93,1)
		print("cost:   "..40/plant_indicator.tp,26,96,8)
		--controls
		rectfill(24,102,104,102,1)
		print("ok-".."\142",26,105,11)
		print("exit-".."\151",76,105,8)
	end
end

function draw_building()

	if player.founds == 0 then
		rectfill(32,42,96,74,1)
		rectfill(33,43,95,73,0)
		print("not enough",46,44,8)
		print("scraps",54,52,8)

		if time()%1 > 0.5 then
			print("- \151 -",54,63,8)
		end
	elseif not build_indicator.got_space then
		rectfill(32,42,96,74,1)
		rectfill(33,43,95,73,0)
		print("not enough",46,44,8)
		print("space",54,52,8)

		if time()%1 > 0.5 then
			print("- \151 -",54,63,8)
		end
	else
		--frame
		rectfill(24,24,104,112,1)
		rectfill(25,25,103,111,0)
		--headline
		rectfill(24,32,104,32,1)
		if build_indicator.got_space == false then
			print("no more space",26,26,11)
		else
			if player.scraps > 0 then
				print("scraps:   "..player.scraps,26,26,11)
			else
				print("no scraps",48,26,8)
			end
		end
		print("which to build",36,34,6)

		--wheat
		spr(129,40,40)
		print("cost 20",26,50,1)
		print("dmg 5",26,58,1)
		print("40 sec",26,72,1)
		--carrot
		spr(130,80,40)
		print("cost 40",66,50,1)
		print("dmg 10",66,58,1)
		print("20 sec",66,72,1)
		
		if build_indicator.tp == 1 then
			spr(59,40,40)
		else
			spr(59,80,40)
		end
		--footer
		rectfill(24,93,104,93,1)
		print("cost:   "..20*build_indicator.tp,26,96,8)
		--controls
		rectfill(24,102,104,102,1)
		print("ok-".."\142",26,105,11)
		print("exit-".."\151",76,105,8)
	end
end

function draw_help()
	if help_page == 0 then
		print("shoot with \142",0,0,13)
		print("choose weapon with \148/\131", 0, 8, 13) 
		print("selected is indicated by - ",0,16,13)
		spr(59,112,14)
		rectfill(0,26,128,26,1)

		spr(60,0,26)
		print("pea shooter.fast burst weapon",10,28,13)

		spr(61,0,34)
		print("carrot launcher.slow aoe",10,36,13)

		spr(62,0,42)
		print("juice gun. slow, hits all",10,44,13)
		
		rectfill(0,54,128,54,1)

		spr(44,0,56)
		print("ammo for pea shooter",10,58,13)

		spr(45,0,64)
		print("ammor for carrot launcher",10,66,13)


		spr(46,0,72)
		print("ammo for juice gun",10,74,13)

	elseif help_page == 1 then
		print("press enter to acces shops",0,0,13)
		print("in shop displayed in header",0,8,13)
		print("scraps is your currency - ",0,16,13)
		spr(41,104,14)
		rectfill(0,26,128,26,1)
		print("left side buy, right sell",0,28,13)
		print("cost or gain is show in footer",0,36,13)
		print("red is cost, green is gain",0,44,13)
		print("navigate with arrows to choose",0,52,13)
	elseif help_page == 2 then
		print("press enter to acces plants",0,0,13)
		print("plant carrots, or wheat",0,8,13)
		spr(11,104,6)
		spr(27,112,6)

		rectfill(0,18,128,18,1)

		print("you can have four plants atm",0,20,13)
		print("they cost displayed scraps",0,28,13)
		print("and you gain 60/30 back",0,36,13)
		print("when they grow in 60/40 secs",0,44,13)
		print("plant them n gain scrap overtime",0,52,13)
	end
	--footer
	rectfill(0,118,128,118,1)
	print("\151 - back",0,120,11)
	print("\142 - next",92,120,11)
end

function draw_endscreen()
	--frame
	rectfill(24,24,104,112,1)
	rectfill(25,25,103,111,0)
	--headline
	rectfill(24,32,104,32,1)
	print("you are dead",26,26,11)

	print("what you achieved",36,34,6)

	--wheat
	print(player.scraps.."- scraps remained",26,46)
	print(level_info.wave.."- levels_reached",26,54)
	print(level_info.kills.."- fastfood cleared",26,62)
	print(level_info.t,26,70)

	
	print("exit-".."\151",76,105,8)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000606660000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000606660000667b0006066600000000
007007000000000000000000000000000011110000000000000000000000000000000000000000000b0000000a0000a00006667b0000557b0006667b00060666
00077000001011001001011000000000110000110000000000000000000000000000000000000000030000b0090a00a00000557b000505550000557b0000667b
0007700000010011011010010000000100dddd0010000000000000000000000000000000000000b0330b0330990a09900005055500000000000505550000557b
007007000010110010010110000000001d5995d1000000000000000000000000000000000b0b0030030300300909009000000000000000000000000000050555
00000000000100110110100100000011d005500d1100000000000000000000000b00000003030030030330300909909000000000000000000000000000000000
00000000001011dddddddddd00000000d000000d0000000000000000000000000303003003030030030300300909009000000000000000000000000000000000
00100100000100d666dddd660000001d00000000d100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01055010001011d666d00d660000000d00000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10599501000100d6dddddddd0000001d00000000d100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01555510001011d6111001000000000d00000000d00000000000000000000000000000000000000000000000000b000000000000000000000000000000000000
10599501000100d6001001110000001d00000000d100000000000000000000000000000000000000000000000003000000000000000000000000000000000000
01055010001011d6111001000000000d00000000d00000000000000000000000000000000000000000b3000000b3b00000000000000000000000000000000000
00100100000100d6001001110000001d00000000d1000000000000000000000000000000000b00000003b0000003a00000000000000000000000000000000000
00000000001011d6001001000000000d00000000d00000000000000000000000000300000003b000000900000009900000000000000000000000000000000000
00000000000100d6666666660000001d44444444d100000000000000000000000000600000005000088008800000000000000000000bb0000005650000000000
00000000001011d6666666660000000dddddddddd000000000000000000000000055550000888800866888880008800000000000000b00000050005000000000
00000000000100dddddddddd00000011001001001100000000000000000000000577675008ff9f8086888888000880000000b000009990000059005000000000
0000000000101100110101100000000011011011000000000000000000000000000670000009f000088888800888888000b000b0009990000059995003099a00
0000000000010011001010010000000000100100000000000000000000000000000670000009f00008888880088888800000000000999000005999500339a999
000000000010110011010110000000000000000000000000000000000000000005677750089fff800088880000088000000b000000099000005999500009a900
00000000000100110010100100000000000000000000000000000000000000000055550000888800000880000008800000000000000900000059995000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005550000000000
076760000767600007676000076760000000000000000000000000000000000000000000c000000c11000011cc0000cc00000000000000000000000000000000
0777700007777000077770000777700000000000000000000000000000000000000000000000000010000001c000000c00000000000000000000000000000000
0f61f0000f61f0000f61f00b0f61f0000000000000000000000000000000000000000000000000000000000000000000000000000000000b0000000000000000
0ffff0000ffff000555555559ffff050000000000000000000000000000000000000000000000000000000000000000000000000555555559000005000000000
04770000047555555555555595555599000000000000000000000000000000000000000000000000000000000000000000055555555555559555559900000000
04770000047757500477570055775750000000000000000000000000000000000000000000000000000000000000000000005050000050005500505000099000
0074700000640000006400009964000000000000000000000000000000000000000000000000000010000001c000000c000000000000000000000000099ff990
445555004404000044040000440400000000000000000000000000000000000000000000c000000c11000011cc0000cc0000000000000000000000000ff99ff0
00000000000000000000000000000000006666000066660000666600006666000000600000006000000060000000600000000000000000f0033009ff000000ff
00ffff0000ffff0000ffff0000ffff000028280000282800002828000028280000006000000060000000600000006000033009fff33009fff34499fff33009ff
0ffffff00ffffff00ffffff00ffffff00068880000688800006888000068880000555500005555000055550000555500f34499fff34499ffff9933fff34499ff
089989900899899008998990089989900086680000866800008668000086680000898900008989000089890000898900ff9933ffff9933ffff49334fff9933ff
033933300339333003393330033933300088860000888600008886000088860000966900009669000096690000966900ff49334fffffff4ffff9ff4fff49334f
044443400444434004444340044443400088880000888800008888000088880000666600006666000066660000666600fff9ff4f88f88f4f88f88f4f88f88f4f
0ffffff00ffffff00ffffff00ffffff0006666000066660000666600006666000086620000682600002668000062860088f88f4f88f88f4f88f884ff88f88f4f
0ff0044000ff440004400ff00044ff00006005000006500000500600000650000080020000082000002008000002800088f884ff88f884fffffff4ff88f884ff
0004000000f4f00000f4f00000f4f0000066660000666600006666000066660000000000000000000000000000000000fffff4fffffff4fffffff4fffffff4ff
00f4f0000084800000848f00008480000089890000898900008989000089890000000000000000000000000000000000fffff4fffffff4fffffff4fffffff4ff
00848f0000848f0000f4ff0000848f000091190000911900009119000091190000000000000000000000000000000000fffff4fffffff4fffffff4fffffff4ff
00f4ff0000f4ff0000f4ff0000f4ff000016110000161100001611000016110000000000000000000000000000000000fffff4fffffff4ffffff4ff0fffff4ff
00f4ff0000f4ff0000f4ff0000f4ff000061610000616100006161000061610000000000000000000000000000000000ffff4ff0ffff4ff0ffff4ff0ffff4ff0
00f4ff0000f4ff0000f4f00000f4ff000091190000911900009119000091190000000000000000000000000000000000ffff4ff0ffff4ff0fff4ff00ffff4ff0
00f4f00000f0f00000f0f00000f0f0000066660000666600006666000066660000000000000000000000000000000000fff4ff00fff4ff00f44ff000fff4ff00
00f0f0000000000000000000000000000060050000065000005006000005600000000000000000000000000000000000f44ff000f44ff00000000000f44ff000
0000000000000000000000000000000000666600006666000066660000666600007ff7fffff7f7000000000000000000007ff7fffff7f7000000000000000000
00090900000909000009090000090900008181000081810000818100008181000fff7ff7ff7ffff0007ff7fffff7f7000fff7ff7ff7ffff0007ff7fffff7f700
00a9a90000a9a90000a9a90000a9a90000199100001991000019910000199100ff7fff7ff7ff7f7f0fff7ff7ff7ffff0ff7fff7ff7ff7f7f0fff7ff7ff7ffff0
0089a8000089a8000089a8000089a800001963000019630000196300001963009889999999889999ff7fff7ff7ff7f7f9889999999889999ff7fff7ff7ff7f7f
00282800002828000028280000282800003633000036330000363300003633009889999999889999988999999988999998899999998899999889999999889999
00888800008888000088880000888800003333000033330000333300003333004444444444444444988999999988999944444444444444449889999999889999
00888800008888000088880000888800006666000066660000666600006666004444444444444444444444444444444444444444444444444444444444444444
0080020000082000002008000020080000600500000650000050060000056000bbbbbbbbbbbbbbbb4444444444444444bbbbbbbbbbbbbbbb4444444444444444
00000000000fff00000fff00000fff0000666600006666000066660000666600333bbb33b333bbbbbbbbbbbbbbbbbbbb333bbb33b333bbbbbbbbbbbbbbbbbbbb
000fff000000f0000000f0000000f000002b2b00002b2b00002b2b00002b2b004443bb44342433b44443bb44342433b44443bb44342433b44443bb44342433b4
0000f0000000f000000040000000f00000b33b0000b33b0000b33b0000b33b004424344424444244442434442444424444243444244442444424344424444244
0000400000044400000444000004440000388300003883000038830000388300ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00044400000848000048484000084800008bbb00008bbb00008bbb00008bbb000ffffffffffffff00ffffffffffffff00ffffffffffffff00ffffffffffffff0
0048484000484840004444400048484000b3b30000b3b30000b3b30000b3b30000ffffffffffff0000ffffffffffff0000ffffffffffff0000ffffffffffff00
004444400044444000044400004444400066660000666600006666000066660000fff000000444000000ffff4444000000fff00000044400000044444fff0000
000444000004440000000000000444000060050000065000005006000005600000fff000000444000000ffff4444000000fff00000044400000044444fff0000
66dccd66000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66dccd66000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddccddd000000000000000000066000000660000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
111cc10000b00b00060080600038030000b33b000038030000000000000000000000000000000000000000000000000000000000000000000000000000000000
001cc11100038000b308003b0b3773b00bb37bb00b3773b000000000000000000000000000000000000000000000000000000000000000000000000000000000
111cc100b0b00b0bb370873b0b7087b00bb73bb00b7087b000000000000000000000000000000000000000000000000000000000000000000000000000000000
001cc11103833830b733337b0b3333b000b33b000b3333b000000000000000000000000000000000000000000000000000000000000000000000000000000000
001cc100844444430bb44bb000b44b0000b44b0000b44b0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc00cccccc00cccccc001111110011111100111111001111110011111100100000001000010011111100cccccc00cccccc0000000000000000000000000
0c0000c00c0000c00c0000c001000010010000100100001001000010010000100100000001000010010000100c0000c00c0000c0000000000000000000000000
0c0000000c0000000c0000c001000010010000100100001001000000010000100100000001111110010000100c0000000c000000000000000000000000000000
0cccccc00c0000000cccccc001111110011111100100001001000000011111100100000000000010011111100cccccc00cccc000000000000000000000000000
000000c00c0000000cc000000100001001000000010000100100000001000010010000100000001001000000000000c00c000000000000000000000000000000
0c0000c00c0000c00c0cc00001000010010000000100001001000010010000100100001001000010010000000c0000c00c0000c0000000000000000000000000
0cccccc00cccccc00c000cc001000010010000000111111001111110010000100111111001111110010000000cccccc00cccccc0000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110011111100cccccc00cccccc00cccccc00cccccc00cccccc0011111100100000001000010011111100111111001111110000000000000000000000000
01000010010000100c0000c00c0000c00c0000c00c0000c00c0000c0010000100100000001000010010000100100001001000010000000000000000000000000
01000000010000000c0000c00c0000c00c0000c00c0000c00c000000010000100100000001111110010000100100000001000000000000000000000000000000
01111110010000000cccccc00cccccc00cccccc00c0000c00c000000011111100100000000000010011111100111111001111000000000000000000000000000
00000010010000000cc000000c0000c00c0000000c0000c00c000000010000100100001000000010010000000000001001000000000000000000000000000000
01000010010000100c0cc0000c0000c00c0000000c0000c00c0000c0010000100100001001000010010000000100001001000010000000000000000000000000
01111110011111100c000cc00c0000c00c0000000cccccc00cccccc0010000100111111001111110010000000111111001111110000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110011111100111111001111110011111100cccccc00cccccc00cccccc00c0000000c0000c0011111100111111001111110000000000000000000000000
01000010010000100100001001000010010000100c0000c00c0000c00c0000c00c0000000c0000c0010000100100001001000010000000000000000000000000
01000000010000000100001001000010010000100c0000c00c0000000c0000c00c0000000cccccc0010000100100000001000000000000000000000000000000
01111110010000000111111001111110011111100c0000c00c0000000cccccc00c000000000000c0011111100111111001111000000000000000000000000000
00000010010000000110000001000010010000000c0000c00c0000000c0000c00c0000c0000000c0010000000000001001000000000000000000000000000000
01000010010000100101100001000010010000000c0000c00c0000c00c0000c00c0000c00c0000c0010000000100001001000010000000000000000000000000
01111110011111100100011001000010010000000cccccc00cccccc00c0000c00cccccc00cccccc0010000000111111001111110000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc001111110011111100111111001111110011111100111111001111110010000000c0000c00cccccc00cccccc00cccccc0000000000000000000000000
0c0000c001000010010000100100001001000010010000100100001001000010010000000c0000c00c0000c00c0000c00c0000c0000000000000000000000000
0c00000001000000010000100100001001000010010000100100000001000010010000000cccccc00c0000c00c0000000c000000000000000000000000000000
0cccccc00100000001111110011111100111111001000010010000000111111001000000000000c00cccccc00cccccc00cccc000000000000000000000000000
000000c00100000001100000010000100100000001000010010000000100001001000010000000c00c000000000000c00c000000000000000000000000000000
0c0000c001000010010110000100001001000000010000100100001001000010010000100c0000c00c0000000c0000c00c0000c0000000000000000000000000
0cccccc001111110010001100100001001000000011111100111111001000010011111100cccccc00c0000000cccccc00cccccc0000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304050304050000000003040503040500000000030405030405000000000304050304050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300151300150000000013001513001500000000130015130015000000001300151300150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2324252324250000000023242523242500000000232425232425000000002324252324250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000100000100000000010000010000000000000000010000010000000001000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222222122222122222122222122200000000222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002a000000000000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001755017550175501755017550175000350002500015000150001500015000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400000c6700d6700e6700f670106701167012670136701567016670196701b67015670106600a6600866007660066600466003660036500265002650026500264000630006300062000620006100061000600
000100003c4103a42035420314402b4502745025460204601e4601a460184601646013460104600e4600c4600b460094500845007450064400444003430024300143001420004200041000410004000040000400
00010000006701067011670126701367016670186601c6601e6602165024650256402a6402e64032640376403c63038630316302d630256201f6201d6201b6201962017610156101361011610106001060010600
000100000f510125201553017540195401c5401e5402154025540275402a5402b5302e55030550315500050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00010000103500b350083500635003350013500035000350003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100000c3500f350113501235015350173501a3501f350213500a30016300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000655000500035500050006550005000355000500065500050003550005000655000500035500050006550005000355000500065500050003550005000655000500035500050006550005000355000000
01100000000000e050000000e05000000000001f0531f053000000e050000000e05000000000000000000000000000e050000000e05000000000001f0531f053000000e050000000e05000000000000000000000
011000000f0530f0500f0531205012050120530f0530000016053160531605314050140501405300000160530f0530f0500f0531205012050120530f053000001605316053160531405014050140531c00316053
011000001f6531f6531f65300600243532435324353006001f300243531f353000001f3532135324353000001f6531f6531f65300600243532435324353006001f300243531f353000001f353213532435300000
__music__
03 4a4b4c44

