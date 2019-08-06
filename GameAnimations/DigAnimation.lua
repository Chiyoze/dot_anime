local dig_anime = {}
dig_anime.script_path = obj.getinfo("script_path")

-- ////////// テスト用 //////////
dig_anime.title = "DigAnimation"
dig_anime.isDebug = isGA_Debug
dig_anime.count = 0
-- ////////// テスト用 //////////

-- ////////// 時間計測 //////////
dig_anime.current_time = 0
dig_anime.prev_time = 0
-- ////////// 時間計測 //////////

-- ////////// 乱数種 //////////
dig_anime.seed = 111		-- [int]:	ベースとなる乱数種
-- ////////// 乱数種 //////////

-- ////////// ディスプレイ //////////
dig_anime.display_x = 0		-- [pixle]: 	表示開始位置(左上端)
dig_anime.display_y = 0		-- [pixle]: 	表示開始位置(左上端)
dig_anime.block_size = 50	-- [pixle]: 	デバッグ用ブロックサイズ
dig_anime.img_width = 128 	-- [pixel]: 	読み込み画像(ブロック、キャラ)の幅
dig_anime.img_height = 128 	-- [pixel]:	読み込み画像(ブロック、キャラ)の高さ
dig_anime.chara_width = 256 	-- [pixel]: 	読み込み画像(ブロック、キャラ)の幅
dig_anime.speed = GA_Speed	-- [int]:	再生速度
dig_anime.fps= 1 / GA_FPS	-- [int]:	画像更新速度
-- ////////// ディスプレイ //////////

-- ////////// マップ //////////
dig_anime.map = {}			-- [array]:		マップ本体
dig_anime.map_width = obj.track0	-- [array index]:	マップの幅
dig_anime.map_height = obj.track1	-- [array index]:	マップの高さ
dig_anime.view_width = obj.track2	-- [array index]:	表示範囲(幅)
dig_anime.view_height = obj.track3	-- [array index]:	表示範囲(高さ)
dig_anime.view_index_x = 1		-- [array index]:	表示開始位置(x軸)
dig_anime.view_index_y = 1		-- [array index]:	表示開始位置(y軸)
dig_anime.view_x = 0			-- [pixle]:	 	表示開始座標(x軸)
dig_anime.view_y = 0			-- [pixle]: 		表示開始座標(y軸)
dig_anime.wall_depth = 2		-- [int]:		描画するマップ外のブロック数
-- ////////// マップ //////////

-- ////////// ブロックデータ //////////
dig_anime.check_range = 5	-- [pixel]:	ブロックに触れる距離
dig_anime.rebound = 1		-- [int]:	ブロックに触れた時の反発係数(反発速度のn倍分戻る)
dig_anime.rebound_speed = 5	-- [int]:	ブロックに触れた時の反発速度
dig_anime.max_num = 20		-- [int]:	ブロック番号の最大値(max_num: empty, +1: GOAL, +2~: Player)
dig_anime.map_bias = 3		-- [int]:	マップ内の破壊不能ブロック判定(広告名挿入開始ブロック予定)
-- ////////// ブロックデータ //////////

-- ##########▼ キャラデータ ▼##########
dig_anime.num_character = 0	-- [int]:	キャラ数
dig_anime.character = {}	-- [array]:	キャラリスト

  -- キャラクターを生成
  -- //////////- Parameter -//////////
  -- pos_x: 初期座標(x軸)	[array index]
  -- pos_y: 初期座標(y軸)	[array index]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- None: nil
  -- /////////////////////////////////
dig_anime.create_character = function(this, pos_x, pos_y)
  this.num_character = this.num_character + 1
  local num = this.num_character

  -- キャラクター情報
  this.character[num] = {}
  this.character[num].state = 0			-- [int]	状態(0: なし, 1: ブロック破壊, 2: 移動, 3:ジャンプ)
  this.character[num].prev_state = 0		-- [int]	前回の状態(0: なし, 1: ブロック破壊, 2: 移動, 3:ジャンプ)
  this.character[num].img_state = "a"		-- [inr]	画像遷移状態(a → b → c → a → b → ... )
  this.character[num].direction = 0		-- [int]	移動方向(0: なし, 1: 右, 2: 左, 3:下, 4: 上)
  this.character[num].pos_x = pos_x		-- [array index]現在配置されているブロック座標(x軸)
  this.character[num].pos_y = pos_y		-- [array index]現在配置されているブロック座標(y軸)
  this.character[num].move_x = 0		-- [pixel]	現在配置されているブロックとの相対座標(x軸)
  this.character[num].move_y = 0		-- [pixel]	現在配置されているブロックとの相対座標(y軸)
  this.character[num].move_speed = 15		-- [pixel]	移動速度
  this.character[num].drop_speed = 25		-- [pixel]	落下速度
  this.character[num].isMoveArray = false	-- [boolean]	配列を移動する必要がある場合にtrue
  this.character[num].isWait = true		-- [boolean]	待機状態の場合にtrue

  -- [path]: 画像ファイル
  this.character[num].img_file = this.script_path.."GameAnimations/img/chara/"..string.format("%03d", num).."/"..string.format("%03d", num).."-00a.png"

  -- 探索用データ
  this.character[num].route_map = {}		-- 探索用深度マップ
  this.character[num].direction_map = {}	-- 探索用方位マップ
  this.character[num].explored_map = {}		-- 探索用記録マップ

  this:image_state(num, 0)
end
-- ##########▲ キャラデータ ▲##########

