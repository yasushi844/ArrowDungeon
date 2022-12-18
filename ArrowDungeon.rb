require"dxruby"
require_relative "program/character.rb"

#設定
class Option < Sprite
	attr_accessor :lh,:rh,:lm,:rm,:ls,:rs
	def initialize
		#時間
		@time = 0
		@rs = 0
		@ls = 0
		@rm = 0
		@lm = 0
		@rh = 0
		@lh = 0

		#ランキング
	end
	def time
		@time += 1
		if @time == 60
			@time = 0
			@rs += 1
		end
		if @rs == 10
			@rs = 0
			@ls += 1
		end
		if @ls == 6
			@ls = 0
			@rm += 1
		end
		if @rm == 10
			@rm = 0
			@lm += 1
		end
		if @lm == 6
			@lm = 0
			@rh += 1
		end
		if @rh == 10
			@rh = 0
			@lh += 1
		end
	end
	def ranking(point)
		YAML.dump(point,File.open("ranking/rank.yml","w"))	#ymlファイルに書き込み、保存
	end
end

#文字出力
class FONT < Sprite
	def initialize
		#フォントの宣言
		@font=Font.new(100)
		@font2=Font.new(50)
		@font3=Font.new(25)
		@status_font = Font.new(30)
	end
	#タイトル
	def titel
		Window.draw_font(116, 46,"アロー",@font,:color=>[255,255,255])
		Window.draw_font( 36,146,"ダンジョン",@font,:color=>[255,255,255])
		Window.draw_font(120, 50,"アロー",@font,:color=>[0,0,0])
		Window.draw_font( 40,150,"ダンジョン",@font,:color=>[0,0,0])
		Window.draw_font( 96,346,"ゲームスタート",@font2,:color=>[255,255,255])
		Window.draw_font(101,446,"PUSH ENTER",@font2,:color=>[255,255,255])
		Window.draw_font(100,350,"ゲームスタート",@font2,:color=>[0,0,0])
		Window.draw_font(105,450,"PUSH ENTER",@font2,:color=>[0,0,0])
	end
	#ダンジョン
	def dungeon(key,key_max,enemy_kill,enemy_kill_max,boss_kill,hp,atk,gold,stage,lh,rh,lm,rm,ls,rs,map,player_x,player_y,shop_flag)
		#ステータスの表示
		Window.draw_font( 15, 0,"|MISSION|",@status_font)
		Window.draw_font( 75, 30,"#{key}/#{key_max}",@status_font) if key < key_max
		Window.draw_font( 45, 30,"CLEAR",@status_font,:color=>[0,0,255]) if key >= key_max
		Window.draw_font( 75, 60,"#{enemy_kill}/#{enemy_kill_max}",@status_font) if enemy_kill < enemy_kill_max
		Window.draw_font( 45, 60,"CLEAR",@status_font,:color=>[0,0,255]) if enemy_kill >= enemy_kill_max
		Window.draw_font( 75, 90,"#{boss_kill}/1",@status_font) if boss_kill != 1
		Window.draw_font( 45, 90,"CLEAR",@status_font,:color=>[0,0,255]) if boss_kill == 1
		Window.draw_font(150,  0,"|STATUS|",@status_font)
		Window.draw_font(180, 30,"#{hp}",@status_font)		
		Window.draw_font(180, 60,"#{atk}",@status_font)
		Window.draw_font(180, 90,"#{gold}G",@status_font)		
		Window.draw_font( 300, 0,"STAGE #{stage}",@status_font)
		Window.draw_font( 300,30,"TIME #{lh}#{rh}:#{lm}#{rm}:#{ls}#{rs}",@status_font)
		#コマンド説明
		Window.draw_font(300,60,"移動   　方向キー ",@font3)

		Window.draw_font(300,90,"店に入る　ENTER",@font3) if map[player_y][player_x] == 3 && shop_flag == 0
		Window.draw_font(300,90,"次へ行く　ENTER",@font3) if map[player_y][player_x] == 4 && key == key_max && enemy_kill >= enemy_kill_max
	end
	#ショップ
	def shop(shop_select,hp_max,atk,action_time_max,gold,goldneed)
		Window.draw_font(300,90,"決定　　　ENTER",@font3)

		#ショップでのコマンド操作
		if shop_select >= 1 && shop_select <= 3			
			Window.draw_font( 125,400,"<HPの強化>",@font2) if shop_select == 1
			Window.draw_font( 105,400,"<ATKの強化>",@font2) if shop_select == 2
			Window.draw_font(   0,400,"<アクション時間の延長>",@font2) if shop_select == 3
			Window.draw_font(  25,450,"HP #{hp_max}",@font2) if shop_select == 1
			Window.draw_font( 300,450,"HP #{hp_max+20}",@font2,:color=>[0,0,255]) if shop_select == 1
			Window.draw_font(  25,450,"ATK #{atk}",@font2) if shop_select == 2
			Window.draw_font( 300,450,"ATK #{atk+2}",@font2,:color=>[0,0,255]) if shop_select == 2
			Window.draw_font(  5,450,"ACT #{action_time_max}",@font2) if shop_select == 3
			Window.draw_font( 280,450,"ACT #{action_time_max+30}",@font2,:color=>[0,0,255]) if shop_select == 3
			Window.draw_font( 70,500,"#{gold}",@font2) if shop_select >= 1 && shop_select <= 3
			Window.draw_font( 330,500,"#{gold - goldneed}",@font2,:color=>[0,0,255]) if gold >= goldneed
			Window.draw_font( 330,500,"#{gold - goldneed}",@font2,:color=>[255,0,0]) if gold <  goldneed
		end
		Window.draw_font(  50,400,"<ショップから出る>",@font2) if shop_select >= 4 && shop_select <= 6
	end
	#バトル
	def battle(hp,hp_max,atk,enemy_hp,enemy_atk_max,enemy_gimmick,monster_name,enemy_kind)
		#値の桁数によってフォントの座標をずらす
		@font_x = 0
		@font_x =24 if enemy_hp >= 0   && enemy_hp <= 9
		@font_x =16 if enemy_hp >= 10  && enemy_hp <= 99
		@font_x = 8 if enemy_hp >= 100 && enemy_hp <= 999

		#バトル時の文字を出力
		Window.draw_font( 10,420,"PLAYER",@status_font)											#PLAYERを表示
		Window.draw_font( 80,450,"#{hp}",@font2) if hp > 5 && hp_max != hp 						#hpが普通の状態
		Window.draw_font( 80,450,"#{hp}",@font2, :color=>[255,0,0]) if hp <= hp_max * 3 / 10	#hpが少ない状態
		Window.draw_font( 80,450,"#{hp}",@font2, :color=>[0,155,0]) if hp == hp_max 			#hpがmaxの状態
		Window.draw_font( 80,510,"#{atk}",@font2)												#ATKの数値を表示
		Window.draw_font( 7+@font_x, 55,"#{enemy_hp}",@status_font)								#敵のHPの残量を表示
		Window.draw_font( 60,115,"#{enemy_atk_max}",@font2)										#敵のATKの数値を表示
		Window.draw_font( 60,165,"#{enemy_gimmick}",@font2)										#敵のギミックの数値を表示		 
		Window.draw_font(75, 3,"#{monster_name[enemy_kind-1]}",@font2)							#敵の名前を表示
	end
	def gameover(stage)
		@font_x = 0
		@font_x = 100 if stage < 10
		@font_x = 75 if stage >= 10 && stage < 100 
		Window.draw_font(85,100," GAME",@font,:color=>[200,0,0])
		Window.draw_font(85,200," OVER",@font,:color=>[200,0,0])
		Window.draw_font( 96,296,"STAGE",@font,:color=>[255,255,255])
		Window.draw_font(100,300,"STAGE",@font,:color=>[0,0,0])
		Window.draw_font(111+@font_x,386,"#{stage}",@font,:color=>[255,255,255])
		Window.draw_font(115+@font_x,390,"#{stage}",@font,:color=>[0,0,0])
		Window.draw_font(  56,496,"スタート画面に戻る",@font2,:color=>[255,255,255])
		Window.draw_font( 101,546,"PUSH ENTER",@font2,:color=>[255,255,255])
		Window.draw_font(  60,500,"スタート画面に戻る",@font2,:color=>[0,0,0])
		Window.draw_font( 105,550,"PUSH ENTER",@font2,:color=>[0,0,0])
	end
	def gameclear(stage)
		Window.draw_font( 85,100," GAME",font,:color=>[0,0,200])
		Window.draw_font( 65,200," CLEAR",font,:color=>[0,0,200])
		Window.draw_font( 96,296,"STAGE",font,:color=>[255,255,255])
		Window.draw_font(100,300,"STAGE",font,:color=>[0,0,0])
		Window.draw_font(186,386,"#{stage}",font,:color=>[255,255,255])
		Window.draw_font(190,390,"#{stage}",font,:color=>[0,0,0])
		Window.draw_font( 56,496,"スタート画面に戻る",font2,:color=>[255,255,255])
		Window.draw_font(101,546,"PUSH ENTER",font2,:color=>[255,255,255])
		Window.draw_font( 60,500,"スタート画面に戻る",font2,:color=>[0,0,0])
		Window.draw_font(105,550,"PUSH ENTER",font2,:color=>[0,0,0])
	end
