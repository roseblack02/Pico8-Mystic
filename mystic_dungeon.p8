pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--main tab
function _init()
	music(4,0,11)
	--frame counter
	frame=0
	--mode
	mode="start"
	--menu screen
	--stars
	star_x,star_y={},{}
	for i=1,10 do
		add(star_x,rnd(128))
		add(star_y,rnd(90))
	end
	cloud_x=0
	--class select screen
	class_y,radius,draw_in_circ=0,100
	--map
	show_map=false
	--end screen
	height=-5
	--direction
	north,east,south,west=true
	--walls to draw
	front,right,left,dist_front,dist_right,dist_left,furth_front,furth_right,furth_left=false
	--pickup items and ladder
	item_y,rand_item,health_item,mp_item,ladder,power_item=30
	--enemy encounter
	encounter,imp_encounter,slime_encounter,skeleton_encounter,ghost_encounter,troll_encounter,snake_encounter,flatwoods_encounter=false
	--player stats
	counter,counter_colour,max_health,health,max_mp,mp,power,floor,points,class=0,12,50,50,40,40,1.1,0,0,""
	--objects
	game_objects={}
	--particles
	particle={}
end

function _update()
	if mode=="start" then
		update_start()
	elseif mode=="class" then
		update_class()
	elseif mode=="game" then
		update_game()
	elseif mode=="end" then
		update_end()
	end

	frame_counter(60)
end

function _draw()
	if mode=="start" then
		draw_start()
	elseif mode=="class" then
		draw_class()
	elseif mode=="game" then
		draw_game()
	elseif mode=="end" then
		draw_end()
	end
end
-->8
--states
function update_start()
	--colours
	pal({1,2,-13,-3,-11,-10,7,8,9,10,-15,12,13,14,-14},1)

	if (btnp(5)) mode="class" sfx(2) radius=100 draw_in_circ=false

	--move clouds
	cloud_x+=0.2
	--loop clouds
	if cloud_x>130 then
		cloud_x=-25
	end
end

function draw_start()
	cls(11)
	sky(cloud_x)
	--title text
	spr(128,13,12,13,8)
	--border
	spr(141,5,3,2,1)
	rectfill(21,5,103,7,13)
	rectfill(21,8,103,9,4)
	spr(157,103,3,2,1)

	spr(141,5,76,2,1)
	rectfill(21,78,103,80,13)
	rectfill(21,81,103,82,4)
	spr(157,103,76,2,1)
	
	print("press ❎ to start",30,100,text_flash({7,15}))
end

function update_class()
	if btnp(5) then
		sfx(13)

		if class_y==2 then
			class="bm"
		elseif class_y==22 then
			class="m"
		elseif class_y==42 then
			class="f"
		else
			class="k"
		end

		draw_in_circ=true
	end

	--decrease radius of circle to draw it in
	if draw_in_circ then
		radius-=2.5
		radius=mid(0,radius,100)
	end

	--start game when circle is closed
	if radius<1 then
		start_game() 
		mode="game"
	end

	--move cursour
	if (btnp(2)) class_y-=20

	if (btnp(3)) class_y+=20

	class_y=mid(2,class_y,62)

	--move clouds
	cloud_x+=0.2
	--loop clouds
	if cloud_x>130 then
		cloud_x=-25
	end


end

function draw_class()
	cls(11)
	sky(cloud_x)
	--classes
	rectfill(18,2,109,18,1)
	rect(18,2,109,18,6)
	spr(121,22,6)
	print("battlemage",32,5,7)
	print("50hp, 40mp, 12power",32,11,7)

	rectfill(18,22,109,38,1)
	rect(18,22,109,38,6)
	spr(122,22,26)
	print("mage",32,25,7)
	print("35hp, 50mp, 12power",32,31,7)

	rectfill(18,42,109,58,1)
	rect(18,42,109,58,6)
	spr(123,22,46)
	print("fighter",32,45,7)
	print("40hp, 30mp, 16power",32,51,7)

	rectfill(18,62,109,78,1)
	rect(18,62,109,78,6)
	spr(124,22,66)
	print("knight",32,65,7)
	print("55hp, 35mp, 11power",32,71,7)

	--cursor
	rect(18,class_y,109,class_y+16,7)
	
	print("press ❎ to select",28,100,text_flash({7,15}))

	circle_draw(64,64,radius)
end

function start_game()
	music(0,0,11)
	--colours
	pal({1,2,3,-3,-11,-10,7,8,9,10,-15,12,13,14,-14},1)
	--remove old objects and recreate
	remove(game_objects)
	make_slime()
	make_skeleton()
	make_flatwoods()
	make_ghost()
	make_snake()
	make_troll()
	make_imp()
	make_player()
	--generate map
	random_map()
	--reset stats
	--enemy encounter
	encounter,imp_encounter,slime_encounter,skeleton_encounter,ghost_encounter,troll_encounter,snake_encounter,flatwoods_encounter=false,false,false,false,false,false,false,false
	--player stats
	counter,counter_colour,floor,points=0,12,0,0
	--changhe stats based on class
	if class=="bm" then
		max_health,max_mp,power=50,40,1.2
	elseif class=="m" then
		max_health,max_mp,power=35,50,1.2
	elseif class=="f" then
		max_health,max_mp,power=40,30,1.6
	else
		max_health,max_mp,power=55,35,1.1
	end
	health,mp=max_health,max_mp
end

function update_game()
	local obj
	for obj in all(game_objects)do
		obj:update()
	end

	--bob rand_item sprite
	if (rand_item) or (health_item) or (mp_item) or (power_item) then
		if frame>29 then 
			item_y+=0.4
		else item_y-=0.4

		end 
		item_y=mid(30,item_y,33)
	end

	--change counter colour
	if counter < 3 then
		counter_colour=12
	elseif counter >=3 and counter < 6 then
		counter_colour=9
	else
		counter_colour=8
	end

	--limit health
	health,max_health=mid(0,health,max_health),mid(0,max_health,100)

	--limit mp
	mp,max_mp=mid(0,mp,max_mp),mid(0,max_mp,75)

	--limit points
	points=mid(0,points,999)

	--games ends when health is 0
	if( health<1 ) mode="end" height=-5 sfx(14) music(8,0,7)
end

function draw_game()
	cls(11)
	--show map if map is open
	if show_map then
		map(map_x,map_y)
	--else show game
	else
		--floor
		rectfill(0,59,128,128,4)

		--further walls
		if (furth_front and not dist_front) rectfill(0,42,128,59,15)

		if (furth_left and not dist_front) wall_furth_left()

		if (furth_right and not dist_front) wall_furth_right()

		--distant walls
		if (dist_front) rectfill(0,38,128,63,5)

		if (dist_left) wall_dist_left()
		

		if (dist_right) wall_dist_right()
		
		--draw walls
		if (front) rectfill(0,30,128,71,6)
		
		if (left) wall_left()
		
		if (right) wall_right()

		--ladder
		if (ladder) circfill(50,87,5,15) rectfill(53,82,75,92,15) circfill(78,87,5,15) spr(46,48,58,2,2) spr(46,64,58,2,2,true) spr(46,48,58+16,2,2,false,true) spr(46,64,58+16,2,2,true,true)--draw_ladder()

		--items
		--dont show in encounters
		--rand_item
		if (rand_item and not ecounter) circfill(60,87,5,5)rectfill(63,82,65,92,5)circfill(68,87,5,5)spr(68,48,item_y,4,4)	

		if (health_item and not ecounter) circfill(60,87,5,5) rectfill(63,82,65,92,5) circfill(68,87,5,5) spr(4,48,item_y,4,4)	
	
		if (mp_item and not ecounter) circfill(60,87,5,5) rectfill(63,82,65,92,5) circfill(68,87,5,5) spr(8,48,item_y,4,4)	

		if (power_item and not ecounter) circfill(60,87,5,5) rectfill(63,82,65,92,5) circfill(68,87,5,5) spr(64,48,item_y,4,4)	
	
	end

	local obj
	for obj in all(game_objects)do
		obj:draw()
	end
end

function update_end()
	--make blood poor down
	height+=0.75
	height=mid(-5,height,128)

	--only allow exit after blood pours
	if height==128 then
		--back to main menu
		if (btnp(5)) mode="start" sfx(2) music(4,0,11)
	end
end

function draw_end()
	--blood pours then display info
	if height<128 then
		blood()
	else
		cls(11)
		--border
		spr(141,5,10,2,1)
		rectfill(21,12,103,14,13)
		rectfill(21,15,103,16,4)
		spr(157,103,10,2,1)

		spr(141,5,54,2,1)
		rectfill(21,56,103,58,13)
		rectfill(21,59,103,60,4)
		spr(157,103,54,2,1)

		--game stats
		print("you died",48,25,4)
		print("you died",48,24,13)
		print("points: "..points,42,35,4)
		print("points: "..points,42,34,13)
		print("floor: "..floor,46,45,4)
		print("floor: "..floor,46,44,13)

		print("press ❎ to restart",26,100,text_flash({7,15}))
	end
end