-- ##########▼ 汎用処理 ▼##########
  -- 配列内の最大値を取得
  -- //////////- Parameter -//////////
  -- array: 探索する配列				[array]
  -- width: 配列の幅					[int]
  -- height: 配列の高さ					[int]
  -- max_value: 初期最大値				[value]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- max_value: 最大値					[value]
  -- /////////////////////////////////
dig_anime.get_max = function(this, array, width, height, max_value)
  for i = 1, height do
    for j = 1, width do
      if array[i][j] > max_value then
        max_value = array[i][j]
      end
    end
  end
  return max_value
end

  -- 配列内の最小値を取得
  -- //////////- Parameter -//////////
  -- array: 探索する配列				[array]
  -- width: 配列の幅					[int]
  -- height: 配列の高さ					[int]
  -- min_value: 初期最小値				[value]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- min_value: 最小値				[value]
  -- /////////////////////////////////
dig_anime.get_min = function(this, array, width, height, min_value)
  for i = 1, height do
    for j = 1, width do
      if array[i][j] < min_value then
        min_value = array[i][j]
      end
    end
  end
  return min_value
end
-- ##########▲ 汎用処理 ▲##########

-- ##########▼ デバッグ用 ▼##########
  -- デバッグ内容を描画
  -- //////////- Parameter -//////////
  -- this: self
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- None: nil
  -- /////////////////////////////////
dig_anime.debug = function(this, num)
  -- 仮想バッファを新規作成しターゲットをそちらに移す
  obj.setoption("drawtarget","tempbuffer", obj.screen_w, obj.screen_h)

  obj.load("text", "探索回数:")
  obj.draw(-755, -500)
  obj.load("text", this.count)
  obj.draw(-620, -500)

  obj.load("text", "キャラ数:")
  obj.draw(-740, -450)
  obj.load("text", this.num_character)
  obj.draw(-620, -450)

  if this.num_character >= num and num > 0 then
    obj.load("text", "キャラ番:")
    obj.draw(-770, -160)
    obj.load("text", num)
    obj.draw(-670, -160)

    obj.load("text", "state:")
    obj.draw(-850, -110)
    obj.load("text", this.character[num].state)
    obj.draw(-770, -110)
    obj.load("text", "0: 何もしない\n1:ブロック破壊\n2:移動\n3:ジャンプ")
    obj.draw(-720, 0)

    obj.load("text", "方向:")
    obj.draw(-850, 130)
    obj.load("text", this.character[num].direction)
    obj.draw(-770, 130)
    obj.load("text", "1: 右, 2:左, 3:下,4:上")
    obj.draw(-725, 185)

    obj.load("text", "x座標:")
    obj.draw(-750, 255)
    obj.load("text", this.character[num].pos_x)
    obj.draw(-670, 255)
    obj.load("text", "y座標:")
    obj.draw(-750, 305)
    obj.load("text", this.character[num].pos_y)
    obj.draw(-670, 305)

    obj.load("text", "移動距離(x座標):")
    obj.draw(-750, 375)
    obj.load("text", this.character[num].move_x)
    obj.draw(-570, 375)
    obj.load("text", "移動距離(y座標):")
    obj.draw(-750, 425)
    obj.load("text", this.character[num].move_y)
    obj.draw(-570, 425)
  end

  obj.load("text", "描画開始座標(x軸):")
  obj.draw(650, 150)
  obj.load("text", this.view_x)
  obj.draw(850, 150)
  obj.load("text", "描画開始座標(y軸):")
  obj.draw(650, 200)
  obj.load("text", this.view_y)
  obj.draw(850, 200)
  obj.load("text", "描画範囲(幅):")
  obj.draw(683, 250)
  obj.load("text", this.view_width)
  obj.draw(850, 250)
  obj.load("text", "描画範囲(高さ):")
  obj.draw(670, 300)
  obj.load("text", this.view_height)
  obj.draw(850, 300)
  obj.load("text", "マップ(幅):")
  obj.draw(722, 350)
  obj.load("text", this.map_width)
  obj.draw(850, 350)
  obj.load("text", "マップ(高さ):")
  obj.draw(708, 400)
  obj.load("text", this.map_height)
  obj.draw(850, 400)

  -- フレームバッファにターゲットを戻して仮想バッファを描画
  obj.setoption("drawtarget","framebuffer")
  obj.load("tempbuffer")
  -- obj.effect() -- エフェクトを避ける場合はコメントアウト
  obj.draw(0, 0)
end
-- ##########▲ デバッグ用 ▲##########

-- ##########▼ マップの生成 ▼##########
  -- ランダムマップの生成
  -- //////////- Parameter -//////////
  -- num: 初期配置キャラ番号(1~)	[int]
  -- x : 初期配置キャラのx座標		[array index]
  -- y : 初期配置キャラのy座標		[array index]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- map: マップ		[array]
  -- /////////////////////////////////
dig_anime.create_map_solo = function(this, num, x, y)
  local map = {}

  -- 1行目の空洞の配置
  map[1] = {}
  for i = 1, this.map_width do
    map[1][i] = this.max_num
  end

  -- 1行目より下のマップ生成
  for i = 2, this.map_height do
    map[i] = {}
    for j = 1, this.map_width do
      map[i][j] = obj.rand(1, this.max_num - 1, (i+j)*i*this.seed, obj.totaltime)
    end
  end

  -- キャラクターの配置
  map[y][x] = this.max_num + 1 + num


  -- ゴール設置
  map[this.map_height][this.map_width] = this.max_num + 1
  return map
