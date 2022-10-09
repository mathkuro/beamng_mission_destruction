-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local C = {}
C.__index = C
local version = 1

function C:init()
  self.latestVersion = version
  self.fgVariables = self.missionTypeData or {}
  self.fgPath = "/gameplay/missionTypes/mathkuroMission01/destruction.flow.json"

  self.defaultAggregateValues = {
    all = {
      bestMedal = "none",
      bestDestroy = 0,
      bestDamages = 0
    }
  }
  self.autoAggregates = {
    {
      type = 'simpleMedal',
      attemptKey = 'medal', -- key in the attempt
      aggregateKey = 'bestMedal', -- key in the aggregate
      newBestKey = 'newBestMedal',
      default = 'none',
    },
    {
      type = 'simpleHighscore',
      attemptKey = 'destroy', -- key in the attempt
      aggregateKey = 'bestDestroy', -- key in the aggregate
      sorting = 'descending', -- keeping the higher score
      newBestKey = 'newBestDestroy',
    },
    {
      type = 'simpleHighscore',
      attemptKey = 'damages', -- key in the attempt
      aggregateKey = 'bestDamages', -- key in the aggregate
      sorting = 'descending', -- keeping the higher score
      newBestKey = 'newbestDamages',
    }
  }

  self.autoUiAttemptProgress = {
    {
      type = 'simple',
      attemptKey = 'medal',
      columnLabel = 'bigMap.progressLabels.medal',
    },
    {
      type = 'simple',
      attemptKey = 'destroy',
      columnLabel = 'Count',
    },
    {
      type = 'simple',
      attemptKey = 'damages',
      columnLabel = 'Damages[$]',
    },
  }

  self.autoUiAggregateProgress = {
    {
      type = 'simple',
      aggregateKey = 'bestMedal',
      columnLabel = 'bigMap.progressLabels.bestMedal',
      newBestKey = 'newBestMedal',
    },
    {
      type = 'simple',
      aggregateKey = 'bestDestroy',
      columnLabel = 'Best Count',
      newBestKey = 'newBestDestroy',
    },
    {
      type = 'simple',
      aggregateKey = 'bestDamages',
      columnLabel = 'Best Damages[$]',
      newBestKey = 'newbestDamages',
    }
  }

  self.autoUiBigmap = {
    aggregates = {
      aggregatePrimary = {
        progressKey = 'default',
        aggregateKey = 'bestDestroys', -- select best time from detail progress key
        label = 'Best Count',
        type = 'simple'
      }
    }
  }
  self.bigMapIcon = {icon = "map_mission_medal"}
  self.missionTypeLabel = 'bigMap.missionLabels.custom'
end

function C:getRandomizedAttempt(progressKey)
  return gameplay_missions_progress.testHelper.randomAttemptType(), {
    damages = round(gameplay_missions_progress.testHelper.randomNumber(100,1000)),
    destroy = round(gameplay_missions_progress.testHelper.randomNumber(0,5)),
    medal = gameplay_missions_progress.testHelper.randomMedal()
  }
end

return function(...) return gameplay_missions_missions.flowMission(C, ...) end
