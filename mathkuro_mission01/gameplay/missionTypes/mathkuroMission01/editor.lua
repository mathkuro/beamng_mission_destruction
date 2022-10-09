-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local C = {}
C.__index = C

local gold
local silver
local bronze

local start

local function hideMedals(value)
  gold.hidden = value
  silver.hidden = value
  bronze.hidden = value
end

local function hideStartAndFinish(value)
  start.hidden = value
end

function C:init()
  self:addString("Start Screen Title", "introTitle", "[Mission] Destruction", 9000, {tooltip = "The title that displays on the start-screen.", isTranslation = true})
  self:addString("Start Screen Text", "introText", "Destruct traffic as much as you can!", 9000, {tooltip = "The text that displays on the start-screen.", isTranslation = true})
  self:addDecoText("Where will the players vehicle start and reset to?")
  self:addTransform("Player Start Position", "playerStart", {hasPos = true, hasRot = true }, {drawMode = "vehicle", drawColor = {0,1,0,0.4}})

  self:addNumeric("Traffic count", "trafficCount", -1, {tooltip = "Set the desired amount of traffic vehicles to spawn. To use the system default enter '-1' otherwise choose any number you would like."})
  self:addNumeric("Traffic Pool Count", "trafficPoolCount", -1, {tooltip = "Set the desired amount of traffic vehicles to spawn. To use the system default enter '-1' otherwise choose any number you would like."})
  self:addNumeric("Traffic Police Ratio", "policeRatio", 0, {tooltip = "Set the desired ratio of police in traffic (from 0 to 1); 0 means no police."})

  self:addBool("Provided Vehicle", "presetVehicleActive", false, {
    self:addModelConfig("Model & Config", "player", "coupe", "race"),
    self:addNumeric("Color of Provided Vehicle", "vehicleColor", 1, {tooltip = "Primary Color Hue (from 0 to 1); HSV model."}),
    self:addBool("Allow Player Vehicle Choice", "allowVehicleChoice", false, nil, {tooltip = "Should the player have the choice to use the preset vehicle in the mission settings?"})
  }, {boxText = "Should a preset vehicle be provided to the player?"})

  self:addBool("Enable Force Field", "isForceFieldEnabled", false)

  self:addNumeric("Extention Time Seconds", "extensionSeconds", 5, {tooltip = "Add this seconds to the mission remain seconds when hit traffic."})
  self:addNumeric("Distance Threshold", "distanceThreshold", 20, {tooltip = "Vehicles within this distance are calculate as the total damage."})

  gold = self:addNumeric("Gold damage score", "goldScore", 50)
  silver = self:addNumeric("Silver damage score", "silverScore", 25)
  bronze = self:addNumeric("Bronze damage score", "bronzeScore", 10)
end
return function(...) return gameplay_missions_missions.editorHelper(C, ...) end
