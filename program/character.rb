#encoding: Shift_JIS

#プレイヤー
class Player <Sprite
	attr_accessor :map,:map2,:x,:y,:gamemode,:gold,:hp,:key,:point
	def initialize()
		@t = 0
	end
	def move(map,map2,player_x,player_y,stage,hp,hp_max,gamemode,gold,point,key)
		@x = player_x
		@y = player_y
		@gamemode = gamemode
		@gold = gold
		@point = point
		@key = key
		@hp = hp
		@hp_max = hp_max

		#-----プレイヤーを操作-----
		if (Input.key_down?(K_UP) && @t == 0) && (map[@y-1][@x] != 1 || map2[@y-1][@x] == 1)
			map2[@y][@x] = 0
			@y -= 1
			@t = 10
		elsif (Input.key_down?(K_LEFT) && @t == 0) && (map[@y][@x-1] != 1 || map2[@y][@x-1] == 1)
			map2[@y][@x] = 0
			@x -= 1
			@t = 10
		elsif (Input.key_down?(K_RIGHT) && @t == 0) && (map[@y][@x+1] != 1 || map2[@y][@x+1] == 1)
			map2[@y][@x] = 0
			@x += 1
			@t = 10
		elsif (Input.key_down?(K_DOWN) && @t == 0) && (map[@y+1][@x] != 1 || map2[@y+1][@x] == 1)
			map2[@y][@x] = 0
			@y += 1
			@t = 10
		elsif @t != 0 && (Input.key_down?(K_UP)||Input.key_down?(K_LEFT)||Input.key_down?(K_RIGHT)||Input.key_down?(K_DOWN) || Input.key_down?(K_SPACE))
			@t -= 1
		else
			@t = 0
		end

		#移動をした時
		if @t == 10
			@gamemode = 2 if map2[@y][@x] == 2 || map2[@y][@x] == 3								#敵と当たった場合
			@gold += stage * 100 if map[@y][@x] == 2											#ゴールドと当たった場合
			@point += stage * 10 if map[@y][@x] == 2
			@key += 1 if map[@y][@x] == 5														#鍵と当たった場合
			@point += 50 if map[@y][@x] == 5
			@hp += @hp_max * 3 / 10 if map[@y][@x] == 6											#回復アイテムと重なった場合
			@hp = @hp_max if @hp_max < @hp														#体力の上限を超えた場合
		end
	end

	attr_accessor :shop_select,:gold,:goldneed,:hp,:hp_max,:atk,:action_time_max,:shop_flag,:level_up_flag
	def shop(shop_select,gold,goldneed,hp,hp_max,atk,action_time_max,shop_flag)
			@shop_flag = shop_flag
			@shop_select = shop_select
			@hp = hp
			@hp_max = hp_max
			@atk = atk
			@action_time_max = action_time_max
			@gold = gold
			@goldneed = goldneed
			@level_up_flag = 0
			#カーソル移動
			@shop_select += 1 if (shop_select - 1) % 3 != 2 && Input.key_push?(K_RIGHT)
			@shop_select -= 1 if (shop_select - 1) % 3 != 0 && Input.key_push?(K_LEFT)
			@shop_select += 3 if (shop_select - 1) / 3 != 1 && Input.key_push?(K_DOWN)
			@shop_select -= 3 if (shop_select - 1) / 3 != 0 && Input.key_push?(K_UP)
			
			#ショップでものを買ったときの処理
			if @gold >= @goldneed && @shop_select >= 1 && @shop_select <= 3 && Input.key_push?(K_RETURN)
				@hp += 20 if shop_select == 1
				@hp_max += 20 if shop_select == 1
				@atk += 2 if shop_select == 2
				@action_time_max += 30 if shop_select == 3
				@gold -= @goldneed
				@goldneed += 400
				@level_up_flag = 1
			end
			
			#ショップから戻る
			@shop_flag = 0 if Input.key_push?(K_RETURN) && shop_select >= 4 && shop_select <= 6

	end
	attr_accessor :t,:enemy_damage,:enemy_hp,:attack_success,:input_after,:combo
	def arrow(t,enemy_damage,atk,mark,enemy_hp,attack_success,input_after,combo,combo_magnification)
		@enemy_damage = enemy_damage
		@enemy_hp = enemy_hp
		@attack_success = attack_success
		@t = t
		@input_after = input_after
		@combo = combo
		#時間経過
		@t -= 1 if @t != 0
		if (Input.key_push?(K_UP) || Input.key_push?(K_RIGHT) || Input.key_push?(K_DOWN) || Input.key_push?(K_LEFT)) && @t == 0
			if Input.key_push?(K_UP)
				@enemy_damage += (atk * combo_magnification).to_i   if mark[0] == 0
				@enemy_hp -= (atk * combo_magnification).to_i   if mark[0] == 0
				@attack_success = 1 if mark[0] == 0
				@t += 54 if mark[0] != 0
				@input_after = 0
				@combo += 1  if mark[0] == 0
				@combo = 0  if mark[0] != 0
			elsif Input.key_push?(K_RIGHT)
				@enemy_damage += (atk * combo_magnification).to_i    if mark[0] == 1
				@enemy_hp -= (atk * combo_magnification).to_i    if mark[0] == 1
				@attack_success = 1 if mark[0] == 1
				@t += 54 if mark[0] != 1
				@input_after = 1
				@combo += 1  if mark[0] == 1
				@combo = 0  if mark[0] != 1
			elsif Input.key_push?(K_DOWN)
				@enemy_damage += (atk * combo_magnification).to_i    if mark[0] == 2
				@enemy_hp -= (atk * combo_magnification).to_i    if mark[0] == 2
				@attack_success = 1 if mark[0] == 2
				@t += 54 if mark[0] != 2
				@input_after = 2
				@combo += 1  if mark[0] == 2
				@combo = 0  if mark[0] != 2
			elsif Input.key_push?(K_LEFT)
				@enemy_damage += (atk * combo_magnification).to_i    if mark[0] == 3
				@enemy_hp -= (atk * combo_magnification).to_i    if mark[0] == 3
				@attack_success = 1 if mark[0] == 3
				@t += 54 if mark[0] != 3
				@input_after = 3
				@combo += 1  if mark[0] == 3
				@combo = 0  if mark[0] != 3
			end
			@t += 6 if @enemy_hp > 0 #再度入力するための時間
		end
	end