-->8
--objects
--from bridgs
function make_game_object(name,x,y,props)
	local obj={
		name=name,
		x=0 or x,
		y=0 or y,
		velocity_x=0,
		velocity_y=0,
		health=0,
		max_health=0,
		damage=0,
		strike=false,
		fire=false,
		ice=false,
		rock=false,
		update=function(self)
		end,
		draw=function(self)
		end,
		take_damage=function(self,strike,fire,ice,rock)
			for_each_game_object("player",function(player)
				--check for turn type
				if player.strike then
					--take damage
					self.damage_taken=strike*power
					self.health-=self.damage_taken
					self.strike=true
					explosion(50+rnd(10),40)

					player.strike=false
				elseif player.fire then
					--take damage
					self.damage_taken=fire*power
					self.health-=self.damage_taken
					self.fire=true
					explosion(50+rnd(10),40)

					player.fire=false
				elseif player.ice then
					--take damage
					self.damage_taken=ice*power
					self.health-=self.damage_taken
					self.ice=true
					explosion(50+rnd(10),40)

					player.ice=false
				elseif player.rock then
					--take damage
					self.damage_taken=rock*power
					self.health-=self.damage_taken
					self.rock=true
					explosion(50+rnd(10),40)

					player.rock=false
				end

				--enemy turn
				if not (player.turn) and not (self.turn) then
					self.turn_timer+=60 
					self.turn=true
				end
				
			end)
		end,
		deal_damage=function(self,dmg)
			--enemy turn
			if self.turn then
				if self.turn_timer<30 then
					for_each_game_object("player",function(player)
						--reset damage taken
						self.damage_taken,self.fire,self.ice,self.strike,self.rock=0,false,false,false,false

						--random damage amount
						local random = flr(rnd(9))

						if random < 3 then
							--miss
							sfx(09)
							self.miss=true

						elseif random >= 3 and random >8 then
							--normal hit
							health-=dmg
							sfx(10)
							self.miss=false

						else
							--crit
							health-=dmg*2
							sfx(10)
							self.miss=false

						end

						--end turn
						self.turn=false
						player.turn=true
					end)
				end
			end
		end,
		display_damage=function(self)
			--display damage
			if self.turn_timer>30 then
				print("-".. flr(self.damage_taken),90,5,7)

				--particle effects
				if self.fire then
					draw_explosion({2,8,9,10})
				elseif self.ice then
					draw_explosion({13,12,12,7})
				elseif self.strike or self.rock then
					draw_explosion({5,5,6,7})
				end
			elseif self.turn_timer<30 and self.turn_timer>0 then
				--if hit player or missed
				if self.miss then
					print("miss!",3,23,7)
				else
					print("hit!",3,23,7)

					--screen shake
					screen_shake(0.2)
				end
			else
				camera(0,0)
			end

			--health bar
			rect(62-(self.max_health/2),72,65+(self.max_health/2),76,1)
			rectfill(63-(self.max_health/2),73,64+(self.max_health/2),75,5)
			rectfill(63-(self.max_health/2),73,64-(self.max_health/2)+(self.health),75,8)
		end,
		bob=function(self)
			if frame>29 then
				self.y+=0.3
			else
				self.y-=0.3
			end

			--limit y
			self.y=mid(0,self.y,3)
		end,
		enemy_turn_timer=function(self)
			--limit health
			self.health=mid(0,self.health,self.max_health)

			--count down time for enemy turn and limit
			self.turn_timer-=1
			self.turn_timer=mid(0,self.turn_timer,60)
		end,
		enemy_stats_reset=function(self)
			--reset stats
			self.damage_taken,self.health,self.fire,self.ice,self.strike,self.rock,self.turn=0,self.max_health,false,false,false,false,false
		end,
		enemy_increase_stats=function(self)
			--increase difficulty
			self.max_health*=(1+(floor/30))
			self.health=self.max_health
			self.damage*=(1+(floor/50))
			--limit hp
			self.max_health=mid(1,self.max_health,120)
		end,
		player_count_down_message=function(self)
			self.message_timer-=1
			self.message_timer=mid(0,self.message_timer,60)
		end
	}
	local key,value
	for key,value in pairs(props) do
		obj[key]=value
	end
	add(game_objects,obj)
	return obj
end

--player
function make_player(x,y)
	return make_game_object("player",x,y,{
		width=8,
		height=8,
		move_speed=8,
		sprite=1,
		cursor_x=5,
		cursor_y=86,
		turn=false,
		power_up=false,
		health_up=false,
		mp_up=false,
		debuff=false,
		message_timer=0,
		update=function(self)
			--friction
			self.velocity_x*=0
			self.velocity_y*=0

			--only move if map not open
			--or if not in encounter
			if not show_map and not encounter then
				--turn left
				if btnp(0) then
					sfx(1)

					if north then
						north=false
						west=true
					elseif west then
						west=false
						south=true
					elseif south then
						south=false
						east=true
					else
						east=false
						north=true
					end
				end
				--turn right
				if btnp(1) then
					sfx(1)
					
					if north then
						north=false
						east=true
					elseif west then
						west=false
						north=true
					elseif south then
						south=false
						west=true
					else
						east=false
						south=true
					end
				end
				--move forward
				if btnp(2) then
					sfx(0)
					
					--move based off of direction
					if north then
						self.velocity_y=-self.move_speed
					elseif south then
						self.velocity_y=self.move_speed
					elseif west then
						self.velocity_x=-self.move_speed
					else
						self.velocity_x=self.move_speed
					end
					--regenerate mp
					mp+=1.5
					mp=mid(0,mp,max_mp)
					--add to walk counter
					counter+=1
					--limit counter
					counter = mid(0,counter,9)
					--70% chance for an enemy encounter if counter is at 9
					if counter == 9 then
						--random num
						local random = flr(rnd(9))
						if random > 2 then
							--start encounter
							encounter=true
							--choose enemy
							local random_enemy = flr(rnd(11))
							if random_enemy < 3 then
								slime_encounter=true
							elseif random_enemy >= 3 and random_enemy < 5 then
								skeleton_encounter=true
							elseif random_enemy == 5 then
								ghost_encounter=true
							elseif random_enemy >= 6 and random_enemy <8 then
								troll_encounter=true
							elseif random_enemy == 8 then
								flatwoods_encounter=true
							elseif random_enemy ==9 then
								imp_encounter=true
							else
								snake_encounter=true
							end
							--reset counter
							counter=0
							--start players turn
							self.turn=true
						end
					end
				end
				--turn back
				if btnp(3) then
					sfx(1)
					
					if north then
						north=false
						south=true
					elseif west then
						west=false
						east=true
					elseif south then
						south=false
						north=true
					else
						east=false
						west=true
					end
				end
			elseif encounter then
				--move cursor
				--left
				if btnp(0) then
					self.cursor_x -= 60
				end

				--right
				if btnp(1) then
					self.cursor_x += 60
				end

				--up
				if btnp(2) then
					self.cursor_y -= 16
				end

				--down
				if btnp(3) then
					self.cursor_y += 16
				end

				--limit cursor
				self.cursor_x = mid(5,self.cursor_x,65)
				self.cursor_y = mid(86,self.cursor_y,102)

				--run
				if btnp(4) and self.turn then
					--10% to successfully run away
					local random = flr(rnd(9))

					if random < 2 then
						encounter,imp_encounter,slime_encounter,skeleton_encounter,ghost_encounter,troll_encounter,snake_encounter,flatwoods_encounter=false,false,false,false,false,false,false,false
						sfx(8)
					end

					--end turn
					self.turn = false
				end

				--action
				--only if on players turn
				if btnp(5) and self.turn then
					--use coords to get move
					if self.cursor_x == 5 and self.cursor_y == 86 then
						--do move
						self.strike=true
						sfx(04)

						--end turn
						self.turn=false
					elseif self.cursor_x == 65 and self.cursor_y == 86 and mp>=15 then
						--do move
						self.fire=true
						sfx(05)
						mp-=15

						--end turn
						self.turn=false
					elseif self.cursor_x == 5 and self.cursor_y == 102 and mp>=10 then
						--do move
						self.ice=true
						sfx(06)
						mp-=10

						--end turn
						self.turn=false
					elseif self.cursor_x == 65 and self.cursor_y == 102 and mp>=10 then
						--do move
						self.rock=true
						sfx(07)
						mp-=10

						--end turn
						self.turn=false
					end
				end
			end
			
			--show map
			--only open map if not in ecounter
			if not encounter then
				if btnp(5) then
					if show_map then
						sfx(3)
						show_map=false
					else
						sfx(2)
						show_map=true
					end
				end
			end
			

			--limiting velocity
			self.velocity_x=mid(-8,self.velocity_x,8)
			self.velocity_y=mid(-8,self.velocity_y,8)
			
			--map collision
			local collision=hit_wall(self.x+self.velocity_x,self.y+self.velocity_y,self.width,self.height,4)
			if collision~="none" then
				--no movement
				--screen shake
				screen_shake(0.1)
				sfx(04)
			else
				--applying velocity
				self.x+=self.velocity_x
				self.y+=self.velocity_y
				camera(0,0)
			end

			--pick up rand_item item
			if check_tile(self.x,self.y,1) then
				sfx(12)
				--add to message timer
				self.message_timer=60
				--randomly choose item
				local random=flr(rnd(11))

				if random<5 then
					power+=0.25
					--booleans for popup message
					self.power_up=true
				elseif random<8 then
					health+=10
					max_health+=10
					self.health_up=true
				elseif random<10 then
					mp+=5
					max_mp+=5
					self.mp_up=true
				else
					--choose random debuff
					local random_debuff=flr(rnd(4)) 
					if random_debuff <= 1 then
						power-=0.2
					elseif random_debuff<=2 then
						max_health-=5
					else
						mp-=5
					end
					self.debuff=true
				end

				--get tile coords
			 	--set tile to normal floor
			 	mset(self.x/8,self.y/8,18)
			else
				--count down message timer and limit
				self:player_count_down_message()
			end

			--pick up health_item item
			if check_tile(self.x,self.y,3) then
				sfx(12)
				health+=10
				max_health+=5
				self.health_up=true
				--add to message timer
				self.message_timer=60
				--get tile coords
			 	--set tile to normal floor
			 	mset(self.x/8,self.y/8,18)
			else
				self:player_count_down_message()
			end

			--pick up mp_item item
			if check_tile(self.x,self.y,4) then
				sfx(12)
				mp+=5
				max_mp+=3
				self.mp_up=true
				--add to message timer
				self.message_timer=60
				--get tile coords
			 	--set tile to normal floor
			 	mset(self.x/8,self.y/8,18)
			else
				self:player_count_down_message()
			end

			--pick up power_item item
			if check_tile(self.x,self.y,5) then
				sfx(12)
				power+=0.1
				--booleans for popup message
				self.power_up=true
				--add to message timer
				self.message_timer=60
				--get tile coords
			 	--set tile to normal floor
			 	mset(self.x/8,self.y/8,18)
			else
				self:player_count_down_message()
			end

			if self.message_timer<1 then
				--close messages
				self.power_up=false
				self.health_up=false
				self.mp_up=false
				self.debuff=false
			end

			--new room if walk into ladder
			if check_tile(self.x,self.y,2) then
				sfx(13)
				--new map
				random_map()
				--reset counter
				counter=0
				--next floor
				floor+=1
				--increase enemy difficulty
				local obj
				for obj in all(game_objects)do
					obj:enemy_increase_stats()
				end
			end

			--check which wall to draw
			if north then
				front,left,right = vision(self.x,self.y-4,0),vision(self.x-4,self.y,0),vision(self.x+12,self.y,0)

				rand_item,health_item,mp_item,power_item,ladder= vision(self.x,self.y-4,1),vision(self.x,self.y-4,3),vision(self.x,self.y-4,4),vision(self.x,self.y-4,5),vision(self.x,self.y-4,2)

				dist_front,dist_left,dist_right = vision(self.x,self.y-12,0),vision(self.x-4,self.y-4,0),vision(self.x+12,self.y-4,0)

				furth_front,furth_left,furth_right = vision(self.x,self.y-20,0),vision(self.x-4,self.y-12,0),vision(self.x+12,self.y-12,0)

			elseif south then
				front,left,right = vision(self.x,self.y+12,0),vision(self.x+12,self.y,0),vision(self.x-4,self.y,0)

				rand_item,health_item,mp_item,power_item,ladder= vision(self.x,self.y+12,1),vision(self.x,self.y+12,3),vision(self.x,self.y+12,4),vision(self.x,self.y+12,5),vision(self.x,self.y+12,2)
				
				dist_front,dist_left,dist_right = vision(self.x,self.y+20,0),vision(self.x+12,self.y+12,0),vision(self.x-4,self.y+12,0)

				furth_front,furth_left,furth_right =  vision(self.x,self.y+28,0),vision(self.x+12,self.y+20,0),vision(self.x-4,self.y+20,0)
			elseif west then
				front,left,right = vision(self.x-4,self.y,0),vision(self.x,self.y+12,0),vision(self.x,self.y-4,0)

				rand_item,health_item,mp_item,power_item,ladder= vision(self.x-4,self.y,1),vision(self.x-4,self.y,3),vision(self.x-4,self.y,4),vision(self.x-4,self.y,5),vision(self.x-4,self.y,2)
				
				dist_front,dist_left,dist_right = vision(self.x-12,self.y,0),vision(self.x-4,self.y+12,0),vision(self.x-4,self.y-4,0)

				furth_front,furth_left,furth_right = vision(self.x-20,self.y,0),vision(self.x-12,self.y+12,0),vision(self.x-12,self.y-4,0)
			else
				front,left,right = vision(self.x+12,self.y,0),vision(self.x,self.y-4,0),vision(self.x,self.y+12,0)

				rand_item,health_item,mp_item,power_item,ladder= vision(self.x+12,self.y,1),vision(self.x+12,self.y,3),vision(self.x+12,self.y,4),vision(self.x+12,self.y,5),vision(self.x+12,self.y,2)
				
				dist_front,dist_left,dist_right = vision(self.x+20,self.y,0),vision(self.x+12,self.y-4,0),vision(self.x+12,self.y+12,0)

				furth_front,furth_left,furth_right = vision(self.x+28,self.y,0),vision(self.x+20,self.y-4,0),vision(self.x+20,self.y+12,0)
			end

			--setting the sprite
			if north then
				self.sprite=1
			elseif south then
				self.sprite=17
			elseif east then
				self.sprite=33
			else
				self.sprite=49
			end
		end,
		draw=function(self)
			--only show sprite if map is open
			if show_map then
				spr(self.sprite,self.x,self.y)
				rectfill(2,117,47,126,4)
				spr(16,2,118)
				print("close: ❎",12,120,7)
			else
				--only draw if map not open
				--health bar
				rect(3,3,5+(max_health/1.5),11,1)
				rectfill(4,4,4+(health/1.5),10,8)

				print(flr(health).. "/".. max_health,5,5,7)

				--mp bar
				rect(3,13,5+(max_mp/1.5),21,1)
				rectfill(4,14,4+(mp/1.5),20,12)

				print(flr(mp).. "/".. max_mp,5,15,7)
			end

			--popup for items
			if self.message_timer>0 then
				if self.power_up then
					print("power up!",46.0,19,7)
				elseif self.health_up then
					print("health up!",44,19,7)
				elseif self.mp_up then
					print("mp up!",52,19,7)
				elseif self.debuff then
					print("debuff!",50,19,7)
				end
			end

			--encounter ui with battle options
			if encounter then
				rectfill(0,80,127,127,1)
				rect(2,82,125,125,6)

				--moves
				rect(5,86,62,98,5)
				print("strike 0 mp",10,90,6)

				rect(65,86,122,98,5)
				print("flame 15 mp",71,90,6)


				rect(5,102,62,114,5)
				print("freeze 10 mp",10,106,6)


				rect(65,102,122,114,5)
				print("rock 10 mp",71,106,6)

				print("action: ❎ run: 🅾️",29,118,6)

				--cursor
				rect(self.cursor_x,self.cursor_y,self.cursor_x+57,self.cursor_y+12,7)
			elseif not encounter and not show_map then
				--navigation ui
				--compass
				circfill(113,113,12,1)
				circfill(113,113,10,6)
				circ(113,113,8,counter_colour)

				if north then
					print("n",112,111,1)
				elseif east then
					print("e",112,111,1)
				elseif south then
					print("s",112,111,1)
				else
					print("w",112,111,1)
				end

				--floor
				print("floor:"..floor,92,2,7)

				--points
				print("points:"..points,84,10,7)

				--map
				spr(16,2,118)
				print("map: ❎",12,120,7)
			end
		end
	})