end

#画像出力
class IMAGE < Sprite

	def initialize(monster_name)
		#画像の書き込み
		@attack = Image.load("image/attack.png")
		@attack2 = Image.load("image/attack2.png")
		@defense = Image.load("image/defense.png")
		@defense2 = Image.load("image/defense2.png")
		#ショップ
		@hpup = Image.load("image/hpup.png")
		@attackup = Image.load("image/attackup.png")
		@action_timeup = Image.load("image/action_timeup.png")

		@background_titel = Image.load("image/background_titel.png")
		@background = Image.load("image/background.png")
		@background2 = Image.load("image/background2.png")
		@background_shop = Image.load("image/background_shop.png")

		@square = Image.load("image/square.png")
		@gold_draw = Image.load("image/gold_draw.png")
		@energy_draw = Image.load("image/energy_draw.png")
		@watch = Image.load("image/watch.png")
		@attack_draw = Image.load("image/attack_draw.png")
		@attack_draw2= Image.load("image/attack_draw2.png")
		@attack_draw3 = Image.load("image/attack_draw3.png")
		@defense_draw = Image.load("image/defense_draw.png")
		@gimmick_draw = Image.load("image/gimmick_draw.png")

		@defense_draw2 = Image.load("image/defense_draw2.png")
		@hp_draw = Image.load("image/hp_draw.png")
		@hp_draw2 = Image.load("image/hp_draw2.png")
		@enemyhp_draw = Image.load("image/enemyhp_draw.png")

		@back = Image.load("image/back.png")
		@key_draw = Image.load("image/key_draw.png")
		@enemy_draw = Image.load("image/enemy_draw.png")
		@boss_draw = Image.load("image/boss_draw.png")

		#タイトル用
		@block = Image.load("image/block.png")
		@character= Image.load("image/character.png")
		@enemy = Image.load("image/enemy.png")

		#4方向の矢印
		@ways = [Image.load("image/up.png"),
			Image.load("image/right.png"),
			Image.load("image/down.png"),
			Image.load("image/left.png")]

		#選択中の円
		@circle = Image.load("image/circle.png")

		#はてなマーク
		@question = Image.load("image/question.png")
		
		#ダメージを表示するときのエフェクト
		@damage_effect = Image.load("image/damage_effect.png")
		#モンスターの種類
		@monster = []
		for @count in 0 ... monster_name.length
			@monster[@count] = Image.load("image/enemy/monster#{@count+1}.png")
		end
	end

	def dungeon
		Window.draw( 15, 30,@key_draw)
		Window.draw( 15, 60,@enemy_draw)
		Window.draw( 15, 90,@boss_draw)
		Window.draw(150, 32,@hp_draw2)
		Window.draw(150, 62,@attack_draw3)
		Window.draw(145, 90,@gold_draw)
	end

	def shop(shop_select)
		Window.draw(0,150,@background_shop)
		Window.draw(50,180,@hpup)
		Window.draw(200,180,@attackup)
		Window.draw(350,180,@action_timeup)