end

#エネミー
class Enemy <Sprite
	attr_accessor :map2,:gamemode,:enemy
	def initialize(map,map2,map_size,tile_size)
		@check = 0
		@map_size = map_size
		@tile_size = tile_size
		@map = map
		@map2 = map2
		@wall_count = 0
		@old_mode = []
		while @check == 0
			@wall_count = 0
			self.x=Random.rand(@map_size - 5) + 3
			self.y=Random.rand(@map_size - 5) + 3
			if map[self.y-1][self.x] == 1
				@wall_count += 1
			end
			if map[self.y][self.x-1] == 1
				@wall_count += 1
			end
			if map[self.y][self.x+1] == 1
				@wall_count += 1
			end
			if map[self.y+1][self.x] == 1
				@wall_count += 1
			end
			if @map[self.y][self.x] == 0 && @map2[self.y][self.x] == 0 && @wall_count != 4
				@check = 1
				map2[self.y][self.x] = 2
			end
		end
	end
	def move(enemy_count,map_size)
		@mode = []
		@check = 0
 		@flag = 0
		@wall_count = 0
		@gamemode = 1
		if @map[self.y-1][self.x] == 1
			@wall_count += 1
		end
		if @map[self.y][self.x-1] == 1
			@wall_count += 1
		end
		if @map[self.y][self.x+1] == 1
			@wall_count += 1
		end
		if @map[self.y+1][self.x] == 1
			@wall_count += 1
		end
		while @check == 0
			if map2[self.y-1][self.x] == 1 && @flag == 0
				@mode[enemy_count] = 1
			elsif map2[self.y][self.x-1] == 1 && @flag == 0
				@mode[enemy_count] = 2
			elsif map2[self.y][self.x+1] == 1 && @flag == 0
				@mode[enemy_count] = 3
			elsif map2[self.y+1][self.x] == 1 && @flag == 0
				@mode[enemy_count] = 4
			elsif @wall_count == 2 && @old_mode[enemy_count] == 1 && (@map[self.y-1][self.x] == 0 || @map[self.y-1][self.x] == 2) && @flag == 0
				@mode[enemy_count] = @old_mode[enemy_count]
			elsif @wall_count == 2 && @old_mode[enemy_count] == 2 && (@map[self.y][self.x-1] == 0 || @map[self.y][self.x-1] == 2) && @flag == 0
				@mode[enemy_count] = @old_mode[enemy_count]
			elsif @wall_count == 2 && @old_mode[enemy_count] == 3 && (@map[self.y][self.x+1] == 0 || @map[self.y][self.x+1] == 2) && @flag == 0
				@mode[enemy_count] = @old_mode[enemy_count]
			elsif @wall_count == 2 && @old_mode[enemy_count] == 4 && (@map[self.y+1][self.x] == 0 || @map[self.y+1][self.x] == 2) && @flag == 0
				@mode[enemy_count] = @old_mode[enemy_count]
			else
				@mode[enemy_count] = Random.rand(4)+1
			end
			if @mode[enemy_count] == 1 && @map[self.y-1][self.x] != 1 && @map[self.y-1][self.x] != 4 && map2[self.y-1][self.x] != 2
				@gamemode = 2 if map2[self.y-1][self.x] == 1
				map2[self.y][self.x] = 0
				map2[self.y-1][self.x] = 2
				self.y -= 1
				@check = 1
			elsif @mode[enemy_count] == 2 && @map[self.y][self.x-1] != 1 && @map[self.y][self.x-1] != 4 &&  map2[self.y][self.x-1] != 2
				@gamemode = 2 if map2[self.y][self.x-1] == 1
				map2[self.y][self.x] = 0
				map2[self.y][self.x-1] = 2
				self.x -= 1
				@check = 1
			elsif @mode[enemy_count] == 3 && @map[self.y][self.x+1] != 1 && @map[self.y][self.x+1] != 4 && map2[self.y][self.x+1] != 2
				@gamemode = 2 if map2[self.y][self.x+1] == 1
				map2[self.y][self.x] = 0
				map2[self.y][self.x+1] = 2
				self.x += 1
				@check = 1
			elsif @mode[enemy_count] == 4 && @map[self.y+1][self.x] != 1 && @map[self.y+1][self.x] != 4 && map2[self.y+1][self.x] != 2
				@gamemode = 2 if map2[self.y+1][self.x] == 1
				map2[self.y][self.x] = 0
				map2[self.y+1][self.x] = 2
				self.y += 1
				@check = 1
			elsif (@map[self.y-1][self.x] == 1 || @map[self.y-1][self.x] == 4 || @map2[self.y-1][self.x] == 2) && (@map[self.y][self.x-1] == 1 || @map[self.y][self.x-1] == 4 || @map2[self.y][self.x-1] == 2) && (@map[self.y][self.x+1] == 1 || @map[self.y][self.x+1] == 4 || @map2[self.y][self.x+1] == 2) && (@map[self.y+1][self.x] == 1 || @map[self.y+1][self.x] == 4 || @map2[self.y+1][self.x] == 2)
				@check = 1
			else
				@flag = 1
			end
		end
		@old_mode[enemy_count] = @mode[enemy_count]
	end
	def die(enemy_max,player_x,player_y,map_size,enemy_count,enemy)
		if self.x == player_x && self.y == player_y
			enemy[enemy_count].vanish
		end
	end