end

function make_slime(x,y)
	return make_game_object("slime",x,y,{
		-- variables
		max_health=15,
		health=15,
		turn=false,
		turn_timer=60,
		damage_taken=0,
		miss=false,
		damage=3,
		update=function(self)
			self:enemy_turn_timer()

			--check if enemy health is 0
			if (self.health<1)  slime_encounter=false encounter=false sfx(11) points+=flr(self.max_health)

			--only update if encounter
			if slime_encounter and encounter then
				--bob sprite
				self:bob()

				--limit y
				self.y=mid(0,self.y,3)

				--player turn
				--take damage
				self:take_damage(4,10,6,5)

				--enemy turn
				self:deal_damage(self.damage)
			else
				self:enemy_stats_reset()
			end
			
		end,
		draw=function(self)
			--only draw if encounter
			if slime_encounter and encounter then
				slime(self.y)

				--display damage and health
				self:display_damage()
			end
		end
	})
end

function make_skeleton(x,y)
	return make_game_object("skeleton",x,y,{
		-- variables
		max_health=20,
		health=20,
		turn=false,
		turn_timer=60,
		damage_taken=0,
		miss=false,
		damage=5,
		update=function(self)
			self:enemy_turn_timer()

			--check if enemy health is 0
			if (self.health<1) skeleton_encounter=false encounter=false sfx(11) points+=flr(self.max_health)
			
			--only update if encounter
			if skeleton_encounter and encounter then
				--bob sprite
				self:bob()

				--players turn
				--take damage
				self:take_damage(8,3,5,12)

				--enemy turn
				self:deal_damage(self.damage)
			else
				self:enemy_stats_reset()
			end
			
		end,
		draw=function(self)
			--only draw if encounter
			if skeleton_encounter and encounter then
				skeleton(self.y)

				--display damage and health
				self:display_damage()
			end
		end
	})
end

function make_snake(x,y)
	return make_game_object("snake",x,y,{
		-- variables
		max_health=10,
		health=10,
		turn=false,
		turn_timer=60,
		damage_taken=0,
		miss=false,
		damage=7,
		update=function(self)
			self:enemy_turn_timer()

			--check if enemy health is 0
			if (self.health<1) snake_encounter=false encounter=false sfx(11) points+=flr(self.max_health)
			
			--only update if encounter
			if snake_encounter and encounter then
				--bob sprite
				self:bob()

				--players turn
				--take damage
				self:take_damage(8,3,7,12)

				--enemy turn
				self:deal_damage(self.damage)
			else
				self:enemy_stats_reset()
			end
			
		end,
		draw=function(self)
			--only draw if encounter
			if snake_encounter and encounter then
				snake(self.y)

				--display damage and health
				self:display_damage()
			end
		end
	})
end

function make_troll(x,y)
	return make_game_object("troll",x,y,{
		-- variables
		max_health=28,
		health=28,
		turn=false,
		turn_timer=60,
		damage_taken=0,
		miss=false,
		damage=5,
		update=function(self)
			self:enemy_turn_timer()

			--check if enemy health is 0
			if (self.health<1) troll_encounter=false encounter=false sfx(11) points+=flr(self.max_health)
			
			--only update if encounter
			if troll_encounter and encounter then
				--bob sprite
				self:bob()

				--players turn
				--take damage
				self:take_damage(3,7,18,5)

				--enemy turn
				self:deal_damage(self.damage)
			else
				self:enemy_stats_reset()
			end
			
		end,
		draw=function(self)
			--only draw if encounter
			if troll_encounter and encounter then
				troll(self.y)

				--display damage and health
				self:display_damage()
			end
		end
	})
end