end

  -- 探索用空マップの生成
  -- //////////- Parameter -//////////
  -- なし
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- map: マップ		[array]
  -- /////////////////////////////////
dig_anime.create_empty_map = function(this)
  local map = {}

  -- 空マップ生成
  for i = 1, this.map_height do
    map[i] = {}
    for j = 1, this.map_width do
      map[i][j]  = 0
    end
  end
  return map
end
-- ##########▲ マップの生成 ▲##########

-- ##########▼ 判定処理 ▼##########
  -- 配列チェック(参照先がインデックスから出てしまう場合はfalse)
  -- //////////- Parameter -//////////
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isInside: 参照先が配列内に収まっているならtrue	[boolean]
  -- /////////////////////////////////
dig_anime.isInside = function(this, map_width, map_height, direction, pos_x, pos_y)
  local isInside = true
  if direction == 1 and pos_x + 1 > map_width then
    isInside = false	-- 右方向
  elseif direction == 2 and pos_x - 1 < 1 then
    isInside = false	-- 左方向
  elseif direction == 3 and pos_y + 1 > map_height then
    isInside = false	-- 下方向
  elseif direction == 4 and pos_y - 1 < 1 then
    isInside = false	-- 上方向
  end
  return isInside
end

  -- 空かチェック
  -- //////////- Parameter -//////////
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isBreak: 参照先が何もなければtrue		[boolean]
  -- /////////////////////////////////
dig_anime.isEmpty = function(this, map, map_width, map_height, direction, pos_x, pos_y)
  if this:isInside(map_width, map_height, direction, pos_x, pos_y) == false then
    return false
  end

  local isEmpty = false
  if direction == 1 and (map[pos_y][pos_x + 1] == this.max_num or map[pos_y][pos_x + 1] == this.max_num + 1) then
    isEmpty = true	-- 右方向
  elseif direction == 2 and (map[pos_y][pos_x - 1] == this.max_num or map[pos_y][pos_x - 1] == this.max_num + 1) then
    isEmpty = true	-- 左方向
  elseif direction == 3 and (map[pos_y + 1][pos_x] == this.max_num or map[pos_y + 1][pos_x] == this.max_num + 1) then
    isEmpty = true	-- 下方向
  elseif direction == 4 and (map[pos_y - 1][pos_x] == this.max_num or map[pos_y - 1][pos_x] == this.max_num + 1) then
    isEmpty = true	-- 上方向
  elseif direction == 0 then
    isEmpty = true	-- 現在位置
  end
  return isEmpty
end

  -- 破壊可能かチェック
  -- //////////- Parameter -//////////
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isBreak: 参照先が破壊可能ならばtrue		[boolean]
  -- /////////////////////////////////
dig_anime.isBreak = function(this, map, map_width, map_height, direction, pos_x, pos_y)
  if this:isEmpty(map, map_width, map_height, direction, pos_x, pos_y) then
    return false
  end

  local isBreak = true
  if direction == 1 then
    if map[pos_y][pos_x + 1] < this.map_bias or map[pos_y][pos_x + 1] > this.max_num then
      isBreak = false	-- 右方向
    end
  elseif direction == 2 then
    if map[pos_y][pos_x - 1] < this.map_bias or map[pos_y][pos_x - 1] > this.max_num then
      isBreak = false	-- 左方向
    end
  elseif direction == 3 then
    if map[pos_y + 1][pos_x] < this.map_bias or map[pos_y + 1][pos_x] > this.max_num then
      isBreak = false	-- 下方向
    end
  elseif direction == 4 then
    if map[pos_y - 1][pos_x] < this.map_bias or map[pos_y - 1][pos_x] > this.max_num then
      isBreak = false	-- 上方向
    end
  end
  return isBreak
end
-- ##########▲ 判定処理 ▲##########

-- ##########▼ ブロック破壊 ▼##########
  -- //////////- Parameter -//////////
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- map: マップ					[array]
  -- /////////////////////////////////
dig_anime.break_block = function(this, map, map_width, map_height, direction, pos_x, pos_y)
  -- 破壊が可能かチェック
  if (this:isBreak(map, map_width, map_height, direction, pos_x, pos_y) == false) then
    return map
  end

  -- ブロック破壊の実行
  if direction == 1 then
    map[pos_y][pos_x + 1] = this.max_num	-- 右方向
  elseif direction == 2 then
    map[pos_y][pos_x - 1] = this.max_num	-- 左方向
  elseif direction == 3 then
    map[pos_y + 1][pos_x] = this.max_num	-- 下方向
  elseif direction == 4 then
    map[pos_y - 1][pos_x] = this.max_num	-- 上方向
  end
  return map
end
-- ##########▲ ブロック破壊 ▲##########

-- ##########▼ 探索アルゴリズム ▼##########
  -- 参照先の情報により状態を決定する
  -- //////////- Parameter -//////////
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- state: 0: 何もしない, 1 :ブロック破壊, 2: 移動
  -- /////////////////////////////////
dig_anime.select_state = function(this, map, map_width, map_height, directiont, pos_x, pos_y)
  local state = 0
  if (this:isEmpty(map, map_width, map_height, directiont, pos_x, pos_y)) then
    -- 参照先が空かチェック
    state = 2
  elseif (this:isBreak(map, map_width, map_height, directiont, pos_x, pos_y)) then
    -- 参照先が破壊可能かかチェック
    state = 1
  end
  return state
