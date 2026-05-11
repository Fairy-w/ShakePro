import { RoutePaths } from '../../core/router/RoutePaths';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { AppLogger } from '../../core/logging/AppLogger';

const ENTRY_ABILITY_LOG_TAG: string = 'ShakeProEntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppLogger.info(ENTRY_ABILITY_LOG_TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    AppLogger.info(ENTRY_ABILITY_LOG_TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    AppLogger.info(ENTRY_ABILITY_LOG_TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent(RoutePaths.LOGIN, (err) => {
      if (err.code) {
        AppLogger.error(ENTRY_ABILITY_LOG_TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      AppLogger.info(ENTRY_ABILITY_LOG_TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    AppLogger.info(ENTRY_ABILITY_LOG_TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    AppLogger.info(ENTRY_ABILITY_LOG_TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    AppLogger.info(ENTRY_ABILITY_LOG_TAG, '%{public}s', 'Ability onBackground');
  }
}