#		Window.draw(350,200,defenseup)
		Window.draw(200,290,@back)
		Window.draw( 30,510,@gold_draw) if shop_select >= 1 && shop_select <= 3
		Window.draw(290,510,@gold_draw) if shop_select >= 1 && shop_select <= 3
		Window.draw(48 + (shop_select - 1) % 3 * 150,178,@square) if shop_select >= 1 && shop_select <= 3	
		Window.draw(225,450,@ways[1]) if shop_select >= 1 && shop_select <= 3	
		Window.draw(225,500,@ways[1]) if shop_select >= 1 && shop_select <= 3	
		Window.draw(198,288,@square) if shop_select >= 4 && shop_select <= 6	
	end
	def battle(enemy_x,enemy_y,enemy_kind,alpha)
		Window.draw( 10,450,@hp_draw)															#HPのマークを表示
		Window.draw( 10,510,@attack_draw)														#ATKのマークを表示
		Window.draw(  0, 35,@enemyhp_draw)														#敵のHPバーのマークを表示
		Window.draw( 15,110,@attack_draw)														#敵のATKのマークを表示
		Window.draw( 12,160,@gimmick_draw)														#敵のギミックのマークを表示

		Window.drawAlpha(175 + enemy_x, 100 + enemy_y,@monster[enemy_kind - 1],alpha)			#敵の画像を表示
		Window.draw(250,440,@attack)															#attackのコマンドを表示
		Window.draw(250,520,@defense)															#defenseのコマンドを表示
		Window.draw(250,440,@attack)															#attackのコマンドを表示
		Window.draw(250,520,@defense)															#defenseのコマンドを表示
	end
	def action(mark,turn,command_select,enemy_hp,ways_x,question_y,target,target2,gimmick,angles,inputway_count,input_after,mark_after,input_x,s,input,damage)

		#コマンドの表示
		for @count in 0...5
			Window.draw(100+(@count*60),310,@ways[mark[@count]]) if (turn != 2 && command_select == 4) || enemy_hp <= 0
			Window.draw(100+(@count*60)+ways_x,310,@ways[mark[@count]]) if (command_select >= 1 && command_select <= 3) || enemy_hp <= 0
			Window.draw(100+(@count*60),130+question_y,@question) if command_select == 4 && s >= 60 && turn == 1
			Window.draw(100+(@count*60),310,@ways[mark[@count]]) if target != @count && target2 != @count && turn == 2 && command_select == 4
			Window.drawRot(100+(@count*60),310,@question,angles[@count]) if ((target != @count && target2 != @count) || gimmick != 2) && turn == 2 && command_select == 4
			Window.drawRot(100+(@count*60),310,@question,angles[@count]) if inputway_count <= @count && turn >= 3 && command_select == 4
			Window.draw(100+(@count*60),250,@ways[input[@count]]) if inputway_count > @count && (turn >= 3 || damage >= 0) && command_select == 4
		end
		Window.draw( 40+input_x,250,@ways[input_after]) if (turn != 1 && command_select == 1 && input_after != nil) || enemy_hp <= 0
		Window.draw( 40+ways_x,310,@ways[mark_after]) if ((turn != 1 && command_select == 1 && mark_after != nil) || enemy_hp <= 0) && mark_after != nil
	
	end
end

class BGM < Sprite
	def initialize
		#BGM宣言
		@play_bgm = 0
		@dungeon_bgm = Sound.new("bgm/dungeon_bgm.wav")
		@shop_bgm = Sound.new("bgm/shop_bgm.wav")
		@enemy_bgm = Sound.new("bgm/enemy_bgm.wav")
		@boss_bgm = Sound.new("bgm/boss_bgm.wav")

		#BGMループ
		@dungeon_bgm.loop_count = -1
		@shop_bgm.loop_count = -1
		@enemy_bgm.loop_count = -1
		@boss_bgm.loop_count = -1	
	end
	def play(gamemode,shop_flag,map,player_x,player_y,enemy_hp)
		if @play_bgm == 0
			if gamemode == 1 && shop_flag == 0
				@dungeon_bgm.play
				@play_bgm = 1
			elsif shop_flag == 1
				@shop_bgm.play
				@play_bgm = 2
			elsif gamemode == 2 && map[player_y][player_x] != 4 && enemy_hp > 0
				@enemy_bgm.play
				@play_bgm = 3
			elsif gamemode == 2 && map[player_y][player_x] == 4 && enemy_hp > 0
			@boss_bgm.stop
				@boss_bgm.play
				@play_bgm = 4
			end
		end
	end
	def stop(gamemode,shop_flag,enemy_hp)
		if @play_bgm == 1 && (shop_flag == 1 || gamemode != 1)
			@dungeon_bgm.stop
			@play_bgm = 0			
		elsif @play_bgm == 2 && shop_flag == 0
			@shop_bgm.stop
			@play_bgm = 0
		elsif @play_bgm == 3 && (gamemode != 2 || enemy_hp <= 0)
			@enemy_bgm.stop
			@play_bgm = 0
		elsif @play_bgm == 4 && (gamemode != 2 || enemy_hp <= 0)
			@boss_bgm.stop
			@play_bgm = 0			
		end
	end
end
class SE < Sprite
	def initialize
		@level_up = Sound.new("sound/level_up.wav")
		@start = Sound.new("sound/start.wav")
		@attack = Sound.new("sound/kou.wav")
		@miss = Sound.new("sound/miss.wav")
		@combo_up = Sound.new("sound/combo_up.wav")
		@guard = Sound.new("sound/guard.wav")
		@damage = Sound.new("sound/damage.wav")
		@die = Sound.new("sound/die.wav")

	end
	def play(turn,s,attack_success,t,combo,enemy_hp,gamemode,battleend_s,input,inputway_count,mark,ways_x,level_up_flag)
		@level_up.stop if level_up_flag == 1
		@level_up.play if level_up_flag == 1
		@start.play if (turn == 1 && s == 1) || gamemode == 4
		@attack.play if attack_success == 1 && t == 6
		@miss.play if attack_success == 0 && t == 60
		@combo_up.play if combo % 10 == 0 && combo != 0 && attack_success == 1 && t == 6
		@guard.play if input[inputway_count-1] == mark[inputway_count-1] && ways_x == 60 && turn == 3
		@damage.play if input[inputway_count-1] != mark[inputway_count-1] && ways_x == 60 && turn == 3
		@die.play if enemy_hp == 0 && gamemode == 2 && battleend_s == 1
		@die.stop if enemy_hp == 0 && gamemode == 2 && battleend_s == 59
	end
end
#-----ゲーム設定-----
enemy_speed = 60		#敵が動く速さ
map_size = 20			#マップの大きさ
mapdraw_x = 25			#マップのx軸
mapdraw_y = 125			#マップのy軸
#-----ゲーム設定-----

#-----初期ステータス-----
hp_max	=   100			#体力
atk 	=   5			#攻撃
gold	=   0			#ゴールド
#-----初期ステータス-----

#敵のHPバーを囲む白枠
enemy_hp_lines = [Sprite.new( 68, 58,Image.new(404,  2,C_WHITE)),
				  Sprite.new( 68, 60,Image.new(  2, 25,C_WHITE)),
				  Sprite.new( 68, 85,Image.new(404,  2,C_WHITE)),
				  Sprite.new(470, 60,Image.new(  2, 25,C_WHITE))]
#タイムバーを囲む白枠
time_lines = [Sprite.new( 98,363,Image.new(304,  2,C_WHITE)),
			  Sprite.new( 98,365,Image.new(  2, 25,C_WHITE)),
			  Sprite.new( 98,390,Image.new(304,  2,C_WHITE)),
			  Sprite.new(400,365,Image.new(  2, 25,C_WHITE))]