function make_ghost(x,y)
	return make_game_object("ghost",x,y,{
		-- variables
		max_health=15,
		health=15,
		turn=false,
		turn_timer=60,
		damage_taken=0,
		miss=false,
		damage=3,
		update=function(self)
			self:enemy_turn_timer()

			--check if enemy health is 0
			if (self.health<1) ghost_encounter=false encounter=false sfx(11) points+=flr(self.max_health)
			
			--only update if encounter
			if ghost_encounter and encounter then
				--bob sprite
				self:bob()

				--players turn
				--take damage
				self:take_damage(5,5,13,6)

				--enemy turn
				self:deal_damage(self.damage)
			else
				self:enemy_stats_reset()
			end
			
		end,
		draw=function(self)
			--only draw if encounter
			if ghost_encounter and encounter then
				ghost(self.y)

				--display damage and health
				self:display_damage()
			end
		end
	})
end

function make_flatwoods(x,y)
	return make_game_object("flatwoods",x,y,{
		-- variables
		max_health=25,
		health=25,
		turn=false,
		turn_timer=60,
		damage_taken=0,
		miss=false,
		damage=6,
		update=function(self)
			self:enemy_turn_timer()

			--check if enemy health is 0
			if (self.health<1) flatwoods_encounter=false encounter=false sfx(11) points+=flr(self.max_health)
			
			--only update if encounter
			if flatwoods_encounter and encounter then
				--bob sprite
				self:bob()

				--players turn
				--take damage
				self:take_damage(7,15,5,10)

				--enemy turn
				self:deal_damage(self.damage)
			else
				self:enemy_stats_reset()
			end
			
		end,
		draw=function(self)
			--only draw if encounter
			if flatwoods_encounter and encounter then
				flatwoods(self.y)

				--display damage and health
				self:display_damage()
			end
		end
	})
end

function make_imp(x,y)
	return make_game_object("imp",x,y,{
		-- variables
		max_health=18,
		health=18,
		turn=false,
		turn_timer=60,
		damage_taken=0,
		miss=false,
		damage=7,
		update=function(self)
			self:enemy_turn_timer()

			--check if enemy health is 0
			if (self.health<1) imp_encounter=false encounter=false sfx(11) points+=flr(self.max_health)
			
			--only update if encounter
			if imp_encounter and encounter then
				--bob sprite
				self:bob()

				--players turn
				--take damage
				self:take_damage(8,4,11,10)

				--enemy turn
				self:deal_damage(self.damage)
			else
				self:enemy_stats_reset()
			end
			
		end,
		draw=function(self)
			--only draw if encounter
			if imp_encounter and encounter then
				imp(self.y)

				--display damage and health
				self:display_damage()
			end
		end
	})
end
-->8
--functions
--from bridgs tutorial
function for_each_game_object(name,callback)
	local obj
	for obj in all(game_objects) do
		if (obj.name==name) callback(obj)
	end
end

--map collision 
function check_tile(x,y,flag)
	local tile_x=x/8
 	local tile_y=y/8
 	local tile=mget(tile_x,tile_y)
 	return fget(tile,flag)
end

--map collision 
function hit_wall(x,y,width,height,indent)
 	if (check_tile(x+indent,y,0)) and (check_tile(x+width-indent,y,0)) then
 		return "top"
 	elseif (check_tile(x+indent,y,0)) and (check_tile(x+width-indent,y,0)) then
 		return "bottom"
 	elseif (check_tile(x,y+indent,0)) and (check_tile(x,y+height-indent,0)) then
 		return "left"
 	elseif (check_tile(x,y+indent,0)) and (check_tile(x+width,y+height-indent,0)) then
 		return "right"
 	else
 		return "none"
 	end
end

--vision
function vision(x,y,flag)
	if check_tile(x,y,flag) then
		return true
	else
		return false
	end
end

--count frames
function frame_counter(limit)
	frame+=1
	if (frame>limit) frame=0
end

-- remove all items from a list
function remove(list)
	local i
	for i=1,#list do
		del(list, list[1])
	end
end

--screen shake
function screen_shake(intesity)
	local shakex,shakey=16-rnd(32),16-rnd(32)
	camera(shakex*intesity,shakey*intesity)
end

--bob y for enemies and pickups
function bob(y)
	if frame>29 then 
		y+=0.4
	else y-=0.4

	end 
	y=mid(27,y,33)
end

--flash text
function text_flash(colours)
	if frame>29 then 
		return colours[1]
	else 
		return colours[2]
	end 
end

--death screen blood pouring
function blood()
	local rand=flr(rnd(10))
	local rand_drop=flr(rnd(8))
	for i=0,8 do
		if i==rand_drop then
			rectfill(i*16,-5,(i*16)+16,height+rand,11)
			circfill((i*16)-8,height+rand,10,11)
		else
			rectfill(i*16,-5,(i*16)+16,height,11)
			circfill((i*16)-8,height,10,11)
		end
	end
end

--create explosion particles
function explosion(x,y)
	for i=1,10 do
		local my_particle={}
		my_particle.x=x 
		my_particle.y=y 
		my_particle.sx=rnd()*25-3
		my_particle.sy=rnd()*25-3
		my_particle.size=rnd(6)+1
		my_particle.age=rnd(2)
		my_particle.max_age=10+rnd(10)

		add(particle,my_particle)
	end
end

--draw explosion
function draw_explosion(colours)
	for my_particle in all(particle) do
		--change colour based on time
		local colour=7
		if my_particle.age>5 then
			colour=colours[4]
		end
		if my_particle.age>7 then
			colour=colours[3]
		end
		if my_particle.age>12 then
			colour=colours[2]
		end
		if my_particle.age>15 then
			colour=colours[1]
		end 

		--draw explosion particles
		circfill(my_particle.x,my_particle.y,my_particle.size,colour)

		--move particles
		my_particle.x+=my_particle.sx
		my_particle.y+=my_particle.sy

		my_particle.sx*=0.5
		my_particle.sy*=0.5

		--count up age
		my_particle.age+=1

		--decrease size
		if my_particle.age>my_particle.max_age then
			my_particle.size-=0.5
			if my_particle.size<0 then
				del(particle,my_particle)
			end
		end
	end
end

--cirlce draw
function circle_draw(x,y,radius)
	--draw circles
	for i=0,128 do
		circ(x,y,radius+i,11)
		circ(x-1,y,radius+i,11)
	end
end

