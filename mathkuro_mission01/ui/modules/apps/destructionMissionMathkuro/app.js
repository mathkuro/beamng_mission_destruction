angular
.module('beamng.apps')
.controller('AppCtrl', function ($scope, $mdSidenav) {
  // ---- 定数 ----

  // 言語設定
  const DEFAULT_LANG = 'en';
  const SUPPORT_LANGS = ['en', 'ja'];
  let currentLanguage = DEFAULT_LANG;

  // 近くの車両のダメージを画面表示する設定
  let damagedVehicleDisplayTimerMap = new Map();
  const DISPLAY_DAMAGE_THRESHOLD = 100;
  const DISPLAY_FRAMES = 120;

  // 被害情報
  let currentTotalDamage = 0;
  let damagedVehicleNum = 0;

  // 画面に表示する変数の初期化
  $scope.totalDamage = 0;
  $scope.totalDamageTitle = '';
  $scope.damagedVehicleNum = 0;
  $scope.damagedVehicleNumTitle = '';
  $scope.nearVehicleDamages = [];
  $scope.ja_jp = false;

  // Get user language settings. ('<lang>_<country>')
  // ref: 0.25\lua\common\utils\languageMap.lua
  bngApi.engineLua('Lua:getSelectedLanguage()', (userLang) => {
    let _lang = userLang.split('_')[0];
    currentLanguage = (SUPPORT_LANGS.includes(_lang)) ? _lang : DEFAULT_LANG;
    if (currentLanguage == "ja") {
      $scope.ja_jp = true;
    }
    console.log('set language: ' + currentLanguage);
  });

  // フレーム毎のループ
  $scope.$on('streamsUpdate', function (event, data) {
    // 指定言語に合わせて表示に変更
    let locale = getLocale(currentLanguage);

    // ダメージ情報更新(更新はミッション側で実施)
    // for UI debug. 
    // bngApi.engineLua('mathkuro_missionDestruction.updateDamagedVehicleTable()');

    // 被害総額取得
    bngApi.engineLua('mathkuro_missionDestruction.getDamagedVehicleNum()', (_num) => {
      damagedVehicleNum = _num;
    });

    // 被害総額取得
    bngApi.engineLua('mathkuro_missionDestruction.getTotalDamageValue()', (damage) => {
      currentTotalDamage = damage;
    });

    // 車両毎の被害額取得
    bngApi.engineLua('mathkuro_missionDestruction.getDamagedVehicleTable()', (_damagedVehicleTable) => {
      Object.keys(_damagedVehicleTable).forEach((key) => {
        let _vname = _damagedVehicleTable[key]['vname'];
        let _damage = _damagedVehicleTable[key]['damage'];
        let _last_val = damagedVehicleDisplayTimerMap.get(key);
        if (typeof _last_val === 'undefined') {
          // 表示数が増えて見にくくなってしまうため、ダメージ値が一定以上の被害車両のみ追加
          if (_damage >= DISPLAY_DAMAGE_THRESHOLD) {
            damagedVehicleDisplayTimerMap.set(key, {vname: _vname, damage: _damage, remain: DISPLAY_FRAMES});
          }
        } else {
          // UPDATE
          if (_last_val['remain'] <= 0 && _damage < _last_val['damage']) {
            damagedVehicleDisplayTimerMap.delete(key)
          } else {
            _last_val['damage'] = _damage;
            damagedVehicleDisplayTimerMap.set(key, _last_val);
          }
        }
      });
    });

    // 画面表示更新
    $scope.$evalAsync(function() {
      let _damages = [];
      damagedVehicleDisplayTimerMap.forEach((val, key) => {
        val['remain'] = val['remain'] - 1;
        if (val['remain'] > 0) {
          // 表示期間が残っている場合のみ画面表示
          // console.log('name: ' + val['vname'] + ', damage:' + val['damage'] + ', remain:' + val['remain']);
          _damages.push({name: val['vname'], damage: locale.damageToLocalString(val['damage'])});
        }
      });

      $scope.totalDamageTitle = locale.totalDamageTitle;
      $scope.totalDamage = locale.damageToLocalString(currentTotalDamage);
      $scope.damagedVehicleNumTitle = locale.damagedVehicleNumTitle;
      $scope.damagedVehicleNum = damagedVehicleNum
      $scope.nearVehicleDamages = _damages;
    });
  });

  // ---- UI上に表示する言語の設定 ----
  function getLocale(localeName){
    if (localeName == 'ja') {
      return new JaLocale();
    } else {
      return new EnLocale();
    }
  };

  class LocalInfoBase {
    totalDamageTitle = 'CRASH TOTAL';
    damagedVehicleNumTitle = 'WRECKS';

    damageToLocalString(damage) {
      return '$' + damage.toLocaleString(undefined, { maximumFractionDigits: 0 });
    }
  };

  class EnLocale extends LocalInfoBase {};

  class JaLocale extends LocalInfoBase {
    totalDamageTitle = '被害総額';
    damagedVehicleNumTitle = '被害台数';

    // 京の桁まで対応
    maxDisplayDigits = 10000 * 10000 * 10000 * 10000 * 10000;

    damageToLocalString(damage) {
      let _damage = damage * 120;

      if (_damage > this.maxDisplayDigits) {
        return '￥' + (damage * 120).toLocaleString(undefined, { maximumFractionDigits: 0 });
      } else {
        let _str = String(Math.round(_damage));
        let keta = ['', '万', '億', '兆', '京'];
        let nums = _str.replace(/(\d)(?=(\d\d\d\d)+$)/g, '$1,').split(',').reverse();
        let data = '';
        for (let i = 0; i < nums.length; i++) {
          if ((nums.length - i) > 2) {
            continue;
          }

          if (!nums[i].match(/^[0]+$/)) {
            data = nums[i].replace(/^[0]+/g, '') + keta[i] + data;
          }
        }
        if (data == '') {
          data = '0';
        }
        return data + '円';
      }
    }
  };

})
.directive('destructionMission', [function () {
  return {
    templateUrl: '/ui/modules/apps/destructionMissionMathkuro/app.html',
    replace: true,
    restrict: 'EA',
    link: function (scope, element, attrs) {
      'use strict';
    }
  };
}])