end

class Status <Sprite
	attr_accessor :enemy_hp_max,:enemy_atk_max,:enemy_gimmick
	def initialize
		@enemy_hp_max = 0
		@enemy_atk_max = 0
		@enemy_gimmick = 0
	end
	def enemy(enemy_kind)
		#エネミーの個体能力を決定
		case enemy_kind
		when 1#トビウオ
			@enemy_hp_max  = 200
			@enemy_atk_max = 10
			@enemy_gimmick = 0
		when 2#幽霊
			@enemy_hp_max  = 300
			@enemy_atk_max = 15
			@enemy_gimmick = 0
		when 3#トカゲ
			@enemy_hp_max  = 400
			@enemy_atk_max = 20
			@enemy_gimmick = 0
		when 4#キョンシー
			@enemy_hp_max  = 600
			@enemy_atk_max = 15
			@enemy_gimmick = 1
		when 5#クロコダイル
			@enemy_hp_max  = 900
			@enemy_atk_max = 25
			@enemy_gimmick = 0
		when 6#剣蛇
			@enemy_hp_max  = 1200
			@enemy_atk_max = 35
			@enemy_gimmick = 0
		when 7#化け花
			@enemy_hp_max  = 1600
			@enemy_atk_max = 15
			@enemy_gimmick = 1
		when 8#亀
			@enemy_hp_max  = 1500
			@enemy_atk_max = 35
			@enemy_gimmick = 0
		when 9#水竜
			@enemy_hp_max  = 2000
			@enemy_atk_max = 30
			@enemy_gimmick = 1
		when 10#エイリアン
			@enemy_hp_max  = 2000
			@enemy_atk_max = 25
			@enemy_gimmick = 2
		when 11#ペガサス
			@enemy_hp_max  = 2400
			@enemy_atk_max = 30
			@enemy_gimmick = 2
		when 12#ゴーレム
			@enemy_hp_max  = 4500
			@enemy_atk_max = 30
			@enemy_gimmick = 0
		when 13#ケンタウロス
			@enemy_hp_max  = 2500
			@enemy_atk_max = 50
			@enemy_gimmick = 0
		when 14#ビヒモス
			@enemy_hp_max  = 2750
			@enemy_atk_max = 35
			@enemy_gimmick = 1
		when 15#オロチ
			@enemy_hp_max  = 3000
			@enemy_atk_max = 40
			@enemy_gimmick = 1
		when 16#鎧
			@enemy_hp_max  = 4500
			@enemy_atk_max = 50
			@enemy_gimmick = 0
		when 17#ウッドマン
			@enemy_hp_max  = 3000
			@enemy_atk_max = 10
			@enemy_gimmick = 5
		when 18#海賊幽霊
			@enemy_hp_max  = 3500
			@enemy_atk_max = 50
			@enemy_gimmick = 1
		when 19#炎竜
			@enemy_hp_max  = 4000
			@enemy_atk_max = 75
			@enemy_gimmick = 0
		when 20#ヒートマシン
			@enemy_hp_max  = 5000
			@enemy_atk_max = 30
			@enemy_gimmick = 2
		when 21#竜
			@enemy_hp_max  = 6000
			@enemy_atk_max = 50
			@enemy_gimmick = 2
		when 22#アーマーナイト
			@enemy_hp_max  = 9999
			@enemy_atk_max = 75
			@enemy_gimmick = 3
		end
	end
end