#-----マップタイルの生成-----
tile_size = 50 	#タイル一つ分の大きさを調整
map_tile = []				#配列の宣言
map_tile[0] = Image.load("image/road.png")					#床
map_tile[1] = Image.load("image/block.png")					#壁
map_tile[2] = Image.load("image/gold.png")					#ゴールド
map_tile[3] = Image.load("image/shop.png")					#ショップ
map_tile[4] = Image.load("image/gate.png")					#扉
map_tile[5] = Image.load("image/key.png")					#鍵
map_tile[6] = Image.load("image/heel.png")					#回復アイテム

map_item = []
map_item[0] = Image.new(50,50,C_DEFAULT)					#何もないところ
map_item[1] = Image.load("image/character.png")				#プレイヤー
map_item[2] = Image.load("image/enemy.png")					#敵
map_item[3] = Image.load("image/boss.png")					#ボス

#-----マップタイルの生成-----


#フォントの宣言
font=Font.new(100)
font2=Font.new(50)
font3=Font.new(25)
status_font = Font.new(30)


#配列の宣言
mark = [0,0,0,0,0]
pointer = Sprite.new(0, 0, Image.new(10, 10))
input = [nil,nil,nil,nil,nil]
angles= [  0,  0,  0,  0,  0]
judge = ["miss","bad","bad","good","great","perfect"]
judgeb= [    0 ,   15,   30,    50,     75,      100]



#-----画面の大きさを設定-----
Window.width = 500
Window.height = 600
#-----画面の大きさを設定-----


#画像の書き込み
attack = Image.load("image/attack.png")
attack2 = Image.load("image/attack2.png")
defense = Image.load("image/defense.png")
defense2 = Image.load("image/defense2.png")
#ショップ
hpup = Image.load("image/hpup.png")
attackup = Image.load("image/attackup.png")
action_timeup = Image.load("image/action_timeup.png")
background_titel = Image.load("image/background_titel.png")
background = Image.load("image/background.png")
background2 = Image.load("image/background2.png")
background_shop = Image.load("image/background_shop.png")
square = Image.load("image/square.png")
gold_draw = Image.load("image/gold_draw.png")
energy_draw = Image.load("image/energy_draw.png")
watch = Image.load("image/watch.png")
attack_draw = Image.load("image/attack_draw.png")
attack_draw2= Image.load("image/attack_draw2.png")
attack_draw3 = Image.load("image/attack_draw3.png")
defense_draw = Image.load("image/defense_draw.png")
gimmick_draw = Image.load("image/gimmick_draw.png")
combo_draw = Image.load("image/combo_draw.png")

defense_draw2 = Image.load("image/defense_draw2.png")
hp_draw = Image.load("image/hp_draw.png")
hp_draw2 = Image.load("image/hp_draw2.png")
enemyhp_draw = Image.load("image/enemyhp_draw.png")

back = Image.load("image/back.png")
key_draw = Image.load("image/key_draw.png")
enemy_draw = Image.load("image/enemy_draw.png")
boss_draw = Image.load("image/boss_draw.png")

#タイトル用
block = Image.load("image/block.png")
character= Image.load("image/character.png")
enemy = Image.load("image/enemy.png")

#4方向の矢印
ways = [Image.load("image/up.png"),
		Image.load("image/right.png"),
		Image.load("image/down.png"),
		Image.load("image/left.png")]
		
#選択中の円
circle = Image.load("image/circle.png")

#はてなマーク
question = Image.load("image/question.png")


#モンスター名(未定)
monster_name = ["トビウオ","幽霊","グリーントカゲ","キョンシー","クロコダイル","剣蛇","化け花","亀","水竜","エイリアン","ペガサス","ゴーレム","ケンタウロス","ビヒモス","オロチ",
				"鎧騎士","ウッドマン","海賊","炎竜","ヒートマシン","緑竜","アーマーナイト"]

#ダメージを表示するときのエフェクト
damage_effect = Image.load("image/damage_effect.png")

