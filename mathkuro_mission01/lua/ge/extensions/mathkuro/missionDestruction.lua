local M = {}
local logTag = 'mathkuro'

local currentDamageTable = {}

local DAMAGE_TBL_KEY = 10001
local DAMAGE_BY_VAL_TBL_KEY = 10002

local TOTAL_DAMAGE_BY_VAL_TBL_KEY = 20001
local TOTAL_DAMAGED_VEHICLE_NUM_TBL_KEY = 20002

-- ダメージ値を$ベースに換算する係数(要チューニング)
local DAMAGE_TO_VALUE = 25000

-- value未定義の車両のvalue値
local DEFAULT_VEHICLE_VALUE = 30000

-- ダメージ計算を行うダメージ[$]の閾値
local DAMAGE_CALC_THRESHOLD = 100

local totalDamageValue = 0
local totalDamagedVehicleNum = 0

-- 被害総額算出対象とする車両距離
local distanceThreshold = 20

local function getTable(key)
  if not currentDamageTable[key] then
    currentDamageTable[key] = {}
  end

  return currentDamageTable[key]
end

local function setDistanceThreshold(threshold)
  distanceThreshold = threshold
end

local function resetDamageValues(key)
  local _key = (type(key) == 'number') and key or DAMAGE_BY_VAL_TBL_KEY
  currentDamageTable[_key] = {}
  totalDamageValue = 0
  totalDamagedVehicleNum = 0
  return
end

local function getTotalDamageValue()
  return math.floor(totalDamageValue)
end

local function getDamagedVehicleNum()
  return totalDamagedVehicleNum
end

-- 車両毎のダメージテーブルを更新
local function updateDamagedVehicleTable(key)
  local _key = (type(key) == 'number') and key or DAMAGE_BY_VAL_TBL_KEY
  local _tbl = getTable(_key)
  local _totalDamageDiff = 0
  local _playerVeh = be:getPlayerVehicle(0)
  local _playerVid = _playerVeh:getId()
  local _playerPos = _playerVeh:getPosition()

  for vid, veh in activeVehiclesIterator() do
    local _currentDamage = 0
    -- 前回のダメージ値(初出の車両の場合は0)
    local _lastDamage = 0
    if _tbl[vid] then
      _lastDamage = _tbl[vid]['damage']
    end

    -- Value値が未設定の車両がたまにあるので補正
    local _value = core_vehicles.getVehicleDetails(vid).configs.Value
    if _value == nil then
      local _min_value = core_vehicles.getVehicleDetails(vid).model.aggregates.Value.min or (DEFAULT_VEHICLE_VALUE * (1 + math.random()))
      local _max_value = core_vehicles.getVehicleDetails(vid).model.aggregates.Value.max or (DEFAULT_VEHICLE_VALUE * (1 + math.random()))
      _value = (_min_value + _max_value)/2
    end

    if map.objects[vid] == nil then
      -- 'damage'が取得できない車両は諦めて0にしておく
      _currentDamage = 0
    else
      -- 車両価格の2倍まで許容？
      local _damageRate = (map.objects[vid]['damage'] / DAMAGE_TO_VALUE)
      _currentDamage = (2.0 > _damageRate) and (_damageRate * _value) or _value
    end

    if _currentDamage < _lastDamage or _currentDamage < DAMAGE_CALC_THRESHOLD then
      -- 以下の場合はテーブルから削除
      -- 前回値よりもダメージ量が小さい場合(車両リセット)
      -- DAMAGE_CALC_THRESHOLD以下(表示数削減)
      _tbl[vid] = nil
    else
      if vid ~= _playerVid then
        if (_tbl[vid] or veh:getPosition():distance(_playerPos) < distanceThreshold) then
          -- 登録済みまたはプレイヤー車両との距離が閾値未満の車両のみダメージ値更新

          if _tbl[vid] == nil then
            -- 新規登録車両は破壊台数に1加算
            totalDamagedVehicleNum = totalDamagedVehicleNum + 1
          end

          _tbl[vid] = {}
          -- 
          if string.find(core_vehicles.getVehicleDetails(vid).configs.Name, 'simple_traffic') == nil then
            _tbl[vid]['vname'] = core_vehicles.getVehicleDetails(vid).configs.Name
          else
            _tbl[vid]['vname'] = core_vehicles.getVehicleDetails(vid).model.Brand.." "..core_vehicles.getVehicleDetails(vid).model.Name
          end
          _tbl[vid]['damage'] = _currentDamage

          -- ダメージ差分
          _totalDamageDiff = _totalDamageDiff + (_currentDamage - _lastDamage)
        end
      end
    end
  end

  totalDamageValue = totalDamageValue + _totalDamageDiff
end

-- 車両毎のダメージテーブルを取得
local function getDamagedVehicleTable(key)
  local _key = (type(key) == 'number') and key or DAMAGE_BY_VAL_TBL_KEY
  return getTable(_key)
end

M.resetDamageValues = resetDamageValues

M.setDistanceThreshold = setDistanceThreshold

M.getTotalDamageValue = getTotalDamageValue

M.getDamagedVehicleNum = getDamagedVehicleNum
M.updateDamagedVehicleTable = updateDamagedVehicleTable

M.getDamagedVehicleTable = getDamagedVehicleTable

return M
