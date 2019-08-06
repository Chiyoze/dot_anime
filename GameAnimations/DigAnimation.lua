local dig_anime = {}
dig_anime.script_path = obj.getinfo("script_path")

-- ////////// �e�X�g�p //////////
dig_anime.title = "DigAnimation"
dig_anime.isDebug = isGA_Debug
dig_anime.count = 0
-- ////////// �e�X�g�p //////////

-- ////////// ���Ԍv�� //////////
dig_anime.current_time = 0
dig_anime.prev_time = 0
-- ////////// ���Ԍv�� //////////

-- ////////// ������ //////////
dig_anime.seed = 111		-- [int]:	�x�[�X�ƂȂ闐����
-- ////////// ������ //////////

-- ////////// �f�B�X�v���C //////////
dig_anime.display_x = 0		-- [pixle]: 	�\���J�n�ʒu(����[)
dig_anime.display_y = 0		-- [pixle]: 	�\���J�n�ʒu(����[)
dig_anime.block_size = 50	-- [pixle]: 	�f�o�b�O�p�u���b�N�T�C�Y
dig_anime.img_width = 128 	-- [pixel]: 	�ǂݍ��݉摜(�u���b�N�A�L����)�̕�
dig_anime.img_height = 128 	-- [pixel]:	�ǂݍ��݉摜(�u���b�N�A�L����)�̍���
dig_anime.chara_width = 256 	-- [pixel]: 	�ǂݍ��݉摜(�u���b�N�A�L����)�̕�
dig_anime.speed = GA_Speed	-- [int]:	�Đ����x
dig_anime.fps= 1 / GA_FPS	-- [int]:	�摜�X�V���x
-- ////////// �f�B�X�v���C //////////

-- ////////// �}�b�v //////////
dig_anime.map = {}			-- [array]:		�}�b�v�{��
dig_anime.map_width = obj.track0	-- [array index]:	�}�b�v�̕�
dig_anime.map_height = obj.track1	-- [array index]:	�}�b�v�̍���
dig_anime.view_width = obj.track2	-- [array index]:	�\���͈�(��)
dig_anime.view_height = obj.track3	-- [array index]:	�\���͈�(����)
dig_anime.view_index_x = 1		-- [array index]:	�\���J�n�ʒu(x��)
dig_anime.view_index_y = 1		-- [array index]:	�\���J�n�ʒu(y��)
dig_anime.view_x = 0			-- [pixle]:	 	�\���J�n���W(x��)
dig_anime.view_y = 0			-- [pixle]: 		�\���J�n���W(y��)
dig_anime.wall_depth = 2		-- [int]:		�`�悷��}�b�v�O�̃u���b�N��
-- ////////// �}�b�v //////////

-- ////////// �u���b�N�f�[�^ //////////
dig_anime.check_range = 5	-- [pixel]:	�u���b�N�ɐG��鋗��
dig_anime.rebound = 1		-- [int]:	�u���b�N�ɐG�ꂽ���̔����W��(�������x��n�{���߂�)
dig_anime.rebound_speed = 5	-- [int]:	�u���b�N�ɐG�ꂽ���̔������x
dig_anime.max_num = 20		-- [int]:	�u���b�N�ԍ��̍ő�l(max_num: empty, +1: GOAL, +2~: Player)
dig_anime.map_bias = 3		-- [int]:	�}�b�v���̔j��s�\�u���b�N����(�L�����}���J�n�u���b�N�\��)
-- ////////// �u���b�N�f�[�^ //////////

-- ##########�� �L�����f�[�^ ��##########
dig_anime.num_character = 0	-- [int]:	�L������
dig_anime.character = {}	-- [array]:	�L�������X�g

  -- �L�����N�^�[�𐶐�
  -- //////////- Parameter -//////////
  -- pos_x: �������W(x��)	[array index]
  -- pos_y: �������W(y��)	[array index]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- None: nil
  -- /////////////////////////////////
dig_anime.create_character = function(this, pos_x, pos_y)
  this.num_character = this.num_character + 1
  local num = this.num_character

  -- �L�����N�^�[���
  this.character[num] = {}
  this.character[num].state = 0			-- [int]	���(0: �Ȃ�, 1: �u���b�N�j��, 2: �ړ�, 3:�W�����v)
  this.character[num].prev_state = 0		-- [int]	�O��̏��(0: �Ȃ�, 1: �u���b�N�j��, 2: �ړ�, 3:�W�����v)
  this.character[num].img_state = "a"		-- [inr]	�摜�J�ڏ��(a �� b �� c �� a �� b �� ... )
  this.character[num].direction = 0		-- [int]	�ړ�����(0: �Ȃ�, 1: �E, 2: ��, 3:��, 4: ��)
  this.character[num].pos_x = pos_x		-- [array index]���ݔz�u����Ă���u���b�N���W(x��)
  this.character[num].pos_y = pos_y		-- [array index]���ݔz�u����Ă���u���b�N���W(y��)
  this.character[num].move_x = 0		-- [pixel]	���ݔz�u����Ă���u���b�N�Ƃ̑��΍��W(x��)
  this.character[num].move_y = 0		-- [pixel]	���ݔz�u����Ă���u���b�N�Ƃ̑��΍��W(y��)
  this.character[num].move_speed = 15		-- [pixel]	�ړ����x
  this.character[num].drop_speed = 25		-- [pixel]	�������x
  this.character[num].isMoveArray = false	-- [boolean]	�z����ړ�����K�v������ꍇ��true
  this.character[num].isWait = true		-- [boolean]	�ҋ@��Ԃ̏ꍇ��true

  -- [path]: �摜�t�@�C��
  this.character[num].img_file = this.script_path.."GameAnimations/img/chara/"..string.format("%03d", num).."/"..string.format("%03d", num).."-00a.png"

  -- �T���p�f�[�^
  this.character[num].route_map = {}		-- �T���p�[�x�}�b�v
  this.character[num].direction_map = {}	-- �T���p���ʃ}�b�v
  this.character[num].explored_map = {}		-- �T���p�L�^�}�b�v

  this:image_state(num, 0)
end
-- ##########�� �L�����f�[�^ ��##########

-- ##########�� �ėp���� ��##########
  -- �z����̍ő�l���擾
  -- //////////- Parameter -//////////
  -- array: �T������z��				[array]
  -- width: �z��̕�					[int]
  -- height: �z��̍���					[int]
  -- max_value: �����ő�l				[value]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- max_value: �ő�l					[value]
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

  -- �z����̍ŏ��l���擾
  -- //////////- Parameter -//////////
  -- array: �T������z��				[array]
  -- width: �z��̕�					[int]
  -- height: �z��̍���					[int]
  -- min_value: �����ŏ��l				[value]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- min_value: �ŏ��l				[value]
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
-- ##########�� �ėp���� ��##########

-- ##########�� �f�o�b�O�p ��##########
  -- �f�o�b�O���e��`��
  -- //////////- Parameter -//////////
  -- this: self
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- None: nil
  -- /////////////////////////////////
dig_anime.debug = function(this, num)
  -- ���z�o�b�t�@��V�K�쐬���^�[�Q�b�g��������Ɉڂ�
  obj.setoption("drawtarget","tempbuffer", obj.screen_w, obj.screen_h)

  obj.load("text", "�T����:")
  obj.draw(-755, -500)
  obj.load("text", this.count)
  obj.draw(-620, -500)

  obj.load("text", "�L������:")
  obj.draw(-740, -450)
  obj.load("text", this.num_character)
  obj.draw(-620, -450)

  if this.num_character >= num and num > 0 then
    obj.load("text", "�L������:")
    obj.draw(-770, -160)
    obj.load("text", num)
    obj.draw(-670, -160)

    obj.load("text", "state:")
    obj.draw(-850, -110)
    obj.load("text", this.character[num].state)
    obj.draw(-770, -110)
    obj.load("text", "0: �������Ȃ�\n1:�u���b�N�j��\n2:�ړ�\n3:�W�����v")
    obj.draw(-720, 0)

    obj.load("text", "����:")
    obj.draw(-850, 130)
    obj.load("text", this.character[num].direction)
    obj.draw(-770, 130)
    obj.load("text", "1: �E, 2:��, 3:��,4:��")
    obj.draw(-725, 185)

    obj.load("text", "x���W:")
    obj.draw(-750, 255)
    obj.load("text", this.character[num].pos_x)
    obj.draw(-670, 255)
    obj.load("text", "y���W:")
    obj.draw(-750, 305)
    obj.load("text", this.character[num].pos_y)
    obj.draw(-670, 305)

    obj.load("text", "�ړ�����(x���W):")
    obj.draw(-750, 375)
    obj.load("text", this.character[num].move_x)
    obj.draw(-570, 375)
    obj.load("text", "�ړ�����(y���W):")
    obj.draw(-750, 425)
    obj.load("text", this.character[num].move_y)
    obj.draw(-570, 425)
  end

  obj.load("text", "�`��J�n���W(x��):")
  obj.draw(650, 150)
  obj.load("text", this.view_x)
  obj.draw(850, 150)
  obj.load("text", "�`��J�n���W(y��):")
  obj.draw(650, 200)
  obj.load("text", this.view_y)
  obj.draw(850, 200)
  obj.load("text", "�`��͈�(��):")
  obj.draw(683, 250)
  obj.load("text", this.view_width)
  obj.draw(850, 250)
  obj.load("text", "�`��͈�(����):")
  obj.draw(670, 300)
  obj.load("text", this.view_height)
  obj.draw(850, 300)
  obj.load("text", "�}�b�v(��):")
  obj.draw(722, 350)
  obj.load("text", this.map_width)
  obj.draw(850, 350)
  obj.load("text", "�}�b�v(����):")
  obj.draw(708, 400)
  obj.load("text", this.map_height)
  obj.draw(850, 400)

  -- �t���[���o�b�t�@�Ƀ^�[�Q�b�g��߂��ĉ��z�o�b�t�@��`��
  obj.setoption("drawtarget","framebuffer")
  obj.load("tempbuffer")
  -- obj.effect() -- �G�t�F�N�g�������ꍇ�̓R�����g�A�E�g
  obj.draw(0, 0)
end
-- ##########�� �f�o�b�O�p ��##########

-- ##########�� �}�b�v�̐��� ��##########
  -- �����_���}�b�v�̐���
  -- //////////- Parameter -//////////
  -- num: �����z�u�L�����ԍ�(1~)	[int]
  -- x : �����z�u�L������x���W		[array index]
  -- y : �����z�u�L������y���W		[array index]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- map: �}�b�v		[array]
  -- /////////////////////////////////
dig_anime.create_map_solo = function(this, num, x, y)
  local map = {}

  -- 1�s�ڂ̋󓴂̔z�u
  map[1] = {}
  for i = 1, this.map_width do
    map[1][i] = this.max_num
  end

  -- 1�s�ڂ�艺�̃}�b�v����
  for i = 2, this.map_height do
    map[i] = {}
    for j = 1, this.map_width do
      map[i][j] = obj.rand(1, this.max_num - 1, (i+j)*i*this.seed, obj.totaltime)
    end
  end

  -- �L�����N�^�[�̔z�u
  map[y][x] = this.max_num + 1 + num


  -- �S�[���ݒu
  map[this.map_height][this.map_width] = this.max_num + 1
  return map
end

  -- �T���p��}�b�v�̐���
  -- //////////- Parameter -//////////
  -- �Ȃ�
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- map: �}�b�v		[array]
  -- /////////////////////////////////
dig_anime.create_empty_map = function(this)
  local map = {}

  -- ��}�b�v����
  for i = 1, this.map_height do
    map[i] = {}
    for j = 1, this.map_width do
      map[i][j]  = 0
    end
  end
  return map
end
-- ##########�� �}�b�v�̐��� ��##########

-- ##########�� ���菈�� ��##########
  -- �z��`�F�b�N(�Q�Ɛ悪�C���f�b�N�X����o�Ă��܂��ꍇ��false)
  -- //////////- Parameter -//////////
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isInside: �Q�Ɛ悪�z����Ɏ��܂��Ă���Ȃ�true	[boolean]
  -- /////////////////////////////////
dig_anime.isInside = function(this, map_width, map_height, direction, pos_x, pos_y)
  local isInside = true
  if direction == 1 and pos_x + 1 > map_width then
    isInside = false	-- �E����
  elseif direction == 2 and pos_x - 1 < 1 then
    isInside = false	-- ������
  elseif direction == 3 and pos_y + 1 > map_height then
    isInside = false	-- ������
  elseif direction == 4 and pos_y - 1 < 1 then
    isInside = false	-- �����
  end
  return isInside
end

  -- �󂩃`�F�b�N
  -- //////////- Parameter -//////////
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isBreak: �Q�Ɛ悪�����Ȃ����true		[boolean]
  -- /////////////////////////////////
dig_anime.isEmpty = function(this, map, map_width, map_height, direction, pos_x, pos_y)
  if this:isInside(map_width, map_height, direction, pos_x, pos_y) == false then
    return false
  end

  local isEmpty = false
  if direction == 1 and (map[pos_y][pos_x + 1] == this.max_num or map[pos_y][pos_x + 1] == this.max_num + 1) then
    isEmpty = true	-- �E����
  elseif direction == 2 and (map[pos_y][pos_x - 1] == this.max_num or map[pos_y][pos_x - 1] == this.max_num + 1) then
    isEmpty = true	-- ������
  elseif direction == 3 and (map[pos_y + 1][pos_x] == this.max_num or map[pos_y + 1][pos_x] == this.max_num + 1) then
    isEmpty = true	-- ������
  elseif direction == 4 and (map[pos_y - 1][pos_x] == this.max_num or map[pos_y - 1][pos_x] == this.max_num + 1) then
    isEmpty = true	-- �����
  elseif direction == 0 then
    isEmpty = true	-- ���݈ʒu
  end
  return isEmpty
end

  -- �j��\���`�F�b�N
  -- //////////- Parameter -//////////
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isBreak: �Q�Ɛ悪�j��\�Ȃ��true		[boolean]
  -- /////////////////////////////////
dig_anime.isBreak = function(this, map, map_width, map_height, direction, pos_x, pos_y)
  if this:isEmpty(map, map_width, map_height, direction, pos_x, pos_y) then
    return false
  end

  local isBreak = true
  if direction == 1 then
    if map[pos_y][pos_x + 1] < this.map_bias or map[pos_y][pos_x + 1] > this.max_num then
      isBreak = false	-- �E����
    end
  elseif direction == 2 then
    if map[pos_y][pos_x - 1] < this.map_bias or map[pos_y][pos_x - 1] > this.max_num then
      isBreak = false	-- ������
    end
  elseif direction == 3 then
    if map[pos_y + 1][pos_x] < this.map_bias or map[pos_y + 1][pos_x] > this.max_num then
      isBreak = false	-- ������
    end
  elseif direction == 4 then
    if map[pos_y - 1][pos_x] < this.map_bias or map[pos_y - 1][pos_x] > this.max_num then
      isBreak = false	-- �����
    end
  end
  return isBreak
end
-- ##########�� ���菈�� ��##########

-- ##########�� �u���b�N�j�� ��##########
  -- //////////- Parameter -//////////
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- map: �}�b�v					[array]
  -- /////////////////////////////////
dig_anime.break_block = function(this, map, map_width, map_height, direction, pos_x, pos_y)
  -- �j�󂪉\���`�F�b�N
  if (this:isBreak(map, map_width, map_height, direction, pos_x, pos_y) == false) then
    return map
  end

  -- �u���b�N�j��̎��s
  if direction == 1 then
    map[pos_y][pos_x + 1] = this.max_num	-- �E����
  elseif direction == 2 then
    map[pos_y][pos_x - 1] = this.max_num	-- ������
  elseif direction == 3 then
    map[pos_y + 1][pos_x] = this.max_num	-- ������
  elseif direction == 4 then
    map[pos_y - 1][pos_x] = this.max_num	-- �����
  end
  return map
end
-- ##########�� �u���b�N�j�� ��##########

-- ##########�� �T���A���S���Y�� ��##########
  -- �Q�Ɛ�̏��ɂ���Ԃ����肷��
  -- //////////- Parameter -//////////
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- state: 0: �������Ȃ�, 1 :�u���b�N�j��, 2: �ړ�
  -- /////////////////////////////////
dig_anime.select_state = function(this, map, map_width, map_height, directiont, pos_x, pos_y)
  local state = 0
  if (this:isEmpty(map, map_width, map_height, directiont, pos_x, pos_y)) then
    -- �Q�Ɛ悪�󂩃`�F�b�N
    state = 2
  elseif (this:isBreak(map, map_width, map_height, directiont, pos_x, pos_y)) then
    -- �Q�Ɛ悪�j��\�����`�F�b�N
    state = 1
  end
  return state
end

  -- �}�b�v���X�V
  -- //////////- Parameter -//////////
  -- n: �T���̐[��					[int]
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- route: �[�x�}�b�v					[array]
  -- directions: ���ʃ}�b�v				[array]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- new_route: �[�x�}�b�v				[array]
  -- new_directions: ���ʃ}�b�v				[array]
  -- /////////////////////////////////
dig_anime.update_route = function(this, n, map, map_width, map_height, route, directions, direction, pos_x, pos_y)
  local new_route = this:create_empty_map()
  local new_directions = this:create_empty_map()

  for i = 0, this:get_max(route, map_width, map_height, 0) + 1 do
    new_route[pos_y][pos_x] = n + i
    new_directions[pos_y][pos_x] = direction
    -- �S�[���ɂ�����C��
    if map[pos_y][pos_x] == this.max_num + 1 then
      break
    end
    -- �|�W�V�������ړ�
    if direction == 1 then
      pos_x = pos_x + 1
    elseif direction == 2 then
      pos_x = pos_x - 1
    elseif direction == 3 then
      pos_y = pos_y + 1
    elseif direction == 4 then
      pos_y = pos_y - 1
    end
    -- ���̕��ʂ��擾
    direction = directions[pos_y][pos_x]
  end
  return new_route, new_directions
end

  -- �Ώۃ}�b�v���S�[���܂őS�T������
  -- //////////- Parameter -//////////
  -- n: �T���̐[��					[int]
  -- explored: �T������					[array]
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isExplored: �T���I���� true			[array]
  -- copy_explored: �T���ς݃}�b�v			[array]
  -- route: �[�x�}�b�v					[array]
  -- directions: ���ʃ}�b�v				[array]
  -- /////////////////////////////////
dig_anime.dfs = function(this, n, explored, map, map_width, map_height, direction, pos_x, pos_y)
  this.count = this.count + 1
  local isExplored = false			-- �S�[�����Ă���ꍇ��true
  local isNext = false				-- ����T������ꍇ��true
  local next_pos_x = 0
  local next_pos_y = 0
  local isUpdate = false			-- �A�b�v�f�[�g���K�v�ȏꍇ��true
  local route = this:create_empty_map()		-- ���[�g�̐[�����L�����}�b�v
  local directions = this:create_empty_map()	-- �A�N�V�����������L�����}�b�v
  -- �z��͎Q�Ɠn���̂��߃}�b�v���R�s�[
  local copy_explored = this:create_empty_map()	-- �T���ς݂��L�����}�b�v�̃R�s�[
  for i = 1, map_height do
    for j = 1, map_width do
      copy_explored[i][j] = explored[i][j]
    end
  end

  copy_explored[pos_y][pos_x] = n	-- ���݈ʒu���L�^
  -- �S�[�������Ȃ�C��
  if map[pos_y][pos_x] == this.max_num + 1 then
    route[pos_y][pos_x] = n		-- ���݂̍��W�Ɍo�H�̐[������
    -- �O��̕��ʂ���
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

  local return_isExplored = false			-- �S�[�����Ă���ꍇ��true
  local return_explored = this:create_empty_map()	-- �T���ς݂��L�����}�b�v
  local return_route = this:create_empty_map()	-- ���[�g��̐[�����L�����}�b�v
  local return_directions = this:create_empty_map()	-- �A�N�V�����������L�����}�b�v
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

    -- �}�b�v���Ɏ��܂��Ă��邩�`�F�b�N
    if this:isInside(map_width, map_height, i, pos_x, pos_y) and isNext then
      -- �A�N�V�������\���ǂ����`�F�b�N
      if this:select_state(map, map_width, map_height, i, pos_x, pos_y) ~= 0 then
        if copy_explored[next_pos_y][next_pos_x] == 0 then
          return_isExplored, copy_explored, return_route, return_directions = this:dfs(n + 1, copy_explored, map, map_width, map_height, i, next_pos_x, next_pos_y)
        elseif route[next_pos_y][next_pos_x] >= n + 1 then
          return_isExplored = true
          isUpdate = true
        end
      end
    end

    -- �����ۗL���Ă��郋�[�g�̍ŒZ�������ǂ蒅���Ă�����X�V
    if isUpdate then
      return_route, return_directions = this:update_route(n, map, map_width, map_height, route, directions, i, pos_x, pos_y)              
      isUpdate = false
    end

    -- �}�b�v���X�V
    if return_isExplored then
      local return_max = this:get_max(return_route, map_width, map_height, 0)
      local current_max = this:get_max(route, map_width, map_height, 0)
      if current_max == 0 or (current_max >= return_max) then
        isExplored = true
        route = return_route		-- �}�b�v���X�V
        route[pos_y][pos_x] = n	-- ���݂̍��W�Ɍo�H�̐[������
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
-- ##########�� �T���A���S���Y�� ��##########

-- ##########�� �L�����ړ� ��##########
  -- �s�N�Z�����x���̈ړ�����
  -- //////////- Parameter -//////////
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- move_x: ���ݔz�u����Ă���u���b�N�Ƃ̑��΍��W	[int]
  -- move_x: ���ݔz�u����Ă���u���b�N�Ƃ̑��΍��W	[int]
  -- move_speed: pixel���x���̈�񓖂���̈ړ�����	[int]
  -- drop_speed: pixel���x���̈�񓖂���̗�������	[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- isMoveArray: �z����ړ�����ׂ��ꍇ��true		[boolean]
  -- move_x: ���ݔz�u����Ă���u���b�N�Ƃ̑��΍��W	[int]
  -- move_x: ���ݔz�u����Ă���u���b�N�Ƃ̑��΍��W	[int]
  -- /////////////////////////////////
dig_anime.pixel_move = function(this, map, map_width, map_height, direction, pos_x, pos_y, move_x, move_y, move_speed, drop_speed)
  -- �ړ��悪�󂩃`�F�b�N
  local isEmpty = this:isEmpty(map, map_width, map_height, direction, pos_x, pos_y)
  local isMoveArray = false

  if direction == 1 then		-- �E����
    if isEmpty then
      move_x = move_x + this.speed * move_speed
      if move_x >= this.img_width then
        move_x = move_x - this.img_width
        isMoveArray = true
      end
    elseif this.check_range < move_x then
      move_x = move_x - this.speed * this.rebound * this.rebound
    end

  elseif direction == 2 then	-- ������
    if isEmpty then
      move_x = move_x - this.speed * move_speed
      if -move_x >= this.img_width then
        move_x = move_x + this.img_width
        isMoveArray = true
      end
    elseif this.check_range < -move_x then
      move_x = move_x + this.speed * this.rebound * this.rebound
    end

  elseif direction == 3 then	-- ������
    if isEmpty then
      move_y = move_y + this.speed * drop_speed
      if move_y >= this.img_height then
        move_y = move_y - this.img_height
        isMoveArray = true
      end
    elseif this.check_range < move_y then
      move_y = move_y - this.speed * this.rebound * this.rebound
    end

  elseif direction == 4 then	-- �����
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

  -- �z�񃌃x���̈ړ�
  -- //////////- Parameter -//////////
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- directiont: �Q�ƕ���(1: �E, 2:��, 3:��, 4:��)	[int]
  -- pos_x: �L�����̈ʒu				[int]
  -- pos_y: �L�����̈ʒu				[int]
  -- player: �L�����ԍ�					[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- map: �}�b�v					[array]
  -- move_x: �v���C���[���ړ��������x��		[int]
  -- move_y: �v���C���[���ړ��������y��		[int]
  -- /////////////////////////////////
dig_anime.array_move = function(this, map, map_width, map_height, direction, pos_x, pos_y, player)
  local move_x = pos_x
  local move_y = pos_y
  local num = player + this.max_num + 1
  -- �ړ��悪�󂩃`�F�b�N
  if (this:isEmpty(map, map_width, map_height, direction, pos_x, pos_y) == false) then
    return map, move_x, move_y
  end

  if direction < 1 or direction > 5 then
    return map, move_x, move_y
  end

  map[pos_y][pos_x] = this.max_num
  if direction == 1 then	-- �E����
    move_x = move_x + 1
    map[move_y][move_x] = num
  elseif  direction == 2 then	-- ������
    move_x = move_x - 1
    map[move_y][move_x] = num
  elseif  direction == 3 then	-- ������
    move_y = move_y + 1
    map[move_y][move_x] = num
  elseif  direction == 4 then	-- �����
    move_y = move_y - 1
    map[move_y][move_x] = num
  end
  return map, move_x, move_y
end
-- ##########�� �L�����ړ� ��##########

-- ##########�� �`�揈�� ��##########
  -- �}�b�v�`��ʒu�̌v�Z
  -- //////////- Parameter -//////////
  -- pos_x: �`�撆�S�ʒu				[int]
  -- pos_y: �`�撆�S�ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- view_x: �`��J�n�ʒu				[int]
  -- view_y: �`��J�n�ʒu				[int]
  -- /////////////////////////////////
dig_anime.view_coordinate = function(this, pos_x, pos_y, direction)
  local view_x = -this.wall_depth + 1
  local view_y = -this.wall_depth + 1
  local isViewMove_x = false
  local isViewMove_y = false

  if this.view_width < this.map_width + this.wall_depth * 2 then
    view_x = pos_x - math.floor(this.view_width/2)
    if (-this.wall_depth + 1 >= view_x and direction ~= 1) or (-this.wall_depth + 1 > view_x and direction == 1) then
      -- �}�b�v�O�\���͈͂��Œ�(���[)
      view_x = -this.wall_depth + 1
    elseif (this.wall_depth + this.map_width < view_x + this.view_width and direction ~= 2) or  (this.wall_depth + this.map_width + 1 < view_x + this.view_width and direction == 2) then
      -- �}�b�v�O�\���͈͂��Œ�(�E�[)
      view_x = this.wall_depth + this.map_width - this.view_width + 1
    else
      isViewMove_x = true
    end
  end

  if this.view_height < this.map_height + this.wall_depth * 2 then
    view_y = pos_y - math.floor(this.view_height/2)
    if (-this.wall_depth + 1 >= view_y and direction ~= 3) or (-this.wall_depth + 1 > view_y and direction == 3) then
      -- �}�b�v�O�\���͈͂��Œ�(��[)
      view_y = -this.wall_depth + 1
    elseif (this.wall_depth + this.map_height < view_y + this.view_height and direction ~= 4) or (this.wall_depth + this.map_height + 1 < view_y + this.view_height and direction == 4) then
      -- �}�b�v�O�\���͈͂��Œ�(���[)
      view_y = this.wall_depth + this.map_height - this.view_height + 1
    else
      isViewMove_y = true
    end
  end
  return view_x, view_y, isViewMove_x, isViewMove_y
end

  -- �}�b�v�̕`��
  -- //////////- Parameter -//////////
  -- num: �L�����ԍ�					[int]
  -- size: �u���b�N�T�C�Y				[int]
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- start_x: �`��J�n�ʒu				[int]
  -- start_y: �`��J�n�ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- nil: �Ȃ�
  -- /////////////////////////////////
dig_anime.draw_map = function(this, num, size, map, map_width, map_height, start_x, start_y, isViewMove_x, isViewMove_y)
  -- ���z�o�b�t�@��V�K�쐬���^�[�Q�b�g��������Ɉڂ�
  local buffer_width = this.view_width  * size
  local buffer_height = this.view_height * size
  obj.setoption("drawtarget","tempbuffer", buffer_width, buffer_height)

  local draw_x = - (this.view_width + 1) * size / 2			-- �`��J�n���W(x��)
  local add_x = this.character[num].move_x * size / this.img_width	-- ���C���L�����p�ړ�����
  if isViewMove_x then
    draw_x = draw_x - add_x
  end

  local draw_y = - (this.view_height + 1) * size / 2			-- �`��J�n���W(y��)
  local add_y = this.character[num].move_y * size / this.img_height	-- ���C���L�����p�ړ�����
  if isViewMove_y then
    draw_y = draw_y - add_y
  end

  -- �}�b�v�̕`��(�㉺���E�ɕ\���T�C�Y���+1�}�X���`��)
  for i = 0, this.view_height + 1 do
    if start_y + i - 1> map_height or start_y + i - 1 < 1 then
      for j = 0, this.view_width + 1 do
        obj.load("text", "��")
        obj.draw(draw_x, draw_y)
        draw_x = draw_x + size
      end
    else
      for j = 0, this.view_width + 1 do
        if start_x + j - 1 > map_width or start_x + j - 1 < 1 then
          obj.load("text", "��")
          obj.draw(draw_x, draw_y)
        else
          val = map[start_y + i - 1][start_x + j - 1]

         if  val < this.map_bias then		-- �j��s�\�I�u�W�F�N�g�̕`��
            obj.load("text","��")
            obj.draw(draw_x, draw_y)
          elseif val < this.max_num then	-- �ʏ�u���b�N�̕`��
            obj.load("text", val)
            obj.draw(draw_x, draw_y)
          elseif val == this.max_num + 1 then	-- �S�[���̕`��
            obj.load("text", "G")
            obj.draw(draw_x, draw_y)
          elseif val > this.max_num + 1 then	-- �v���C���[�̕`��
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

  -- �t���[���o�b�t�@�Ƀ^�[�Q�b�g��߂��ĉ��z�o�b�t�@��`��
  obj.setoption("drawtarget","framebuffer")
  obj.load("tempbuffer")
  obj.effect()
  obj.draw(- size * (this.view_width + 1) / 2, 0)
end

  -- �T�u�}�b�v�̕`��
  -- //////////- Parameter -//////////
  -- num: �L�����ԍ�					[int]
  -- size: �u���b�N�T�C�Y				[int]
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- start_x: �`��J�n�ʒu				[int]
  -- start_y: �`��J�n�ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- nil: �Ȃ�
  -- /////////////////////////////////
dig_anime.draw_sub = function(this, num, size, map, map_width, map_height, start_x, start_y, isViewMove_x, isViewMove_y)
  -- ���z�o�b�t�@��V�K�쐬���^�[�Q�b�g��������Ɉڂ�
  local buffer_width = this.view_width  * size
  local buffer_height = this.view_height * size
  obj.setoption("drawtarget","tempbuffer", buffer_width, buffer_height)

  local draw_x = - (this.view_width + 1) * size / 2			-- �`��J�n���W(x��)
  local add_x = this.character[num].move_x * size / this.img_width	-- ���C���L�����p�ړ�����
  if isViewMove_x then
    draw_x = draw_x - add_x
  end

  local draw_y = - (this.view_height + 1) * size / 2			-- �`��J�n���W(y��)
  local add_y = this.character[num].move_y * size / this.img_height	-- ���C���L�����p�ړ�����
  if isViewMove_y then
    draw_y = draw_y - add_y
  end

  -- �}�b�v�̕`��(�㉺���E�ɕ\���T�C�Y���+1�}�X���`��)
  for i = 0, this.view_height + 1 do
    if start_y + i - 1> map_height or start_y + i - 1 < 1 then
      for j = 0, this.view_width + 1 do
        obj.load("text", "��")
        obj.draw(draw_x, draw_y)
        draw_x = draw_x + size
      end
    else
      for j = 0, this.view_width + 1 do
        if start_x + j - 1 > map_width or start_x + j - 1 < 1 then
          obj.load("text", "��")
          obj.draw(draw_x, draw_y)
        else
          val = map[start_y + i - 1][start_x + j - 1]

         if  val == 0 then			-- ��I�u�W�F�N�g�̕`��
            obj.load("text","��")
            obj.draw(draw_x, draw_y)
          else					-- �ԍ��̕`��
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

  -- �t���[���o�b�t�@�Ƀ^�[�Q�b�g��߂��ĉ��z�o�b�t�@��`��
  obj.setoption("drawtarget","framebuffer")
  obj.load("tempbuffer")
  obj.effect()
  obj.draw(size * (this.view_width + 1) / 2, 0)
end

  -- ���C���`��
  -- //////////- Parameter -//////////
  -- num: �L�����ԍ�					[int]
  -- size: �u���b�N�T�C�Y				[int]
  -- map: �}�b�v					[array]
  -- map_width: �}�b�v�̕�				[int]
  -- map_height: �}�b�v�̍���				[int]
  -- start_x: �`��J�n�ʒu				[int]
  -- start_y: �`��J�n�ʒu				[int]
  -- /////////////////////////////////
  -- ///////////- Returns -///////////
  -- nil: �Ȃ�
  -- /////////////////////////////////
dig_anime.draw_main = function(this, num, map, map_width, map_height, start_x, start_y, isViewMove_x, isViewMove_y)
  -- ���z�o�b�t�@��V�K�쐬���^�[�Q�b�g��������Ɉڂ�
  local buffer_width = this.view_width  * this.img_width
  local buffer_height = this.view_height * this.img_height
  obj.setoption("drawtarget","tempbuffer", buffer_width, buffer_height)

  local draw_x = - (this.view_width + 1) * this.img_width / 2	-- �`��J�n���W(x��)
  local add_x = this.character[num].move_x			-- ���C���L�����p�ړ�����
  if isViewMove_x then
    draw_x = draw_x - add_x
  end

  local draw_y = - (this.view_height + 1) * this.img_height / 2	-- �`��J�n���W(y��)
  local add_y = this.character[num].move_y			-- ���C���L�����p�ړ�����
  if isViewMove_y then
    draw_y = draw_y - add_y
  end

  -- �}�b�v�̕`��(�㉺���E�ɕ\���T�C�Y���+1�}�X���`��)
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

         if  val < this.map_bias then		-- �j��s�\�I�u�W�F�N�g�̕`��
            obj.load("image",this.script_path.."GameAnimations/img/block/001.png")
            obj.draw(draw_x, draw_y)
          elseif val < this.max_num then	-- �ʏ�u���b�N�̕`��
            obj.load("image",this.script_path.."GameAnimations/img/block/"..string.format("%03d", (val%3+2))..".png")
            obj.draw(draw_x, draw_y)
          elseif val >= this.max_num then	-- �S�[���̕`��
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


  -- �L�����N�^�[�T��
  for i = 1, this.view_height + 1 do
    if start_y + i - 1 <= map_height and start_y + i - 1 > 0 then
      for j = 1, this.view_width + 1 do
        if start_x + j - 1 <= map_width and start_x + j - 1 > 0 then
          val = map[start_y + i - 1][start_x + j - 1]
          -- �L�����N�^�[�`��
          if val > this.max_num + 1 then
           -- x���W�̏�����
            draw_x = - (this.view_width - 1) * this.img_width / 2 + (j - 1) * this.img_width
            if isViewMove_x then
              draw_x = draw_x - add_x
            end

            -- y���W�̏�����
            draw_y = - (this.view_height - 1) * this.img_height / 2 + (i - 1) * this.img_height
            if isViewMove_y then
              draw_y = draw_y - add_y
            end

            -- �L�����`��
            local gap = (this.chara_width - this.img_width) / 2
            obj.load("image", this.character[val - this.max_num - 1].img_file)
            if this.character[num].direction == 2 then
              obj.effect("���]","���E���]",1) 
              gap = -gap
            end
            obj.draw(draw_x + add_x - gap, draw_y + add_y)
          end
        end
      end
    end
  end

  -- �t���[���o�b�t�@�Ƀ^�[�Q�b�g��߂��ĉ��z�o�b�t�@��`��
  obj.setoption("drawtarget","framebuffer")
  obj.load("tempbuffer")
  obj.effect()
  obj.draw(0, 0)
end
-- ##########�� �`�揈�� ��##########

-- ##########�� ������ ��##########
dig_anime.init = function(this)
  -- �e�X�g�p�ϐ��̏�����
  this.count = 0

  -- �}�b�v���̏�����
  local pos_x = obj.rand(1, this.map_width , this.seed, obj.totaltime)
  local map = this:create_map_solo(1, pos_x, 1)			-- �}�b�v�̐���
  this.map = map						-- �V���ɐ������ꂽ�}�b�v[array]

  -- �`��J�n���W[array]
  local isViewMove_x = false
  local isViewMove_y = false
  this.view_x, this.view_y, isViewMove_x, isViewMove_y = this:view_coordinate(pos_x, 1)

  -- �L�����N�^�[����(1�l��)
  this:create_character(pos_x, 1)

  -- �}�b�v�T��
  local isExplored = false
  isExplored, this.character[1].explored_map, this.character[1].route_map, this.character[1].direction_map = this:dfs(1, this:create_empty_map(), map, this.map_width, this.map_height, 0, pos_x, 1)

  -- ���Ԃ̏�����
  this.prev_time = 0
end
-- ##########�� ������ ��##########

-- ##########�� ��ԑJ�� ��##########
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
  -- �u���b�N�j��̎��͂Ƃ肠�����ҋ@��ԉ���
  if state == 1 then
    isWait = false
  end

  -- ��Ԉڍs
  if this.character[num].prev_state == state then
    if this.character[num].img_state == "a" then
      this.character[num].img_state = "b"
    elseif this.character[num].img_state == "b" then
      this.character[num].img_state = "c"
    else
      this.character[num].img_state = "a"
      isWait = true  -- �ŏI����͕K���ҋ@��Ԃֈڍs
    end
  else
    this.character[num].img_state = "a"
  end

  -- �摜�t�@�C���X�V
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
  -- ��ԑJ��
  this.character[num].direction = this.character[num].direction_map[this.character[num].pos_y][this.character[num].pos_x]
  this.character[num].state = this:select_state(this.map, this.map_width, this.map_height, this.character[num].direction, this.character[num].pos_x, this.character[num].pos_y)

  -- �摜��Ԃ̍X�V
  this.character[num].isWait = this:image_state(num, this.character[num].state)

  if this.character[num].state == 1 and this.character[num].isWait then
    -- �u���b�N�j��
    this.map = this:break_block(this.map, this.map_width, this.map_height, this.character[num].direction, this.character[num].pos_x, this.character[num].pos_y)
    this.character[num].isWait = false -- �ړ����J�n
  elseif this.character[num].state == 2 and this.character[num].isWait  then
    -- pixel���x���̈ړ�����
    isMoveArray, this.character[num].move_x, this.character[num].move_y = this:pixel_move(this.map, this.map_width, this.map_height, this.character[num].direction, this.character[num].pos_x, this.character[num].pos_y, this.character[num].move_x, this.character[num].move_y, this.character[num].move_speed, this.character[num].drop_speed)
    -- �z�񃌃x���ňړ�
    if isMoveArray then
      this.map, this.character[num].pos_x, this.character[num].pos_y = this:array_move(this.map, this.map_width, this.map_height, this.character[num].direction, this.character[num].pos_x, this.character[num].pos_y, num)
      this.character[num].move_x = 0
      this.character[num].move_y = 0
    end
  end
end
-- ##########�� ��ԑJ�� ��##########

-- ##########�� ���s���� ��##########
dig_anime.run = function(this)
  local num = 1
  local isViewMove_x = false
  local isViewMove_y = false
  if this.isDebug then	-- �f�o�b�O�\��
    this:debug(num)
  end

  this.view_x, this.view_y, isViewMove_x, isViewMove_y = this:view_coordinate(this.character[num].pos_x, this.character[num].pos_y, this.character[num].direction)

  if this.isDebug then	-- �f�o�b�O�\��
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
-- ##########�� ���s���� ��##########

dig_anime:init()-- ���[�h���ɏ�����
return dig_anime