#変数宣言
inputway_count = 0
wayflag = 1
a = 0
s = 0
x = 1
y = 1
command = 1
rot = 0
question_x = -1
question_y = -1
gimmick_flag = 0
command_select = 0
target = 0
target2= 0
angle = 0
gimmick = 0
reway = 0
enemy_x = 0
enemy_y = 0
time = 150
damage = -1
enemy_damage = -1
damage_x = 0
damage_s = 0
enemy_gimmick_count = 0
enemy_gimmick = 0
start_time = 150
start_time_max = 150
action_time = 360
action_time_max = 360
battleend_s = 0
enemy_hp_max = -1				#敵の体力
enemy_atk_max = -1				#敵の攻撃力
enemy_hp = enemy_hp_max
shop_flag = 0
regame = 1
hp = hp_max
t = 0
game = 0
flag = 1
turn = 0
stage = 1
enemy_kind = 2
enemy_move = 0
gamemode = 0
enemy_a = 0
enemy_max = 0
map_size = 0
low_level = 0					#一番低いレベル
high_level = 0					#一番高いレベル
shop_select = 1					#ショップでの選択肢
attack_count = 0
add_x = 0
goldneed = 100				#ショップで購入するために必要なお金
map = []						#マップ配列の生成
map2= []						#マップ配列の生成
enemys=[]						#敵を配列に格納
attack_turn = 1
player_x = 0					#プレイヤーのx座標
player_y = 0					#プレイヤーのy座標
key = 0
key_max = 0
start = 1
point = 0
enemy_kill = 0
enemy_kill_max = 0
boss_kill = 0
boss_flag = 0
ways_x = 0
input_x = 0
input_after = nil
mark_after = nil
ways_alpha = 0
attack_success = 0
combo = 0
combo_magnification = 1
area = 1
alpha = 0
#クラスの定義
player = Player.new
status = Status.new
option = Option.new
fonts = FONT.new
images = IMAGE.new(monster_name)
bgms = BGM.new
ses = SE.new
Window.loop do
	#BGMを開始させる
	bgms.play(gamemode,shop_flag,map,player_x,player_y,enemy_hp)

	#SEを開始させる
	ses.play(turn,s,attack_success,t,combo,enemy_hp,gamemode,battleend_s,input,inputway_count,mark,ways_x,player.level_up_flag)

	#背景
	Window.draw(0,0,background_titel) if gamemode == 0 || gamemode == 3 || gamemode == 4
	Window.draw(0,0,background) if gamemode == 2 && map[player_y][player_x] != 4
	Window.draw(0,0,background2) if gamemode == 2 && map[player_y][player_x] == 4
	if gamemode == 1 || gamemode == 2
		option.time
	end
	case gamemode
	#タイトル
	when 0
		fonts.titel
		area += 1 if  Input.key_push?(K_UP)
		area -= 1 if  Input.key_push?(K_DOWN)
		area =  1 if area < 1
		area =  20 if area > 20
		p area if Input.key_push?(K_UP) || Input.key_push?(K_DOWN)
		for y in 0 ... 12
			for x in 0 ... 10
				Window.draw(x*50,y*50,block) if (x== 0|| x == 9 || y == 0 || y == 11) || (x == 4 && y == 8) || (x == 7 && y == 6)
				Window.draw(x*50,y*50,character) if x== 5 && y == 6
				Window.draw(x*50,y*50,enemy) if (x == 2 && y == 5) || (x == 8 && y == 9)
			end
		end

		#Enterを押すとゲームスタート
		gamemode = 1 if  Input.key_push?(K_RETURN)
		#データをリセット
		if start == 1 && gamemode == 1
			key = 0
			key_max = 0
			stage = area
			attack_turn = 1
			regame = 1
			hp_max = 100 + 20 * (area - 1)
			hp = hp_max
			atk =  10 + area - 1
			action_time_max = 360
			gold = 0
			goldneed = 100 + 400 * (area - 1)
			point = 0
			start = 0
			area = 1
			option = Option.new
		end
	#ゲーム開始
	when 1

		#初期の設定
		if regame == 1
			key = 0
			gamemode = 1
			enemy_kill = 0
			boss_kill = 0
			boss_flag = 1
			if map_size % 2 == 0
				map_size -= 1
			end
			map_size = 	stage / 5 * 2 + 9		 				#マップの大きさ
			low_level = (stage + 1) / 2	+ (stage - 1) / 6	 	#最弱モンスターレベル
			high_level = stage / 2 + (stage - 1) / 6 + 2 		#最強モンスターレベル
			
			gold_max = map_size / 5								#マップ内のゴールドの最大生成数
			shop_max = 1										#マップ内のショップの最大生成数
			gate_max = 1										#マップ内のドアの最大生成数
			key_max = map_size / 5								#マップ内の鍵の最大生成数			
			heel_max = map_size / 3 - 2							#マップ内の回復アイテムの最大生成数
			enemy_max = map_size / 3 - 1						#マップ内の敵の最大生成数
			
			enemy_a = enemy_max
			enemy_kill_max = stage / 10 + 1
			map = Array.new(map_size){Array.new(map_size,0)}	#マップ配列の生成
			map2= Array.new(map_size){Array.new(map_size,0)}	#マップ配列の生成
			player_x = 1										#プレイヤーのx座標
			player_y = 1										#プレイヤーのy座標
			map2[player_y][player_x] = 1						#プレイヤーの座標を決める
			#迷路の外枠の壁と迷路製作の軸になる壁を生成
			for i in 0 .. map_size-1
				for j in 0 .. map_size-1
					if ((i == 0 || j == 0 || i == map_size-1 || j == map_size-1) && map[j][i] == 0) ||(i % 2 == 0 && j % 2 == 0 && map[j][i] == 0)
						map[j][i] = 1
					end
				end
			end

			#迷路の壁を生成
			for i in 2 .. map_size-3
				for j in 2 .. map_size-3
					block_cover = 1
					while block_cover == 1
						a = 0
						block_cover = 0
						if i == 2 && j % 2 == 0 && j != 2
							a = Random.rand(6)+1
						elsif i % 2 == 0 && j % 2 == 0 && i != 2
							a = Random.rand(5)+2
						end
						case a
						when 1
							if map[i-1][j] == 0
								map[i-1][j] = 1
							else
								block_cover = 1
							end
						when 2
							if map[i][j-1] == 0
								map[i][j-1] = 1
							else
								block_cover = 1
							end
						when 3
							if map[i][j+1] == 0
								map[i][j+1] = 1
							else
								block_cover = 1
							end
						when 4
							if map[i+1][j] == 0
								map[i+1][j] = 1
							else
								block_cover = 1
							end
						when 5,6
						end
					end
				end
			end

			
			#迷路のアイテムを生成
			map_count = 0			
			while (gold_max + shop_max + gate_max + key_max + heel_max) != map_count
				for i in 2 .. map_size-2
					for j in 2 .. map_size-2
						a = -999
						a = Random.rand(map_size)
						if a == 0 && map[i][j] == 0 && (gold_max + shop_max + gate_max + key_max + heel_max) != map_count
							if gold_max > map_count
								map[i][j] = 2
							elsif gold_max + shop_max > map_count
								map[i][j] = 3
							elsif gold_max + shop_max + gate_max > map_count
								map[i][j] = 4
							elsif gold_max + shop_max + gate_max + key_max > map_count
								map[i][j] = 5
							elsif gold_max + shop_max + gate_max + key_max + heel_max > map_count
								map[i][j] = 6
							end		
							map_count += 1
						end
					end
				end
			end
			
			#敵を生成
			enemys=[]
			enemy_max.times do
				enemys << Enemy.new(map,map2,map_size,tile_size)
			regame = 0
			end
		end
		
		
		#ダンジョン風ゲームの開始

		#文字や画像の出力
		fonts.dungeon(key,key_max,enemy_kill,enemy_kill_max,boss_kill,hp,atk,gold,stage,option.lh,option.rh,option.lm,option.rm,option.ls,option.rs,map,player_x,player_y,shop_flag)
		images.dungeon
	#	Window.draw_font(300,  0,"point #{point}",status_font)