end

  -- マップを更新
  -- //////////- Parameter -//////////
  -- n: 探索の深さ					[int]
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- route: 深度マップ					[array]
  -- directions: 方位マップ				[array]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- new_route: 深度マップ				[array]
  -- new_directions: 方位マップ				[array]
  -- /////////////////////////////////
dig_anime.update_route = function(this, n, map, map_width, map_height, route, directions, direction, pos_x, pos_y)
  local new_route = this:create_empty_map()
  local new_directions = this:create_empty_map()

  for i = 0, this:get_max(route, map_width, map_height, 0) + 1 do
    new_route[pos_y][pos_x] = n + i
    new_directions[pos_y][pos_x] = direction
    -- ゴールについたら修了
    if map[pos_y][pos_x] == this.max_num + 1 then
      break
    end
    -- ポジションを移動
    if direction == 1 then
      pos_x = pos_x + 1
    elseif direction == 2 then
      pos_x = pos_x - 1
    elseif direction == 3 then
      pos_y = pos_y + 1
    elseif direction == 4 then
      pos_y = pos_y - 1
    end
    -- 次の方位を取得
    direction = directions[pos_y][pos_x]
  end
  return new_route, new_directions
end

  -- 対象マップをゴールまで全探索する
  -- //////////- Parameter -//////////
  -- n: 探索の深さ					[int]
  -- explored: 探索メモ					[array]
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isExplored: 探索終了時 true			[array]
  -- copy_explored: 探索済みマップ			[array]
  -- route: 深度マップ					[array]
  -- directions: 方位マップ				[array]
  -- /////////////////////////////////
dig_anime.dfs = function(this, n, explored, map, map_width, map_height, direction, pos_x, pos_y)
  this.count = this.count + 1
  local isExplored = false			-- ゴールしている場合はtrue
  local isNext = false				-- 次を探索する場合はtrue
  local next_pos_x = 0
  local next_pos_y = 0
  local isUpdate = false			-- アップデートが必要な場合はtrue
  local route = this:create_empty_map()		-- ルートの深さを記したマップ
  local directions = this:create_empty_map()	-- アクション方向を記したマップ
  -- 配列は参照渡しのためマップをコピー
  local copy_explored = this:create_empty_map()	-- 探索済みを記したマップのコピー
  for i = 1, map_height do
    for j = 1, map_width do
      copy_explored[i][j] = explored[i][j]
    end
  end

  copy_explored[pos_y][pos_x] = n	-- 現在位置を記録
  -- ゴールしたなら修了
  if map[pos_y][pos_x] == this.max_num + 1 then
    route[pos_y][pos_x] = n		-- 現在の座標に経路の深さを代入
    -- 前回の方位を代入
    if direction == 1 then
      directions[pos_y][pos_x - 1] = direction
    elseif direction == 2 then
      directions[pos_y][pos_x + 1] = direction
    elseif direction == 3 then
      directions[pos_y - 1][pos_x] = direction
    elseif direction == 4 then
      directions[pos_y + 1][pos_x] = direction
    end
    return true, copy_explored, route, directions
  end

  local return_isExplored = false			-- ゴールしている場合はtrue
  local return_explored = this:create_empty_map()	-- 探索済みを記したマップ
  local return_route = this:create_empty_map()	-- ルート上の深さを記したマップ
  local return_directions = this:create_empty_map()	-- アクション方向を記したマップ
  for i = 1, 4 do
    if i == 1 and direction~= 2 then
      next_pos_x = pos_x + 1
      next_pos_y = pos_y 
      isNext = true
    elseif i == 2 and direction~= 1 then
      next_pos_x = pos_x - 1
      next_pos_y = pos_y 
      isNext = true
    elseif i == 3 and direction~= 4 then
      next_pos_x = pos_x
      next_pos_y = pos_y + 1
      isNext = true
    elseif i == 4 and direction~= 3 then
      next_pos_x = pos_x
      next_pos_y = pos_y - 1
      isNext = true
    else
      isNext = false
    end

    -- マップ内に収まっているかチェック
    if this:isInside(map_width, map_height, i, pos_x, pos_y) and isNext then
      -- アクションが可能かどうかチェック
      if this:select_state(map, map_width, map_height, i, pos_x, pos_y) ~= 0 then
        if copy_explored[next_pos_y][next_pos_x] == 0 then
          return_isExplored, copy_explored, return_route, return_directions = this:dfs(n + 1, copy_explored, map, map_width, map_height, i, next_pos_x, next_pos_y)
        elseif route[next_pos_y][next_pos_x] >= n + 1 then
          return_isExplored = true
          isUpdate = true
        end
      end
    end

    -- もし保有しているルートの最短距離たどり着いていたら更新
    if isUpdate then
      return_route, return_directions = this:update_route(n, map, map_width, map_height, route, directions, i, pos_x, pos_y)              
      isUpdate = false
    end

    -- マップを更新
    if return_isExplored then
      local return_max = this:get_max(return_route, map_width, map_height, 0)
      local current_max = this:get_max(route, map_width, map_height, 0)
      if current_max == 0 or (current_max >= return_max) then
        isExplored = true
        route = return_route		-- マップを更新
        route[pos_y][pos_x] = n	-- 現在の座標に経路の深さを代入
        directions = return_directions
        if direction == 1 then
          directions[pos_y][pos_x - 1]=direction
        elseif direction == 2 then
          directions[pos_y][pos_x + 1]=direction
        elseif direction == 3 then
          directions[pos_y - 1][pos_x]=direction
        end
      end
    end
  end
  return isExplored, copy_explored, route, directions