-->8
--map generation
--choose random map
function random_map()
	--list of room types
	--each room is a list of tiles
	--2 is wall 18 is floor
	--boolean for if a door is on top,right,bottom,left clockwise
	local rooms={}
	add(rooms,{split([[2,2,2,18,18,2,2,2,
					2,18,18,18,18,18,18,2,
					2,18,2,2,2,2,18,2,
					18,18,18,18,18,2,18,18,
					18,18,2,18,18,18,18,18,
					2,18,2,2,2,2,18,2,
					2,18,18,18,18,18,18,2,
					2,2,2,18,18,2,2,2]]),
				{true,true,true,true}})

	add(rooms,{split([[2,2,2,18,18,2,2,2,
					2,18,18,18,18,18,18,2,
					2,18,18,18,18,18,18,2,
					2,2,2,2,2,18,18,18,
					2,2,2,2,2,18,18,18,
					2,18,18,18,18,18,18,2,
					2,18,18,18,18,18,18,2,
					2,2,2,18,18,2,2,2]]),
				{true,true,true,false}})

	add(rooms,{split([[2,2,2,2,2,2,2,2,
					2,18,18,2,2,18,18,2,
					2,18,18,2,2,18,18,2,
					18,18,18,2,2,18,18,18,
					18,18,2,2,2,2,18,18,
					2,18,2,2,2,2,18,2,
					2,18,18,18,18,18,18,2,
					2,2,2,18,18,2,2,2]]),
				{false,true,true,true}})

	add(rooms,{split([[2,2,2,18,18,2,2,2,
					2,2,2,18,18,2,2,2,
					2,2,2,18,18,2,2,2,
					18,18,18,18,18,18,18,18,
					18,18,18,18,18,18,18,18,
					2,2,2,18,18,2,2,2,
					2,2,2,18,18,2,2,2,
					2,2,2,18,18,2,2,2]]),
				{true,true,true,true}})

	add(rooms,{split([[2,2,2,18,18,2,2,2,
					2,18,18,18,18,18,18,2,
					2,18,18,18,18,18,18,2,
					2,2,2,18,18,2,2,2,
					2,2,2,18,18,2,2,2,
					2,18,18,18,18,18,18,2,
					2,18,18,18,18,18,18,2,
					2,2,2,18,18,2,2,2]]),
				{true,false,true,false}})

	add(rooms,{split([[2,2,2,18,18,2,2,2,
					2,18,18,18,18,18,18,2,
					2,18,18,18,18,18,18,2,
					18,18,18,2,2,2,2,2,
					18,18,18,2,2,2,2,2,
					2,18,18,18,18,18,18,2,
					2,18,18,18,18,18,18,2,
					2,2,2,18,18,2,2,2]]),
				{true,false,true,true}})

	add(rooms,{split([[2,2,2,18,18,2,2,2,
					2,18,2,18,18,18,18,2,
					2,18,2,18,18,18,18,2,
					18,18,2,18,18,18,18,18,
					18,18,18,18,18,2,18,18,
					2,18,18,18,18,2,18,2,
					2,18,18,18,18,2,18,2,
					2,2,2,18,18,2,2,2]]),
				{true,true,true,true}})

	add(rooms,{split([[2,2,2,18,18,2,2,2,
					2,18,18,18,18,18,18,2,
					2,18,2,2,2,2,18,2,
					18,18,2,2,2,2,18,18,
					18,18,18,2,2,18,18,18,
					2,18,18,2,2,18,18,2,
					2,18,18,2,2,18,18,2,
					2,2,2,2,2,2,2,2]]),
				{true,true,false,true}})

	--debug data
	----------------------
	local room_tile_data=""
	local tile_count=0
	local room_door_data=""
	local door_count=0
	for room in all(rooms) do
		for tile in all(room[1]) do
			room_tile_data=room_tile_data.. tostr(tile).. ","
			tile_count+=1
			if tile_count%8==0 then
				room_tile_data=room_tile_data.. "\n"
			end
			if tile_count%64==0 then
				room_tile_data=room_tile_data.. "\n\n"
			end
		end

		for door in all(room[2]) do
			room_door_data=room_door_data.. tostr(door).. ","
			door_count+=1
			if door_count%4==0 then
				room_door_data=room_door_data	.. "\n\n"
			end
		end
	end

	printh(room_tile_data,"md_room_tiles.txt",1)
	printh(room_door_data,"md_room_doors.txt",1)
	-----------------------------

	--new map
	local new_map={}

	--generate first room until it has a door on either the right or bottom
	repeat
		local rand_room=flr(rnd(#rooms))+1
	until rooms[rand_room][2][2] or rooms[rand_room][2][3]

	add(new_map,rooms[rand_room])

	local tile_counter=1
	for x=0,8 do
		for y=0,8 do
			--place map tiles
			mset(x,y,new_map[tile_counter])

			--increment room tiles
			tile_counter+=1
		end
	end


	--[[loop through map
	local tile_counter=1
	for x=0,15 do
		for y=0,15 do
			--place map tiles
			mset(x,y,new_map[tile_counter])

			--increment room tiles
			tile_counter+=1
		end
	end--]]

	--place outer walls
	for outer_x=0,15 do
		for outer_y=0,15 do
			if outer_x==0 or outer_x==15 or outer_y==0 or outer_y==15 then
				mset(outer_x,outer_y,2)
			end
		end
	end

	--list of pickups
	local pickups={}

	--for placing 3 random pickups
	for i=0,2 do
		local random_pickup=flr(rnd(5))

		if random_pickup<2 then
			add(pickups,19)
		elseif random_pickup==2 then
			add(pickups,3)
		elseif random_pickup==3 then
			add(pickups,35)
		else
			add(pickups,51)
		end
	end

	--randomly place tiles
	--exit
	place_rand_tile(50)

	--pickups
	--place pickups only when list is not empty
	for i=0,2 do
		if #pickups>0 then
			--starts at 1 not 0 :/
			place_rand_tile(pickups[1])

			--delete pickup
			del(pickups, pickups[1])
		end
	end

	--find player starting tile
	--repeat until the x and y coords are only floor tiles
	local spawn_x,spawn_y
	repeat
		spawn_x,spawn_y=flr(rnd(15)),flr(rnd(15))
	until mget(spawn_x,spawn_y)==18

	for_each_game_object("player",function(player)
		--set coords
		player.x=spawn_x*8
		player.y=spawn_y*8
	end)
end

--randomly place tiles
function place_rand_tile(tile)
	--repeat until the x and y coords are only floor tiles
	local x,y
	repeat
		x,y=flr(rnd(15)),flr(rnd(15))
	until mget(x,y)==18

	--set tile
	mset(x,y,tile)
end

-->8
--backgrounds
--sky background for menu and class select
function sky(x)
	--moon
	circfill(110,15,12,10)
	circfill(100,10,12,11)
	--place stars
	for i=1,50 do
		pset(star_x[i],star_y[i],7)
	end
	--cloud
	circfill(x,39,7,6)
	circfill(x+1,31,4,6)
	circfill(x+6,31,5,6)
	circfill(x+7,43,6,6)
	circfill(x+13,39,7,6)

	--mountains
	hill(0,100,10,5)
	hill(25,105,18,5)
	hill(64,100,25,5)
	hill(95,100,10,5)
	hill(110,95,18,5)
	--hills
	hill(3,120,15,3)
	hill(40,125,30,3)
	hill(70,120,10,3)
	hill(90,118,13,3)
	hill(115,120,25,3)
end

function hill(x,y,radius,colour)
	circfill(x,y,radius,colour)
	rectfill(x-radius,y,x+radius,128,colour)
end

-- backgrounds
function wall_left()
	spr(12,0,14,2,2)
	spr(12,16,22,2,2)
	rectfill(0,22,15,79,6)
	rectfill(16,30,31,71,6)
	spr(12,0,72,2,2,false,true)
	spr(12,16,64,2,2,false,true)
end

function wall_dist_left()
	rectfill(0,30,31,71,6)
	spr(14,32,30,2,2)
	rectfill(32,38,47,63,5)
	spr(14,32,56,2,2,false,true)
end

function wall_furth_left()
	rectfill(0,35,41,66,5)
	spr(44,42,35,2,2)
	rectfill(42,43,57,58,15)
	spr(44,42,51,2,2,false,true)
end

function wall_right()
	spr(12,112,14,2,2,true)
	spr(12,96,22,2,2,true)
	rectfill(127,22,112,79,6)
	rectfill(111,30,96,71,6)
	spr(12,112,72,2,2,true,true)
	spr(12,96,64,2,2,true,true)
end

function wall_dist_right()
	rectfill(127,30,96,71,6)
	spr(14,80,30,2,2,true)
	rectfill(95,38,80,63,5)
	spr(14,80,56,2,2,true,true)

end

function wall_furth_right()
	rectfill(127,35,86,66,5)
	spr(44,70,35,2,2,true)
	rectfill(70,43,85,58,15)
	spr(44,70,51,2,2,true,true)
end

function draw_ladder()
	circfill(53,72,5,15)
	rectfill(56,67,70,77,15)
	circfill(73,72,5,15)

	line(55,44,55,66,6)
	line(55,66,55,75,5)

	for i=0,20,5 do
		line(56,48+i,70,48+i,6)
	end
	
	line(56,68,70,68,5)
	line(56,73,70,73,5)

	line(71,44,71,66,6)
	line(71,66,71,75,5)
end

-->8
--enemies
function slime(y)
	-- outline
	circfill(64,35+y,32,1)
	circfill(44,68+y,10,1)
	rectfill(34,47+y,54,66+y,1)

	circfill(66,90+y,12,1)
	rectfill(54,60+y,78,86+y,1)

	circfill(87,60+y,7,1)
	rectfill(80,47+y,94,58+y,1)
	-- body
	circfill(44,68+y,8,3)
	rectfill(36,47+y,52,66+y,3)

	circfill(66,90+y,10,3)
	rectfill(56,60+y,76,86+y,3)

	circfill(87,60+y,5,3)
	rectfill(82,47+y,92,58+y,3)
	-- head
	circfill(64,35+y,30,3)
	-- face
	-- mouth
	circ(64,59+y,5,1)
	rectfill(59,54+y,69,62+y,3)
	eyes(y)
	--hands
	drip_hands(y,3)
end

function skeleton(y)
	-- outline
	circfill(64,35+y,32,1)
	rectfill(47,61+y,81,66+y,1)
	rectfill(48,68,80,128,1)
	-- body
	rectfill(50,68,78,128,13)
	--hands
	hands(y,7)
	-- head
	circfill(64,35+y,30,7)
	-- face
	-- mouth
	circfill(54,66+y,7,1)
	circfill(64,66+y,7,1)
	circfill(74,66+y,7,1)

	rectfill(49,59+y,79,64+y,7)
	circfill(54,66+y,5,7)
	circfill(64,66+y,5,7)
	circfill(74,66+y,5,7)
	-- nose
	circfill(64,55+y,2,1)
	eyes(y)
end

function imp(y)
	-- outline
	rectfill(48,58,80,128,1)
	-- body
	rectfill(50,58,78,128,2)
	--hands
	hands(y,2)
	-- head
	circfill(64,35+y,32,1)
	circfill(64,35+y,30,2)
	--horns
	spr(173,38,2+y,2,2)
	spr(173,75,2+y,2,2,true)
	--face
	circ(64,59+y,5,1)
	rectfill(59,54+y,69,62+y,2)
	eyes(y)
end

function ghost(y)
	-- outline
	rectfill(32,45+y,96,75+y,1)
	circfill(44,75+y,12,1)
	circfill(64,95+y,12,1)
	rectfill(52,75+y,76,91+y,1)
	circfill(84,85+y,12,1)
	rectfill(73,75+y,96,81+y,1)
	circfill(64,40+y,32,1)
	-- body
	rectfill(34,45+y,94,75+y,7)
	circfill(44,75+y,10,7)
	rectfill(54,75+y,74,91+y,7)
	circfill(64,95+y,10,7)
	rectfill(75,75+y,94,81+y,7)
	circfill(84,85+y,10,7)
	-- head
	circfill(64,40+y,30,7)
	-- face
	-- mouth
	circfill(64,65+y,3,1)
	eyes(y)
	--hands
	drip_hands(y,7)
end

function flatwoods(y)
	-- outline
	circfill(64,45+y,32,1)
	rectfill(48,68,80,128,1)
	-- body
	rectfill(50,68,78,128,2)
	--hands
	hands(y+15,1)
	-- head
	circfill(64,45+y,31,1)
	circfill(64,45+y,30,2)
	-- hood
	line(64,1+y,64,3+y,1)
	line(64,4+y,64,30+y,2)
	spr(77,40,1+y,3,3)
	spr(77,65,1+y,3,3,true)
	-- face
	circfill(64,55+y,22,1)
	circ(64,55+y,22,1)
	-- eyes
	circfill(50,54+y,3,10)
	circfill(78,54+y,3,10)
	-- cheeks
	line(45,62+y,47,60+y,14)
	line(48,62+y,50,60+y,14)
	line(51,62+y,53,60+y,14)
	line(73,62+y,75,60+y,14)
	line(76,62+y,78,60+y,14)
	line(79,62+y,81,60+y,14)
end

function troll(y)
	-- outline
	rectfill(48,58,80,128,1)
	circfill(32,45+y,9,1)
	circfill(96,45+y,9,1)
	-- body
	rectfill(50,58,78,128,6)
	--hands
	hands(y,13)
	-- head
	circfill(64,35+y,32,1)
	circfill(64,35+y,30,13)
	--ears
	circfill(32,45+y,7,13)
	circ(32,45+y,3,1)
	circfill(96,45+y,7,13)
	circ(96,45+y,3,1)
	--face
	-- mouth
	line(61,64+y,67,64+y,1)
	pset(65,65+y,7)
	--nose
	line(62,55+y,64,58+y,1)
	line(64,58+y,66,55+y,1)
	eyes(y)
end

function snake(y)
	--body
	spr(73,58,51+y,4,3)
	spr(73,58,75+y,4,3)
	--head
	circfill(64,35+y,19,1)
	circfill(64,35+y,17,3)
	--face
	-- eyes
	circfill(50,41+y,3,10)
	line(50,39+y,50,43+y,1)
	circfill(78,41+y,3,10)
	line(78,39+y,78,43+y,1)
	-- cheeks
	line(45,49+y,47,47+y,14)
	line(48,49+y,50,47+y,14)
	line(51,49+y,53,47+y,14)
	line(73,49+y,75,47+y,14)
	line(76,49+y,78,47+y,14)
	line(79,49+y,81,47+y,14)
	--nose
	line(62,51+y,63,52+y,1)
	line(65,52+y,66,51+y,1)
	--tongue
	line(64,55+y,64,56+y,8)
end

function eyes(y)
	--eyes
	circfill(50,43+y,8,1)
	circfill(78,43+y,8,1)
	-- cheeks
	line(45,55+y,47,53+y,1)
	line(48,55+y,50,53+y,1)
	line(51,55+y,53,53+y,1)

	line(73,55+y,75,53+y,1)
	line(76,55+y,78,53+y,1)
	line(79,55+y,81,53+y,1)
end

function drip_hands(y,colour)
	circfill(27,50+(y/2),10,1)
	circfill(22,59+(y/2),5,1)
	rectfill(17,51+(y/2),28,60+(y/2),1)
	circfill(27,62+(y/2),5,1)
	rectfill(22,51+(y/2),33,63+(y/2),1)
	circfill(31,56+(y/2),5,1)
	rectfill(26,51+(y/2),37,57+(y/2),1)

	circfill(27,50+(y/2),8,colour)
	circfill(22,59+(y/2),3,colour)
	rectfill(19,51+(y/2),26,60+(y/2),colour)
	circfill(27,62+(y/2),3,colour)
	rectfill(24,51+(y/2),31,63+(y/2),colour)
	circfill(31,56+(y/2),3,colour)
	rectfill(28,51+(y/2),35,57+(y/2),colour)

	circfill(103,65+(y/1.5),10,1)
	circfill(98,71+(y/1.5),5,1)
	rectfill(93,66+(y/1.5),104,72+(y/1.5),1)
	circfill(103,77+(y/1.5),5,1)
	rectfill(98,66+(y/1.5),109,78+(y/1.5),1)
	circfill(108,74+(y/1.5),5,1)
	rectfill(102,66+(y/1.5),113,75+(y/1.5),1)

	circfill(103,65+(y/1.5),8,colour)
	circfill(98,71+(y/1.5),3,colour)
	rectfill(95,66+(y/1.5),102,72+(y/1.5),colour)
	circfill(103,77+(y/1.5),3,colour)
	rectfill(100,66+(y/1.5),107,78+(y/1.5),colour)
	circfill(108,74+(y/1.5),3,colour)
	rectfill(104,66+(y/1.5),111,75+(y/1.5),colour)
end

function hands(y,colour)
	circfill(34,70+(y/2),10,1)
	circfill(34,70+(y/2),8,colour)

	circfill(94,70+(y/2),10,1)
	circfill(94,70+(y/2),8,colour)
end

__gfx__
00000000001111005666666544111144000000000011111111111100000000000007000000001111111100000000000066000000000000005500000000000000
0000000001aaa9106566665f4189aa14000000000111711111111110000000000007000001111111111111100000000066660000000000005555000000000000
007007001a111191665555ff189aa3c100000000011878888888811000000000007077071111cccccccc11111000000066666600000000005555550000000000
00077000011aa110665555ff19aa3cc100000000017787778788811000000000000700111ccccccccccccc711100000066666666000000005555555500000000
0007700001aaa910665555ff1aa3ccd10000000001187888888881100000000000070111cccccccccccccc7c1110000066666666660000005555555555000000
0070070001aa9910665555ff1a3ccd2100000000011878888888811000000000000711ccccccccccccccc7c77c11000066666666666600005555555555550000
000000000019910065ffff5f41ccd2140000000001187888888881100000000000071ccccccccccccccccc7cccc1100066666666666666005555555555555500
00000000000110005ffffff5441111440000070001187888888881100000000000111ccccccc7777cccccc7cccc1110066666666666666665555555555555555
00111110000110001111111144111144000007000118888888888110000000000011cccccc777777777ccc7ccccd110000000000000000000000000000000000
01ddddd1001aa100144444414418814401117177111888888888211111111110011cccccc77777777777cc7ccccdd11000000000000000000000000000000000
0166d8d101aaa910144444411118811111111711111888888888211111111111011ccccc777777777777cccccccdd11000000000000000000000000000000000
01d6dd6101aa9910144444411888882111888788888888888882222222222f11011cccc7777777777777cccccccdd11000000000000000000000000000000000
166ddd1001199110144444411888822111888788888888888882222222222f1111ccccc77777777777cccccccccddd1100000000000000000000000000000000
1ddd66101a11119114444441111821111188888888888888882222222222ff1111cccc77777777777cccccccccdddd1100000000000000000000000000000000
1dcddd1001aaa91014444441441221441188888888888888882222222222ff1111cccc7777777777ccccccccccdddd1100000000000000000000000000000000
01111100001111001111111144111144118888888888888882222222222fff1111cccc77777777ccccccccccccdddd1100000000000000000000000000000000
00000000000001000000000044111144118888888888888822222222222fff1111cccc7777777ccccccccccccddddd11ff000000000000000111100000000000
00000000001119100000000041cccc1411888888888888822222222222ffff1111cccc777777cccccccccccccdddd211ffff0000000000001111110000000000
0000000001aa1191000000001c77ccd11188888888888822222222222fffff1111ccccc7777cccccccccccccddddd211ffffff00000000001166111111111111
000000001aaa9191000000001c7cccd1118888888888222222222222ffffff1111ccccccccccccccccccccccddddd211ffffffff000000001166111111111111
000000001aa99191000000001cccccd111888888882222222222222fffffff11011ccccccccccccccccccccddddd2110ffffffffff0000001166666666666666
0000000001991191000000001ccccdd111111111111222222222211111111111011cccccccccccccccccccdddddd2110ffffffffffff00001166666666666666
00000000001119100000000041dddd1401111111111222222222211111111110011cc7cccccccccccccccdddddd72110ffffffffffffff001166111111111111
0000000000000100000000004411114400000000011222222222f110070000000011c7ccccccccccccccdddddd221100ffffffffffffffff1166111111111111
000000000010000011144111444114440000000001122222222ff1100700000000117c777ccccccccccdddddd227110000000000000000001166110000000000
0000000001a11100161111614417a144000000000112222222fff11070770700000117cccccccccccdddddddd271777000000000000000001166111111111111
000000001a11aa1016666661411aa1140000000001122222fffff11007000000000017ccccccccddddddddd22217000000000000000000001166111111111111
000000001a1aaa91161111611aaaaa91000000000112222ffffff1100700000000000711cddddddddddddd221117000000000000000000001166666666666666
000000001a1aa991161111611aaaa9910000000001122ffffffff11007000000000007111ddddddddddd22211107000000000000000000001166666666666666
000000001911991016666661411a911400000000011ffffffffff11000000000000007011111ddddd22211111007000000000000000000001166111111111111
00000000019111001611116144199144000000000111111111111110000000000000000001111111111111100000000000000000000000001166111111111111
00000000001000001114411144411444000000000011111111111100000000000000000000001111111100000000000000000000000000001166110000000000
00000000000000011000000000000000000700000000111111110000000000000000000011333333331111111111111111000000000000000000000000000001
00000000000000111100000000000000000700000111111111111110000000000000000011333333331111111111111111110000000000000000000000000011
0000700000000117a110000000000000007070711111888999991111100700000000000011333333333333333333333331111000000000000000000000000111
0000700000000117a110000007000000000700111888899999999991110700000000000011333333333333333333333333311100000000000000000000001112
0077077070000117a1100000000000000007011188899999999999aa111700000000000011333333333333333333333333331110000000000000000000011122
000070000000011aa11000000700000000071188899999999999aaaaa77177700000000011333333333333333333333333333111000000000000000000111222
000070000000011aa110000007000000000718889999999999aaaaaaaa3710000000000011133333333333333333333333333311000000000000000001112222
000070000000011aa1100007707707000011188999999999aaaaaaaaa33711000000000001113333333333333333333333333311000000000000000011122222
00000000000011aaaa1100000700000000118899999999aaaaaaaaaa333711000000000000111333333333333333333333333311000000000000000111222222
00000000000011aaaa110000070000000118899999999aaaaaaaaaa33337c1100000000000011113333333333333333333333311000000000000001112222222
0000000000011aaaaaa1100007000000011889999999aaaaaaaaaa33333cc1100000000000001111111111111111113333333311000000000000011122222222
0000000000111aaaaaa111000700000001189999999aaaaaaaaaa333333cc1100000000000000111111111111111111333333311000000000000111222222222
000000001111aaaaaaaa1111000000001188999999aaaaaaaaaa333333cccc110000000000000111111111111111111333333311000000000001112222222222
0011111111aaaaaaaaaaa91111111100118999999aaaaaaaaaa3333333cccc110000000000001111111111111111113333333311000000000011122222222222
01111111aaaaaaaaaaaaa9991111111011899999aaaaaaaaaa3333333ccccc110000000000011113333333333333333333333311000000000111222222222222
11aaaaaaaaaaaaaaaaaaa9999999991111999999aaaaaaaaa33333333ccccc110000000000111333333333333333333333333311000000001112222222222222
11999999aa7aaaaaaaaa9999999999111199999aaaaaaaaa33333333cccccc110000000001113333333333333333333333333311000000011122222222222222
01111111997aaaaaaaaa9999111111101199999aaaaaaaa333333333cccccd110000000011133333333333333333333333333311000000111222222222222222
0011111177977aaaaaa9991111111100119999aaaaaaaa333333333ccccccd110000000011333333333333333333333333333111000001112222222222222222
0000000011719aaaaa99111100000000119799aaaaaaa333333333ccccccdd110000000011333333333333333333333333331110000011122222222222222222
0000000000711999999111000000000001179aaaaaaa333333333cccccccd1100000000011333333333333333333333333311100000111222222222222222222
00000000007119999991100000000000077977aaaaa333333333ccccc7cdd1100000000011333333333333333333333331111000001112222222222222222222
000000000070119999110000700000000117aaaaaa333333333cccccc7cdd1100000000011333333331111111111111111110000011122222222222222222222
000000000000119999110000700000000017aaaaa333333333cccccc7c7717000000000011333333331111111111111111000000111222222222222222222222
0000000000000119911000770777000000171aaa33333333ccccccccc7d1110000000000c0000000000cc0000000000000888000112222222222222222222222
0000000000000119911000007000000000011aa3333333ccccccccccd7d11000000000000c000000000cc0000008820008266700000000000000000000000000
00000000000001199110000070000000000011333333cccccccccccdd71100000000000000c0000000cccc000088227882666670000000000000000000000000
000000000000011991100000700000000000011133cccccccccccddd1710000000000000000c00200ccddc008282888782666670000000000000000000000000
00000000000001199110000070000000000000111ccccccccccdddd111000000000000000000c2000ccddcc08288888726565656000000000000000000000000
00000000000001199110000070000000000000011111cccccddd11111000000000000000000022000cdd7dc08288888826565656000000000000000000000000
000000000000001111000000000000000000000001111111111111100000000000000000000200200cd77dc08288888826666666000000000000000000000000
0000000000000001100000000000000000000000000011111111000000000000000000000000000200d77c00008888802f666660000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000dd00000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000d00000000000ddd000000000000000000000000000000000dddddddddddd00000000
00000000000000000000000000000000000000000000000000000000000dd00000000000ddd00000000000000000000000000000000ddddddddddddd00000000
0000000000000000000000000000000000000000000000000000000000ddd00000000000dd40000000000000000000000000000000dddddddddddddd00000000
0000000000000000000000000000000000000000000000000000000000ddd00000000000d44000000000000000000000000000000d4444444444444400000000
0000000d00000000000000000000000000000000000000000000000000ddd0000000000d44000000000000000000000000000000044444444444444400000000
000000ddd0000000000000000000000000000000000000000000000000ddd0000000d00440000000000000000000000000000000040000000000000000000000
00000ddddd00dddddd00dddddd000000d0000000d00000d00dddddd000ddd00ddddd400400d00000000d00dddddd000000000000000000000000000000000000
000004dddd0ddddddd0ddddddd00000dd000000dd0000dd0ddddddd000ddd0ddddd440000dd0000000dd0ddddddd000000000000000000000000000d00000000
0000044ddddddddddddddddddd0000ddd00000ddd000ddddddddddd000dddddddd440000ddd000000ddddddddddd000000000000ddddddddddddddd400000000
0000004ddd44444ddd44444ddd0000ddd00000ddd000ddd44444dd4000ddd44444400000ddd000000ddd44444ddd000000000000dddddddddddddd4400000000
0000000ddd44444ddd44444ddd0000ddd00000ddd000ddd44444d44000ddd44444000000ddd000000ddd44444ddd000000000000ddddddddddddd44000000000
0000000ddd00000ddd00000ddd0000ddd00000ddd000ddd0000d440000ddd00000000000ddd000000ddd00000dd4000000000000444444444444440000000000
0000000ddd00000ddd00000ddd0000ddd00000ddd000ddd000d4400000ddd00000000000ddd000000ddd00000d44000000000000444444444444400000000000
0000000ddd00000ddd00000ddd0000ddd00000ddd000ddd00d44000000ddd00000000000ddd000000ddd00000440000000000000000000000000000000000000
0000000ddd00000ddd00000ddd0000ddd00000ddd000ddddddddddd000ddd00000000000ddd000000ddd00000400000000000000000111000000000000000000
0000000ddd00000ddd00000ddd0000ddd00000ddd000ddddddddddd000ddd00000000000ddd000000ddd0000000d000000000000000111100000000000000000
0000000ddd00000ddd00000ddd0000ddd00000ddd000ddddddddddd000ddd00000000000ddd000000ddd000000dd000000000000001111100000000000000000
0000000ddd00000ddd00000ddd0000ddd00000ddd00d44dd4444ddd000ddd00000000000ddd000000ddd00000ddd000000000000001121110000000000000000
0000000ddd00000ddd00000ddd0000ddd00000ddd0044dd44444ddd000ddd00000000000ddd000000ddd00000ddd000000000000001121110000000000000000
0000000dddd0000ddd00000ddd0000dddd0000ddd004ddd40000ddd000dddd0000000000dddd00000dddd0000ddd000000000000011122111000000000000000
0000000ddddd000ddd00000ddd0000ddddd000ddd000ddd00000ddd000ddddd000000000ddddd0000ddddd000ddd000000000000011222211100000000000000
000000d4ddddd00ddd00000ddd000d4ddddd00ddd000ddd00000ddd00d4ddddd0000000d4ddddd00d4ddddd00dd4000000000000011222211110000000000000
000000444ddd400dd400000ddd000444ddddddddd000dddddddddd400444ddd40000000444ddd400444ddddddd44000000000000011222221122200000000000
0000004044d4400d4400000ddd0004044dddddddd000ddddddddd44004044d4400000004044d44004044ddddd440000000000000011222222222200000000000
00000000044400d44000000ddd00000044ddd4ddd000dddddddd440000004440000000000044400000044ddd4400000000000000011222222222200000000000
00000000004000440000000ddd000000044444ddd000444444444000000004000000000000040000000044444000000000000000011222222222200000000000
00000000000000400000000ddd000000004440ddd000444444440000000000000000000000000000000004440000000000000000011222222222220000000000
00000000000000000000000ddd000000000000ddd000000000000000000000000000000000000000000000000000000000000000111222222222222000000000
00000000000000000000000dd4000000000000dd4000000000000000000000000000000000000000000000000000000000000000112222222222222200000000
00d00000000000000000000d44000000000000d44000000000000000000000000000000000000000000000000000000000000000112222222222222200000000
004d000000000000000000d44000000000000d440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004dd000000000000000004400000000000004400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004ddd000000000000000400000000d0000040000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000
0004dddddd00000000000000000000ddd00000000000000000000000000000000000000000000000000000ddd000000000000000000000000000000000000000
000d4ddddddd00000d0000000d000ddddd00dddddd00000d00dddddd00000d00dddddd00000d00dddddd0ddddd00dddddd000000000000000000000000000000
00dd444ddddd0000dd000000dd0004dddd0ddddddd0000dd0ddddddd0000dd0ddddddd0000dd0ddddddd04dddd0ddddddd000000000000000000000000000000
0ddd04444ddd000ddd00000ddd00044ddddddddddd000ddddddddddd000ddddddddddd000ddddddddddd044ddddddddddd000000000000000000000000000000
0ddd00044ddd000ddd00000ddd00004ddd44444ddd000ddd44444ddd000ddd44444ddd000ddd44444ddd004ddd44444ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd44444ddd000ddd44444ddd000ddd44444ddd000ddd44444ddd000ddd44444ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd00000ddd000ddd00000ddd000ddd00000dd4000ddd00000ddd000ddd00000ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd00000ddd000ddd00000ddd000ddd00000dd4000ddd00000ddd000ddd00000ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd00000ddd000ddd00000ddd000ddd00000d40d00ddd00000ddd000ddd00000ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd00000ddd000ddd00000ddd000ddd0000d44d400ddd00000ddd000ddd00000ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd00000ddd000ddd00000ddd000ddd000d44dd400ddd00000ddd000ddd00000ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd00000ddd000ddd00000ddd000ddd00d440dd000ddd00000ddd000ddd00000ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd00000ddd000ddd00000ddd000ddd0d440ddd000ddd00000ddd000ddd00000ddd000000000000000000000000000000
0ddd00000ddd000ddd00000ddd00000ddd00000ddd000ddd00000ddd000dddd4400ddd000ddd00000ddd000ddd00000ddd000000000000000000000000000000
0dddd0000ddd000dddd0000ddd00000dddd0000ddd000dddd0000ddd000dddd4000ddd000dddd0000ddd000dddd0000ddd000000000000000000000000000000
0ddddd000ddd000ddddd000ddd00000ddddd000ddd000ddddd000ddd000ddddd000ddd000ddddd000ddd000ddddd000ddd000000000000000000000000000000
d4ddddd00dd400d4ddddd00dddd000d4ddddd00ddd00d4ddddd00ddd00d4ddddd00dd400d4ddddd00dd400d4ddddd00ddd000000000000000000000000000000
444ddddddd4400444ddddddddddd00444ddd400ddd00444ddddddddd00444ddddddd4400444ddddddd4400444ddd400ddd000000000000000000000000000000
4044ddddd440004044ddddd4ddd4004044d4400ddd004044dddddddd004044ddddd440004044ddddd440004044d4400ddd000000000000000000000000000000
00044ddd44000000044ddd444d4400000444000ddd0000044ddd4ddd0000044ddd44000000044ddd440000000444000ddd000000000000000000000000000000
000044444000000000444440444000000040000ddd00000044444ddd000000444440000000004444400000000040000ddd000000000000000000000000000000
000004440000000000044400040000000000000ddd00000004440ddd000000044400000000000444000000000000000ddd000000000000000000000000000000
000000000000000000000000000000000000000ddd00000000000ddd000000000000000000000000000000000000000ddd000000000000000000000000000000
000000000000000000000000000000000000000dd400000000000dd4000000000000000000000000000000000000000dd4000000000000000000000000000000
000000000000000000000000000000000000000d4400000000000d44000000000000000000000000000000000000000d44000000000000000000000000000000
00000000000000000000000000000000000000d4400000000000d44000000000000000000000000000000000000000d440000000000000000000000000000000
00000000000000000000000000000000000000440000000000004400000000000000000000000000000000000000004400000000000000000000000000000000
00000000000000000000000000000000000000400000000000004000000000000000000000000000000000000000004000000000000000000000000000000000
__gff__
0000010200000000000000000000000002000008000000000000000000000000000001100000000000000000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202021212020202000202021212020202000202020202020202000202021212020202000202021212020202000202021212020202000202021212020202000202021212020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0212121212121202000212121212121202000212120202121202000202021212020202000212121212121202000212121212121202000212021212121202000212121212121202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0212020202021202000212121212121202000212120202121202000202021212020202000212121212121202000212121212121202000212021212121202000212020202021202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212021212000202020202121212001212120202121212001212121212121212000202021212020202001212120202020202001212021212121212001212020202021212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212021212121212000202020202121212001212020202021212001212121212121212000202021212020202001212120202020202001212121212021212001212120202121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0212020202021202000212121212121202000212020202021202000202021212020202000212121212121202000212121212121202000212121212021202000212120202121202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0212121212121202000212121212121202000212121212121202000202021212020202000212121212121202000212121212121202000212121212021202000212120202121202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202021212020202000202021212020202000202021212020202000202021212020202000202021212020202000202021212020202000202021212020202000202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010800000c7530c7430c7000f743107330c7000b7330b723000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000662407620086300a6300d635000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000f05012050150500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000015050120500f0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0305000014373143731365217652186521e6522665227655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b06000005650056500565012650136501465021650216502c6503865500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f06000002273042732a2502d25030255000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1708000014373143731365217652186521e65226652276552b6502d65031650206501865011655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000e1501015014150191501d15023150271502b150004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000015150121500f150001000f1500c1500b15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0700000637306070146400f6400b620086200561505600036000160000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17090000256532f65022650216501f6501d650106500f6500f6500265002655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000012150181501d15500000000001e1502415029155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
190f00000d07300000100630000011053000000c05300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b0f00000637306070146400f6400b620086200562004620036200262002620016200162000610006100061000615000000000000000000000000000000000000000000000000000000000000000000000000000
0b0600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0119000023040260402a0402b0403400028040000001c0400000000000000000000000000000000000021040260402b0400000028040000002604000000240400000000000000002304000000210400000023040
0119000023740237402373023730237202372000700007001c7401c7401c7301c7301c7201c720007000070021740217402174021740217302173021730217302172021720217202172021710217102171000700
0119000026740267402673026730267202672000700007001f7401f7401f7301f7301f7201f720007000070024740247402474024740247302473024730247302472024720247202472024710247102471000700
011900002d7402d7402d7302d7302d7202d720007000070026740267402673026730267202672000700007002b7402b7402b7402b7402b7302b7302b7302b7302b7202b7202b7202b7202b7102b7102b71000700
0119000023040260402a0402b0403400028040000001c040000000000000000000000000000000000002a04028040250402500023040000002104000000200400000000000000001e04000000210400000023040
0119000023740237402373023730237202372000700007001c7401c7401c7301c7301c7201c72000700007001e7401e7401e7401e7401e7301e7301e7301e7301e7201e7201e7201e7201e7101e7101e71000700
0119000026740267402673026730267202672000700007001f7401f7401f7301f7301f7201f720007000070021740217402174021740217302173021730217302172021720217202172021710217102171000700
011900002d7402d7402d7302d7302d7202d7200070000700267402674026730267302672026720007000070028740287402874028740287302873028730287302872028720287202872028710287102871000700
0119000023040260402a0402b0403400028040000001c0400000000000000000000000000000000000021040260402b040000002804000000260400000024040000000000000000230400000021040000001f040
011900002304000000000002704000000000002a04000000000002c04000000000002f04000000000001e04000000210400000000000250400000000000210400000024040240000000028040280000000023040
01190000207402074020740207402073020730207302073020720207202072020720207102071020710007001e7401e7401e7301e7301e7201e72000700007002174021740217302173021720217200070000700
011900002374023740237402374023730237302373023730237202372023720237202371023710237100070021740217402173021730217202172000700007002474024740247302473024720247200070000700
011900002a7402a7402a7402a7402a7302a7302a7302a7302a7202a7202a7202a7202a7102a7102a7100070028740287402873028730287202872000700007002b7402b7402b7302b7302b7202b7200070000700
31190000250540000028554000002c554000002f554000002a554000002d55400000315540000034554000002f554000002b55400000285540000023554000002a55400000265540000023554000002055400000
0119000019740197401973019730197201972019710000001e7401e7401e7301e7301e7201e7201e7100000023740237402373023730237202372023710000001e7401e7401e7301e7301e7201e7201e71000000
011900001c7401c7401c7301c7301c7201c7201c71000000217402174021730217302172021720217100000026740267402673026730267202672026710000002174021740217302173021720217202171000000
01190000237402374023730237302372023720237100000028740287402873028730287202872028710000002d7402d7402d7302d7302d7202d7202d710000002874028740287302873028720287202871000000
19190000250540000028554000002c554000002f554000002a554000002d55400000315540000034554000002f554000002b55400000285540000025554000003255400000365540000039554000003b55400000
0119000019740197401973019730197201972019710000001e7401e7401e7301e7301e7201e7201e7100000023740237402374023740237302373023730237302372023720237202372023710237102371000000
011900001c7401c7401c7301c7301c7201c7201c71000000217402174021730217302172021720217100000026740267402674026740267302673026730267302672026720267202672026710267102671000000
01190000237402374023730237302372023720237100000028740287402873028730287202872028710000002d7402d7402d7402d7402d7302d7302d7302d7302d7202d7202d7202d7202d7102d7102d71000000
19190000250540000028554000002c554000002f554000002a554000002d554000003155400000345540000028554000002b554000002f5540000032554000002a55400000265540000023554000002055400000
0119000019740197401973019730197201972019710000001e7401e7401e7301e7301e7201e7201e710000001c7401c7401c7301c7301c7201c7201c710000001e7401e7401e7301e7301e7201e7201e71000000
011900001c7401c7401c7301c7301c7201c7201c7100000021740217402173021730217202172021710000001f7401f7401f7301f7301f7201f7201f710000002174021740217302173021720217202171000000
011900002374023740237302373023720237202371000000287402874028730287302872028720287100000026740267402673026730267202672026710000002874028740287302873028720287202871000000
19190000250540000028554000042c554000042f554000042a554000042d55400004315540000434554000042855400004245540000421554000041e554000042b554000042f5540000432554000043455400000
0119000019740197401973019730197201972019710000001e7401e7401e7301e7301e7201e7201e710000001c7401c7401c7401c7401c7301c7301c7301c7301c7201c7201c7201c7201c7101c7101c71000000
011900001c7401c7401c7301c7301c7201c7201c7100000021740217402173021730217202172021710000001f7401f7401f7401f7401f7301f7301f7301f7301f7201f7201f7201f7201f7101f7101f71000000
011900002374023740237302373023720237202371000000287402874028730287302872028720287100000026740267402674026740267302673026730267302672026720267202672026710267102671000000
011400002574025740257402574025730257302573025730257202572025720257202571025710257100000024740247402473024730247302472024720000001f7401f7401f7301f7301f7301f7201f72000000
011400002974029740297402974029730297302973029730297202972029720297202971029710297100000028740287402873028730287302872028720000002274022740227302273022730227202272000000
01140000307403074030740307403073030730307303073030720307203072030720307103071030710000002e7402e7402e7302e7302e7302e7202e720000002974029740297302973029730297202972000000
01140000227402274022740227402273022730227302273022720227202272022720227102271022710000001f7401f7401f7401f7401f7301f7301f7301f7301f7201f7201f7200000024750247502475000000
011400002574025740257402574025730257302573025730257202572025720257202571025710257100000022740227402274022740227302273022730227302272022720227200000028750287502875000000
011400002c7402c7402c7402c7402c7302c7302c7302c7302c7202c7202c7202c7202c7102c7102c710000002974029740297402974029730297302973029730297202972029720000002e7502e7502e75000000
01140000227402274022740227402273022730227302273022720227202272022720227102271022710000001f7401f7401f7401f7401f7301f7301f7301f7301f7201f7201f7201f7201f7101f7101f71000000
011400002c7402c7402c7402c7402c7302c7302c7302c7302c7202c7202c7202c7202c7102c7102c7100000029740297402974029740297302973029730297302972029720297202972029710297102971000000
01140000227402274022740227402273022730227302273022720227202272022720227102271022710000001f7401f7401f7401f7401f7301f7301f7301f7301f7201f7201f7201f7201f7101f7101f71000000
__music__
01 191a1b1c
00 1d1e1f20
00 211a1b1c
02 22232425
01 26272829
00 2a2b2c2d
00 2e2f3031
02 32333435
01 36373879
00 393a3b7d
00 36373844
02 3c3d3e44