#		Window.draw_font( 50, 75,"#{energy}個",status_font)
		#Window.draw( 11, 80,energy_draw)
		
		#鍵をすべて集めた場合は扉が開いた画像にする
		if key == key_max && enemy_kill >= enemy_kill_max
			map_tile[4] = Image.load("image/gate2.png")#開いている扉
			#扉の前にフロアボスを出現させる
			if boss_flag == 1
				for y in 1 .. map_size-2
					for x in 1 .. map_size-2
						map2[y][x] = 3 if map[y][x] == 4 
					end
				end
			boss_flag = 0
			end
		else
			map_tile[4] = Image.load("image/gate.png")#閉じている扉
		end
		
		#マップをスクロール
		if player_y - 4 < 0
			map_player_y = 4
		elsif player_y + 4 > map_size - 1
			map_player_y = map_size - 5
		else
			map_player_y = player_y
		end
		if player_x - 4 < 0
			map_player_x = 4
		elsif player_x + 4 > map_size - 1
			map_player_x = map_size - 5
		else
			map_player_x = player_x
		end
		
		#右角の位置を合わす
		y2 = 0
		x2 = 0
		
		#自分の周囲マップを表示
		for y in map_player_y - 4..map_player_y + 4
			for x in map_player_x - 4..map_player_x + 4
				Window.draw(x2 * tile_size + mapdraw_x, y2 * tile_size + mapdraw_y, map_tile[map[y][x]] )
				Window.draw(x2 * tile_size + mapdraw_x, y2 * tile_size + mapdraw_y, map_item[map2[y][x]])
				x2 += 1
			end
			x2 = 0
			y2 += 1
		end

		#ショップにいないとき
		if shop_flag == 0
			#モンスターの行動に関する処理
			if enemy_move >= enemy_speed
				enemy_count = 0
				enemys.each do |enemy|
					if enemys[enemy_count] != nil
						enemy.move(enemy_count,map_size)
						if enemy.gamemode == 2
							gamemode = 2
						end
					end
					enemy_count += 1
				end
				enemy_move = 0
			else
				enemy_move += 1
			end

			#プレイヤーの行動(ダンジョン)
			player.move(map,map2,player_x,player_y,stage,hp,hp_max,gamemode,gold,point,key)

			#class Playerから変数の値を引き継ぐ
			gold = player.gold
			point = player.point
			key = player.key
			hp = player.hp
			player_x = player.x
			player_y = player.y
			gamemode = player.gamemode
			map[player_y][player_x] = 0 if map[player_y][player_x] != 3 && map[player_y][player_x] != 4		#ショップと扉以外は通った道を平地にする
			map2[player_y][player_x] = 1																	#プレイヤーの座標を更新


			#ショップにいるとき
			if map[player_y][player_x] == 3 && Input.key_push?(K_RETURN)
				shop_flag = 1
				shop_select = 1
			end			
			#扉にいるとき

			if map[player_y][player_x] == 4 && Input.key_push?(K_RETURN) && key == key_max && enemy_kill >= enemy_kill_max
				#次のステージへ
				point += stage * 100
				gamemode = 4
			end

		#ショップでのコマンド
		elsif shop_flag == 1
			#ショップでの画像出力
			images.shop(shop_select)

			#ショップでの文字出力
			fonts.shop(shop_select,hp_max,atk,action_time_max,gold,goldneed)
			
			#ショップでプレイヤーができること
			player.shop(shop_select,gold,goldneed,hp,hp_max,atk,action_time_max,shop_flag)
			shop_select = player.shop_select
			gold = player.gold
			goldneed = player.goldneed
			hp = player.hp
			hp_max = player.hp_max
			atk = player.atk
			action_time_max = player.action_time_max
			shop_flag = player.shop_flag
			#Window.draw(48 + (shop_select - 1) % 3 * 150,178 + ((shop_select - 1) / 3 * 150),square)
		end
		#バトルモードに突入前にエネミーの読み込みをする
		flag = 1 if gamemode == 2


	#バトルモード
	when 2
		#エネミーの読み込み
		if flag == 1

			#初期設定

			#エネミーの種類を決める
			enemy_kind = rand(2+stage/5) + stage - stage/5 if map[player_y][player_x] != 4
			enemy_kind = stage + 2 if map[player_y][player_x] == 4
			#enemy_hp_max = (enemy_kind - 1) * (((enemy_kind + 1) / 3 + 1) * 50) + 100	#敵の体力を決定
			#enemy_atk_max = enemy_kind / 5 + 99										#敵の攻撃力を決定
			#enemy_gimmick = enemy_kind / 5												#敵のギミック数を決定
			status.enemy(enemy_kind)
			enemy_hp_max  = status.enemy_hp_max			#エネミーの体力
			enemy_atk_max = status.enemy_atk_max 		#エネミーの攻撃力
			enemy_gimmick = status.enemy_gimmick		#エネミーのギミック数

			enemy_hp = enemy_hp_max		#エネミーの体力を入力
			turn = 0
			flag = 0					#読み込みを終了
			command = 1
			command_select = 0			
			attack_turn = 1
			alpha = 255
			enemy_y = 0
			
		end
		#時間を表示するバー
		enemy_hp_bar = Sprite.new( 70, 60,Image.new(400 * enemy_hp / enemy_hp_max , 25,[255 - 255 * enemy_hp / enemy_hp_max,255 * enemy_hp / enemy_hp_max,0])) if 400 * enemy_hp / enemy_hp_max  > 0
		start_time_bar = Sprite.new(100,365,Image.new(300 * start_time / start_time_max , 25,[0,255 * start_time / start_time_max,255])) if (300 * start_time / start_time_max > 0) && start_time > 0 && turn ==  1
		action_time_bar = Sprite.new(100,365,Image.new((300 * action_time / action_time_max), 25,[255,(255 * action_time / action_time_max),0])) if 300 * action_time / action_time_max > 0 && (action_time > 1 && (((turn ==  2 || turn == 3) && command_select >= 1 && command_select <= 3) || ((turn ==  3 || turn == 4) && command_select == 4)) || hp <= 0 || enemy_hp <= 0)
		
		#時間経過
		if turn == 1
			start_time -= 1
		else
			start_time = start_time_max
		end
		
		if turn == 3 && command_select == 4
			action_time -= 1
		elsif command_select == 4 && turn != 4 && hp > 0 && enemy_hp > 0
			action_time = action_time_max
		end
		
		if turn != 1 && command_select >= 1 && command_select <= 3	
			action_time -= 1
		elsif command_select >= 1 && command_select <= 3 && hp > 0 && enemy_hp > 0
			action_time = action_time_max
		end


		Sprite.draw(enemy_hp_bar)																#敵のHPを表示するbar
		Sprite.draw(enemy_hp_lines)																#敵のHPのbarを囲む線

		#バトル時の画像を出力
		images.battle(enemy_x,enemy_y,enemy_kind,alpha)

		#バトル時の文字を出力
		fonts.battle(hp,hp_max,atk,enemy_hp,enemy_atk_max,enemy_gimmick,monster_name,enemy_kind)


		#攻撃するたびいろんな変数をリセットする
		if battleend_s > 0
			command_select = -1
		elsif command_select == 0
			Window.draw_font(95,350,"ENTER START",font2)
			if attack_turn == 1
				#Window.draw_font(70,270,"<PLAYER TURN>",font2,:color=>[0,0,255])
				Window.draw(250,440,attack2)
			elsif attack_turn == 2
				#Window.draw_font(80,270,"<ENEMY TURN>",font2,:color=>[255,0,0])
				Window.draw(250,520,defense2)
			end
			if Input.key_push?(K_RETURN)
				command_select = 1 if attack_turn == 1
				command_select = 4 if attack_turn == 2
				turn = 1
				inputway_count = 0
				input = [nil,nil,nil,nil,nil]
				input_after = nil
				mark_after = nil
				angles= [  0,  0,  0,  0,  0]
				s = 0
				a = -1
				combo = 0
				combo_magnification = 1
				wayflag = 1
				rot = 0
				question_x = -1
				question_y = -1
				gimmick_flag = 1
				damage = -1
				enemy_damage = -1
				enemy_gimmick_count = 0
				ways_x = 0
				attack_success = 0
			end
		end

		#行動時の画像出力
		images.action(mark,turn,command_select,enemy_hp,ways_x,question_y,target,target2,gimmick,angles,inputway_count,input_after,mark_after,input_x,s,input,damage)

		Sprite.draw(start_time_bar) if turn == 1
		Sprite.draw(action_time_bar) if (turn != 1 && command_select >= 1 && command_select <= 3) || ((turn ==  3 || turn == 4) && command_select == 4) || hp <= 0 || enemy_hp <= 0
		Sprite.draw(time_lines) if (turn != 2 && command_select == 4) || (command_select >= 1 && command_select <= 3) || hp <= 0 || enemy_hp <= 0
	#	Window.draw(60,120,attack_draw2) if ((turn ==  2 || turn ==  3) && command_select == 1) || enemy_hp <= 0		#攻撃値の表示バック
		#攻撃値により表示させる場所をずらす
		font_x = 0
		font_x = 30 if enemy_damage <= 9
		font_x = 20 if enemy_damage <= 99 && enemy_damage >= 10
		font_x = 10 if enemy_damage <= 999 &&enemy_damage >= 100
	#	Window.draw_font(70+font_x,140,"#{enemy_damage}",font2,:color=>[255,0,0]) if (turn ==  2 || turn ==  3) && command_select >= 1 && command_select <= 3 || enemy_hp <= 0 #敵に与える攻撃値
		Window.draw(65,350,watch) if turn == 1 || (command_select == 1 && enemy_hp <= 0)																#時計マーク(バーの左端)
		Window.draw(75,350,attack_draw) if command_select == 1 && turn != 1 || enemy_hp <= 0				#攻撃マーク(バーの左端)
		Window.draw(65,355,defense_draw) if (command_select == 4 && turn == 3 || turn == 4) || hp <= 0		#防御マーク(バーの左端)

		#時間を進める
		s += 1 if command_select >= 1 && command_select <= 4
		
		
		#自分のターン
		if command_select == 1
			#矢印を確認
			if turn == 1
				if wayflag == 1
					for x in 0...5
						way_flag = rand(4)
						mark[x] = way_flag
					end
					wayflag = 0
				end
				Window.draw_font(100,240,"<矢印を叩け>",font2,:color=>[0,0,255])

				if s == 150
					turn += 1
					s = 0
					input_x = 60
					ways_x = 0
					question_y = 0
					enemy_damage = 0
					t = 0
				elsif s >= 60
					question_y += 2
					Window.draw(340,130+question_y,question) if enemy_gimmick >= 2
					Window.draw(100,130+question_y,circle)
				end
			#十字キーを入力
			elsif turn == 2
				if action_time == 0
					turn += 1
					s = 0
					question_x = 0
					enemy_x = 0
					enemy_y = 0
					attack_success = 0
				else
					Window.draw(100,310,circle)

					#攻撃時のコマンド入力
					player.arrow(t,enemy_damage,atk,mark,enemy_hp,attack_success,input_after,combo,combo_magnification)
					t = player.t
					enemy_damage = player.enemy_damage
					enemy_hp = player.enemy_hp
					attack_success = player.attack_success
					input_after = player.input_after

					combo = player.combo
					combo_font = 0
					combo_font = 12 if combo <= 9
					Window.draw(375, 95,combo_draw)
					Window.draw_font(400+combo_font,120,"#{combo}",font2)
					combo_magnification = 1.0 if combo <= 9
					combo_magnification = 1.2 if combo >= 10 && combo <= 19
					combo_magnification = 1.5 if combo >= 20 && combo <= 29
					combo_magnification = 2.0 if combo >= 30 && combo <= 39
					combo_magnification = 2.5 if combo >= 40 && combo <= 49
					combo_magnification = 3.0 if combo >= 50
					Window.draw(340,230,attack_draw) if combo >= 10
					Window.draw_font(380,230,"#{combo_magnification}倍",font2) if combo >= 10
					#成功、失敗のエフェクト
					input_x = 60 if (t == 6 || t == 60) || enemy_hp <= 0	
					ways_x = 60 if t == 6 && enemy_hp > 0 && attack_success == 1
					ways_x = 0 if enemy_hp <= 0

					if t <= 6 && ways_x != 0 && enemy_hp > 0 && attack_success == 1
						#矢印をずらす
						if ways_x == 60
							mark_after = mark[0]
							for x in 0...4
								mark[x] = mark[x+1] 
							end
							mark[4] = rand(4)
						end
						input_x-= 10
						ways_x -= 10
						if attack_success == 1
							attack_success = 0 if t == 1
							enemy_x += 10 if t == 1 || t == 6 
							enemy_x -=  5 if t >= 2 && t <= 5 
							enemy_y +=  5 if t == 6
							enemy_y -=  5 if t == 1
						end
					elsif t >= 9
						ways_x += 1 if (t % 10 >= 5 && (t / 10) % 2 == 1) || (t % 10 < 5 && (t / 10) % 2 == 0)
						ways_x -= 1 if (t % 10 >= 5 && (t / 10) % 2 == 0) || (t % 10 < 5 && (t / 10) % 2 == 1)
					end
					input_after = nil if t == 2 && attack_success == 0
				end
				if enemy_gimmick >= 2
					add_x = -3 if question_x >= 180
					add_x =  3 if question_x <= 0
					question_x += add_x
					Window.draw(340-question_x,310,question)
				end
			elsif turn == 3
				if s == 1
					#それぞれのコマンド
				#	enemy_hp  -= enemy_damage
					point += enemy_damage * 1
					hp += 3  if command_select == 2
					attack_count = 0
					wayflag = 1
				end
				if s == 60
					add_x = 0
					command_select = 0
					s = 0
					turn = 0
					attack_turn = 2
					attack_success = 0
				end
			end
		#敵の攻撃
		elsif command_select == 4
			if turn == 1
				if wayflag == 1
					for x in 0...5
						way_flag = rand(4)
						mark[x] = way_flag
					end
					wayflag = 0
				end
				if s >= 60
					question_y += 2
				end
				Window.draw_font(70,240,"<矢印を覚えろ>",font2,:color=>[255,0,0])
				if s == 150
					question_y = 0
					turn += 1 if enemy_gimmick != 0
					turn += 2 if enemy_gimmick == 0
					s = 0
				end
			elsif turn == 2
				gimmick = rand(3)+1 if gimmick_flag == 1
				target = rand(5) if gimmick_flag == 1
				gimmick_flag = 0
				#回転
				if gimmick == 1
					angle = rand(3)+1 if s == 1
					angles[target] += angle * 1.5 if s <= 60
					if s == 60
						mark[target] += angle
						mark[target] -= 4	if mark[target] >= 4
						s = 0
						gimmick_flag = 1
						enemy_gimmick_count += 1
						turn += 1 if enemy_gimmick_count == enemy_gimmick
					end
				#入れ替え
				elsif gimmick == 2
					if s == 1
						target2 = -1
						while target2 == -1 || target == target2
							target2 = rand(5)
						end
					end
					if s <= 15
						question_y += 4
					elsif s <= 45
						question_x -= (target - target2) * 2
					elsif s <= 60
						question_y -= 4
					end

					Window.drawRot(100+(target *60)+question_x,310+question_y,question,angles[target])
					Window.drawRot(100+(target2*60)-question_x,310-question_y,question,angles[target2])
					if s == 60
						f = mark[target]
						mark[target] = mark[target2]
						mark[target2]= f
						f = angles[target]
						angles[target] = angles[target2]
						angles[target2]= f	
						s = 0
						question_x = 0
						question_y = 0
						gimmick_flag = 1
						enemy_gimmick_count += 1
						turn += 1 if enemy_gimmick_count == enemy_gimmick
					end
				#入れ替え(一個)
				elsif gimmick == 3
					if s == 1
						reway = mark[target]
						while mark[target] == reway
							reway = rand(4)
						end
						ways_alpha = 255
					end
					if s <= 60
						question_y -= 2
					end
					if ways_alpha > 0 && s >= 30
						ways_alpha -= 8
						ways_alpha = 0 if ways_alpha < 0
					end
					Window.drawAlpha(100+(target*60),430+question_y,ways[reway],ways_alpha)
					if s == 60
						mark[target] = reway
						s = 0
						gimmick_flag = 1
						question_y = 0
						enemy_gimmick_count += 1
						ways_x = 0
						gimmick = 0
						turn += 1 if enemy_gimmick_count == enemy_gimmick
					end
				end
			elsif turn == 3
				if inputway_count == mark.length || action_time == 0
					turn += 1
					s = 0
				else
					ways_x -= 10 if ways_x > 0
					Window.draw(100+(inputway_count*60)-ways_x,310,circle)
						if Input.key_push?(K_UP)
							input[inputway_count] = 0
						elsif Input.key_push?(K_RIGHT)
							input[inputway_count] = 1
						elsif Input.key_push?(K_DOWN)
							input[inputway_count] = 2
						elsif Input.key_push?(K_LEFT)
							input[inputway_count] = 3
						end
					if input[inputway_count] != nil
						inputway_count += 1
						ways_x = 60
					end
				end
			elsif turn == 4
				if a == -1
					a = 0
					for x in 0...5
						if input[x] == mark[x]
							a += 1
						end
					end
				end
				if s == 1
					enemy_damage = (5 - a) * enemy_atk_max
					hp -= enemy_damage
					wayflag = 1
					attack_turn = 1
				end
				if enemy_damage == 0
					Window.draw(115,450 - s,defense_draw2)
					Window.draw_font(153,475 - s,"0",font2,:color=>[0,0,255])
					point += enemy_kind * 3
				else
					Window.draw(90,450 - s,damage_effect)
					font_x = 0
					font_x = 30 if enemy_damage <= 9
					font_x = 20 if enemy_damage <= 99 && enemy_damage >= 10
					font_x = 10 if enemy_damage <= 999 &&enemy_damage >= 100
					Window.draw_font(120+font_x,475 - s,"#{enemy_damage}",font2,:color=>[255,0,0])
				end
				if s == 60
					turn = 0
					s = 0
					command_select = 0
					enemy_damage = 0
				end

			end
		end
		#敵に対するダメージ表記
		if damage >= 0
			damage_x = 0 if damage < 10000 && damage > 999
			damage_x =12 if damage < 1000  && damage > 99
			damage_x =25 if damage < 100   && damage > 9
			damage_x =37 if damage < 10    && damage >=0
			damage_s += 1
			Window.draw(275,150-damage_s,damage_effect)
			Window.draw_font(300+damage_x,175-damage_s,"#{damage}",font2,:color=>[255,0,0])
			if damage_s == 60
				damage_s = 0
				damage_x = 0
				damage = -1
			end
		end
		#自分のHPを調節
		if hp <= 0
			battleend_s += 1
			hp = 0
			if battleend_s == 60
				battleend_s = 0
				gamemode = 3
			end
		elsif hp > hp_max
			hp = hp_max
		end
		#敵のHPを調節
		if enemy_hp <= 0
			enemy_hp = 0
			battleend_s += 1
			alpha -= 4
			enemy_x += 15 if battleend_s % 10 >= 8 || battleend_s % 10 <= 2
			enemy_x -= 15 if battleend_s % 10 >= 3 && battleend_s % 10 <= 7 
			if battleend_s == 60
				battleend_s = 0
				enemy_kill += 1 if map[player_y][player_x] != 4
				boss_kill = 1 if map[player_y][player_x] == 4
				point += enemy_kind * 50
				gold += rand(enemy_hp_max) + enemy_hp_max * 5
				enemy_move = -30
				gamemode = 1
				enemy_hp_max = -1
				enemy_max -= 1
				enemy_a.times do |enemy_count|
					if enemys[enemy_count] != nil
						if enemys[enemy_count].x == player_x && enemys[enemy_count].y == player_y
							enemys[enemy_count] = nil
						end
					end
					enemy_count += 1
				end
			elsif battleend_s > 0
				enemy_y += 1
			end
		elsif enemy_hp > enemy_hp_max
			enemy_hp = enemy_hp_max
		end
	when 3

		#ゲームオーバー画面
		fonts.gameover(stage)

		#Enterを押すとスタート画面
		gamemode = 0 if  Input.key_push?(K_RETURN)
		start = 1 if  Input.key_push?(K_RETURN)

	when 4

		#ゲームクリア画面
		if stage == 20
			fonts.gameclear(stage)

			#Enterを押すとスタート画面
			gamemode = 0 if  Input.key_push?(K_RETURN)
			start = 1 if  Input.key_push?(K_RETURN)
		else
			#次のステージへ
			hp += (hp_max - hp) / 2 + 1
			hp = hp_max if hp > hp_max
			regame = 1
			gamemode = 1
			stage += 1
		end
	end

	#BGMを終了させる
	bgms.stop(gamemode,shop_flag,enemy_hp)
end