end
-- ##########▲ 探索アルゴリズム ▲##########

-- ##########▼ キャラ移動 ▼##########
  -- ピクセルレベルの移動距離
  -- //////////- Parameter -//////////
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- move_x: 現在配置されているブロックとの相対座標	[int]
  -- move_x: 現在配置されているブロックとの相対座標	[int]
  -- move_speed: pixelレベルの一回当たりの移動距離	[int]
  -- drop_speed: pixelレベルの一回当たりの落下距離	[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isMoveArray: 配列を移動するべき場合はtrue		[boolean]
  -- move_x: 現在配置されているブロックとの相対座標	[int]
  -- move_x: 現在配置されているブロックとの相対座標	[int]
  -- /////////////////////////////////
dig_anime.pixel_move = function(this, map, map_width, map_height, direction, pos_x, pos_y, move_x, move_y, move_speed, drop_speed)
  -- 移動先が空かチェック
  local isEmpty = this:isEmpty(map, map_width, map_height, direction, pos_x, pos_y)
  local isMoveArray = false

  if direction == 1 then		-- 右方向
    if isEmpty then
      move_x = move_x + this.speed * move_speed
      if move_x >= this.img_width then
        move_x = move_x - this.img_width
        isMoveArray = true
      end
    elseif this.check_range < move_x then
      move_x = move_x - this.speed * this.rebound * this.rebound
    end

  elseif direction == 2 then	-- 左方向
    if isEmpty then
      move_x = move_x - this.speed * move_speed
      if -move_x >= this.img_width then
        move_x = move_x + this.img_width
        isMoveArray = true
      end
    elseif this.check_range < -move_x then
      move_x = move_x + this.speed * this.rebound * this.rebound
    end

  elseif direction == 3 then	-- 下方向
    if isEmpty then
      move_y = move_y + this.speed * drop_speed
      if move_y >= this.img_height then
        move_y = move_y - this.img_height
        isMoveArray = true
      end
    elseif this.check_range < move_y then
      move_y = move_y - this.speed * this.rebound * this.rebound
    end

  elseif direction == 4 then	-- 上方向
    if isEmpty then
      move_y = move_y - this.speed * move_speed
      if -move_y >= this.img_height then
        move_y = move_y + this.img_height
        isMoveArray = true
      end
    elseif this.check_range < -move_y then
      move_y = move_y + this.speed * this.rebound * this.rebound
    end
  end

  return isMoveArray, move_x, move_y
end

  -- 配列レベルの移動
  -- //////////- Parameter -//////////
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- directiont: 参照方向(1: 右, 2:左, 3:下, 4:上)	[int]
  -- pos_x: キャラの位置				[int]
  -- pos_y: キャラの位置				[int]
  -- player: キャラ番号					[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- map: マップ					[array]
  -- move_x: プレイヤーが移動した先のx軸		[int]
  -- move_y: プレイヤーが移動した先のy軸		[int]
  -- /////////////////////////////////
dig_anime.array_move = function(this, map, map_width, map_height, direction, pos_x, pos_y, player)
  local move_x = pos_x
  local move_y = pos_y
  local num = player + this.max_num + 1
  -- 移動先が空かチェック
  if (this:isEmpty(map, map_width, map_height, direction, pos_x, pos_y) == false) then
    return map, move_x, move_y
  end

  if direction < 1 or direction > 5 then
    return map, move_x, move_y
  end

  map[pos_y][pos_x] = this.max_num
  if direction == 1 then	-- 右方向
    move_x = move_x + 1
    map[move_y][move_x] = num
  elseif  direction == 2 then	-- 左方向
    move_x = move_x - 1
    map[move_y][move_x] = num
  elseif  direction == 3 then	-- 下方向
    move_y = move_y + 1
    map[move_y][move_x] = num
  elseif  direction == 4 then	-- 上方向
    move_y = move_y - 1
    map[move_y][move_x] = num
  end
  return map, move_x, move_y
end
-- ##########▲ キャラ移動 ▲##########

-- ##########▼ 描画処理 ▼##########
  -- マップ描画位置の計算
  -- //////////- Parameter -//////////
  -- pos_x: 描画中心位置				[int]
  -- pos_y: 描画中心位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- view_x: 描画開始位置				[int]
  -- view_y: 描画開始位置				[int]
  -- /////////////////////////////////
dig_anime.view_coordinate = function(this, pos_x, pos_y, direction)
  local view_x = -this.wall_depth + 1
  local view_y = -this.wall_depth + 1
  local isViewMove_x = false
  local isViewMove_y = false

  if this.view_width < this.map_width + this.wall_depth * 2 then
    view_x = pos_x - math.floor(this.view_width/2)
    if (-this.wall_depth + 1 >= view_x and direction ~= 1) or (-this.wall_depth + 1 > view_x and direction == 1) then
      -- マップ外表示範囲を固定(左端)
      view_x = -this.wall_depth + 1
    elseif (this.wall_depth + this.map_width < view_x + this.view_width and direction ~= 2) or  (this.wall_depth + this.map_width + 1 < view_x + this.view_width and direction == 2) then
      -- マップ外表示範囲を固定(右端)
      view_x = this.wall_depth + this.map_width - this.view_width + 1
    else
      isViewMove_x = true
    end
  end

  if this.view_height < this.map_height + this.wall_depth * 2 then
    view_y = pos_y - math.floor(this.view_height/2)
    if (-this.wall_depth + 1 >= view_y and direction ~= 3) or (-this.wall_depth + 1 > view_y and direction == 3) then
      -- マップ外表示範囲を固定(上端)
      view_y = -this.wall_depth + 1
    elseif (this.wall_depth + this.map_height < view_y + this.view_height and direction ~= 4) or (this.wall_depth + this.map_height + 1 < view_y + this.view_height and direction == 4) then
      -- マップ外表示範囲を固定(下端)
      view_y = this.wall_depth + this.map_height - this.view_height + 1
    else
      isViewMove_y = true
    end
  end
  return view_x, view_y, isViewMove_x, isViewMove_y
end

  -- マップの描画
  -- //////////- Parameter -//////////
  -- num: キャラ番号					[int]
  -- size: ブロックサイズ				[int]
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- start_x: 描画開始位置				[int]
  -- start_y: 描画開始位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- nil: なし
  -- /////////////////////////////////
dig_anime.draw_map = function(this, num, size, map, map_width, map_height, start_x, start_y, isViewMove_x, isViewMove_y)
  -- 仮想バッファを新規作成しターゲットをそちらに移す
  local buffer_width = this.view_width  * size
  local buffer_height = this.view_height * size
  obj.setoption("drawtarget","tempbuffer", buffer_width, buffer_height)

  local draw_x = - (this.view_width + 1) * size / 2			-- 描画開始座標(x軸)
  local add_x = this.character[num].move_x * size / this.img_width	-- メインキャラ用移動距離
  if isViewMove_x then
    draw_x = draw_x - add_x
  end

  local draw_y = - (this.view_height + 1) * size / 2			-- 描画開始座標(y軸)
  local add_y = this.character[num].move_y * size / this.img_height	-- メインキャラ用移動距離
  if isViewMove_y then
    draw_y = draw_y - add_y
  end

  -- マップの描画(上下左右に表示サイズより+1マスずつ描画)
  for i = 0, this.view_height + 1 do
    if start_y + i - 1> map_height or start_y + i - 1 < 1 then
      for j = 0, this.view_width + 1 do
        obj.load("text", "△")
        obj.draw(draw_x, draw_y)
        draw_x = draw_x + size
      end
    else
      for j = 0, this.view_width + 1 do
        if start_x + j - 1 > map_width or start_x + j - 1 < 1 then
          obj.load("text", "△")
          obj.draw(draw_x, draw_y)
        else
          val = map[start_y + i - 1][start_x + j - 1]

         if  val < this.map_bias then		-- 破壊不能オブジェクトの描画
            obj.load("text","□")
            obj.draw(draw_x, draw_y)
          elseif val < this.max_num then	-- 通常ブロックの描画
            obj.load("text", val)
            obj.draw(draw_x, draw_y)
          elseif val == this.max_num + 1 then	-- ゴールの描画
            obj.load("text", "G")
            obj.draw(draw_x, draw_y)
          elseif val > this.max_num + 1 then	-- プレイヤーの描画
            obj.load("text", "P")
            if val - (this.max_num + 1) ~= num then
              obj.draw(draw_x, draw_y)
            else
              obj.draw(draw_x + add_x, draw_y + add_y)
            end
          end

        end
        draw_x = draw_x + size
      end
    end
    draw_x = - (this.view_width + 1) * size / 2
    if isViewMove_x then
      draw_x = draw_x - add_x
    end
    draw_y = draw_y + size
  end

  -- フレームバッファにターゲットを戻して仮想バッファを描画
  obj.setoption("drawtarget","framebuffer")
  obj.load("tempbuffer")
  obj.effect()
  obj.draw(- size * (this.view_width + 1) / 2, 0)
end

  -- サブマップの描画
  -- //////////- Parameter -//////////
  -- num: キャラ番号					[int]
  -- size: ブロックサイズ				[int]
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- start_x: 描画開始位置				[int]
  -- start_y: 描画開始位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- nil: なし
  -- /////////////////////////////////
dig_anime.draw_sub = function(this, num, size, map, map_width, map_height, start_x, start_y, isViewMove_x, isViewMove_y)
  -- 仮想バッファを新規作成しターゲットをそちらに移す
  local buffer_width = this.view_width  * size
  local buffer_height = this.view_height * size
  obj.setoption("drawtarget","tempbuffer", buffer_width, buffer_height)

  local draw_x = - (this.view_width + 1) * size / 2			-- 描画開始座標(x軸)
  local add_x = this.character[num].move_x * size / this.img_width	-- メインキャラ用移動距離
  if isViewMove_x then
    draw_x = draw_x - add_x
  end

  local draw_y = - (this.view_height + 1) * size / 2			-- 描画開始座標(y軸)
  local add_y = this.character[num].move_y * size / this.img_height	-- メインキャラ用移動距離
  if isViewMove_y then
    draw_y = draw_y - add_y
  end

  -- マップの描画(上下左右に表示サイズより+1マスずつ描画)
  for i = 0, this.view_height + 1 do
    if start_y + i - 1> map_height or start_y + i - 1 < 1 then
      for j = 0, this.view_width + 1 do
        obj.load("text", "△")
        obj.draw(draw_x, draw_y)
        draw_x = draw_x + size
      end
    else
      for j = 0, this.view_width + 1 do
        if start_x + j - 1 > map_width or start_x + j - 1 < 1 then
          obj.load("text", "△")
          obj.draw(draw_x, draw_y)
        else
          val = map[start_y + i - 1][start_x + j - 1]

         if  val == 0 then			-- 空オブジェクトの描画
            obj.load("text","□")
            obj.draw(draw_x, draw_y)
          else					-- 番号の描画
            obj.load("text", val)
            obj.draw(draw_x, draw_y)
          end

        end
        draw_x = draw_x + size
      end
    end
    draw_x = - (this.view_width + 1) * size / 2
    if isViewMove_x then
      draw_x = draw_x - add_x
    end
    draw_y = draw_y + size
  end

  -- フレームバッファにターゲットを戻して仮想バッファを描画
  obj.setoption("drawtarget","framebuffer")
  obj.load("tempbuffer")
  obj.effect()
  obj.draw(size * (this.view_width + 1) / 2, 0)
end

  -- メイン描画
  -- //////////- Parameter -//////////
  -- num: キャラ番号					[int]
  -- size: ブロックサイズ				[int]
  -- map: マップ					[array]
  -- map_width: マップの幅				[int]
  -- map_height: マップの高さ				[int]
  -- start_x: 描画開始位置				[int]
  -- start_y: 描画開始位置				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- nil: なし
  -- /////////////////////////////////
dig_anime.draw_main = function(this, num, map, map_width, map_height, start_x, start_y, isViewMove_x, isViewMove_y)
  -- 仮想バッファを新規作成しターゲットをそちらに移す
  local buffer_width = this.view_width  * this.img_width
  local buffer_height = this.view_height * this.img_height
  obj.setoption("drawtarget","tempbuffer", buffer_width, buffer_height)

  local draw_x = - (this.view_width + 1) * this.img_width / 2	-- 描画開始座標(x軸)
  local add_x = this.character[num].move_x			-- メインキャラ用移動距離
  if isViewMove_x then
    draw_x = draw_x - add_x
  end

  local draw_y = - (this.view_height + 1) * this.img_height / 2	-- 描画開始座標(y軸)
  local add_y = this.character[num].move_y			-- メインキャラ用移動距離
  if isViewMove_y then
    draw_y = draw_y - add_y
  end

  -- マップの描画(上下左右に表示サイズより+1マスずつ描画)
  for i = 0, this.view_height + 1 do
    if start_y + i - 1> map_height or start_y + i - 1 < 1 then
      for j = 0, this.view_width + 1 do
        obj.load("image",this.script_path.."GameAnimations/img/block/000.png")
        obj.draw(draw_x, draw_y)
        draw_x = draw_x + this.img_width
      end
    else
      for j = 0, this.view_width + 1 do
        if start_x + j - 1 > map_width or start_x + j - 1 < 1 then
          obj.load("image",this.script_path.."GameAnimations/img/block/000.png")
          obj.draw(draw_x, draw_y)
        else
          val = map[start_y + i - 1][start_x + j - 1]

         if  val < this.map_bias then		-- 破壊不能オブジェクトの描画
            obj.load("image",this.script_path.."GameAnimations/img/block/001.png")
            obj.draw(draw_x, draw_y)
          elseif val < this.max_num then	-- 通常ブロックの描画
            obj.load("image",this.script_path.."GameAnimations/img/block/"..string.format("%03d", (val%3+2))..".png")
            obj.draw(draw_x, draw_y)
          elseif val >= this.max_num then	-- ゴールの描画
            obj.load("image",this.script_path.."GameAnimations/img/block/021.png")
            obj.draw(draw_x, draw_y)
          end
        end
        draw_x = draw_x + this.img_width
      end
    end
    draw_x = - (this.view_width + 1) * this.img_width / 2
    if isViewMove_x then
      draw_x = draw_x - add_x
    end
    draw_y = draw_y + this.img_height
  end


  -- キャラクター探索
  for i = 1, this.view_height + 1 do
    if start_y + i - 1 <= map_height and start_y + i - 1 > 0 then
      for j = 1, this.view_width + 1 do
        if start_x + j - 1 <= map_width and start_x + j - 1 > 0 then
          val = map[start_y + i - 1][start_x + j - 1]
          -- キャラクター描画
          if val > this.max_num + 1 then
           -- x座標の初期化
            draw_x = - (this.view_width - 1) * this.img_width / 2 + (j - 1) * this.img_width
            if isViewMove_x then
              draw_x = draw_x - add_x
            end

            -- y座標の初期化
            draw_y = - (this.view_height - 1) * this.img_height / 2 + (i - 1) * this.img_height
            if isViewMove_y then
              draw_y = draw_y - add_y
            end

            -- キャラ描画
            local gap = (this.chara_width - this.img_width) / 2
            obj.load("image", this.character[val - this.max_num - 1].img_file)
            if this.character[num].direction == 2 then
              obj.effect("反転","左右反転",1) 
              gap = -gap
            end
            obj.draw(draw_x + add_x - gap, draw_y + add_y)
          end
        end
      end
    end
  end

  -- フレームバッファにターゲットを戻して仮想バッファを描画
  obj.setoption("drawtarget","framebuffer")
  obj.load("tempbuffer")
  obj.effect()
  obj.draw(0, 0)
end
-- ##########▲ 描画処理 ▲##########

-- ##########▼ 初期化 ▼##########
dig_anime.init = function(this)
  -- テスト用変数の初期化
  this.count = 0

  -- マップ情報の初期化
  local pos_x = obj.rand(1, this.map_width , this.seed, obj.totaltime)
  local map = this:create_map_solo(1, pos_x, 1)			-- マップの生成
  this.map = map						-- 新たに生成されたマップ[array]

  -- 描画開始座標[array]
  local isViewMove_x = false
  local isViewMove_y = false
  this.view_x, this.view_y, isViewMove_x, isViewMove_y = this:view_coordinate(pos_x, 1)

  -- キャラクター生成(1人目)
  this:create_character(pos_x, 1)

  -- マップ探索
  local isExplored = false
  isExplored, this.character[1].explored_map, this.character[1].route_map, this.character[1].direction_map = this:dfs(1, this:create_empty_map(), map, this.map_width, this.map_height, 0, pos_x, 1)

  -- 時間の初期化
  this.prev_time = 0
end
-- ##########▲ 初期化 ▲##########

-- ##########▼ 状態遷移 ▼##########
dig_anime.image_state = function(this, num, state)
  local isWait = true
  local img_folder = this.script_path.."GameAnimations/img/chara/"..string.format("%03d", num).."/"..string.format("%03d", num)
  local img_file = "_00a.png"

  if (obj.time - this.prev_time) * this.speed < this.fps and obj.time~=0 then
    return
  elseif obj.time==0 then
    img_file = "_00b.png"
    this.character[num].img_file = img_folder..img_file
    this.character[num].prev_state = state
    return
  end

  this.prev_time = obj.time
  -- ブロック破壊の時はとりあえず待機状態解除
  if state == 1 then
    isWait = false
  end

  -- 状態移行
  if this.character[num].prev_state == state then
    if this.character[num].img_state == "a" then
      this.character[num].img_state = "b"
    elseif this.character[num].img_state == "b" then
      this.character[num].img_state = "c"
    else
      this.character[num].img_state = "a"
      isWait = true  -- 最終動作は必ず待機状態へ移行
    end
  else
    this.character[num].img_state = "a"
  end

  -- 画像ファイル更新
  if this.character[num].state == 1 and (this.character[num].direction == 1 or this.character[num].direction == 2)  then
    img_file = "_01"..this.character[num].img_state..".png"
  elseif this.character[num].state == 1 and (this.character[num].direction == 3 or this.character[num].direction == 4)  then
    img_file = "_02"..this.character[num].img_state..".png"
  elseif this.character[num].state == 2 and this.character[num].direction == 3 then
    img_file = "_03"..this.character[num].img_state..".png"
  elseif this.character[num].state == 2 then
    img_file = "_00"..this.character[num].img_state..".png"
  end
  this.character[num].img_file = img_folder..img_file
  this.character[num].prev_state = state

  return isWait
end

dig_anime.state = function(this, num)
  local isMoveArray = false
  -- 状態遷移
  this.character[num].direction = this.character[num].direction_map[this.character[num].pos_y][this.character[num].pos_x]
  this.character[num].state = this:select_state(this.map, this.map_width, this.map_height, this.character[num].direction, this.character[num].pos_x, this.character[num].pos_y)

  -- 画像状態の更新
  this.character[num].isWait = this:image_state(num, this.character[num].state)

  if this.character[num].state == 1 and this.character[num].isWait then
    -- ブロック破壊
    this.map = this:break_block(this.map, this.map_width, this.map_height, this.character[num].direction, this.character[num].pos_x, this.character[num].pos_y)
    this.character[num].isWait = false -- 移動を開始
  elseif this.character[num].state == 2 and this.character[num].isWait  then
    -- pixelレベルの移動処理
    isMoveArray, this.character[num].move_x, this.character[num].move_y = this:pixel_move(this.map, this.map_width, this.map_height, this.character[num].direction, this.character[num].pos_x, this.character[num].pos_y, this.character[num].move_x, this.character[num].move_y, this.character[num].move_speed, this.character[num].drop_speed)
    -- 配列レベルで移動
    if isMoveArray then
      this.map, this.character[num].pos_x, this.character[num].pos_y = this:array_move(this.map, this.map_width, this.map_height, this.character[num].direction, this.character[num].pos_x, this.character[num].pos_y, num)
      this.character[num].move_x = 0
      this.character[num].move_y = 0
    end
  end
end
-- ##########▲ 状態遷移 ▲##########

-- ##########▼ 実行部分 ▼##########
dig_anime.run = function(this)
  local num = 1
  local isViewMove_x = false
  local isViewMove_y = false
  if this.isDebug then	-- デバッグ表示
    this:debug(num)
  end

  this.view_x, this.view_y, isViewMove_x, isViewMove_y = this:view_coordinate(this.character[num].pos_x, this.character[num].pos_y, this.character[num].direction)

  if this.isDebug then	-- デバッグ表示
    this:draw_map(num, this.block_size, this.map, this.map_width, this.map_height, this.view_x, this.view_y, isViewMove_x, isViewMove_y)
    if Dig_MAP == 1 then
      this:draw_sub(num, this.block_size, this.character[num].route_map, this.map_width, this.map_height, this.view_x, this.view_y, isViewMove_x, isViewMove_y)
    elseif Dig_MAP == 2 then
      this:draw_sub(num, this.block_size, this.character[num].direction_map, this.map_width, this.map_height, this.view_x, this.view_y, isViewMove_x, isViewMove_y)
    elseif Dig_MAP == 3 then
      this:draw_sub(num, this.block_size, this.character[num].explored_map, this.map_width, this.map_height, this.view_x, this.view_y, isViewMove_x, isViewMove_y)
    end
  else
    this:draw_main(num, this.map, this.map_width, this.map_height, this.view_x, this.view_y, isViewMove_x, isViewMove_y)  
  end

  this:state(num)
end
-- ##########▲ 実行部分 ▲##########

dig_anime:init()-- ロード時に初期化
return dig_anime