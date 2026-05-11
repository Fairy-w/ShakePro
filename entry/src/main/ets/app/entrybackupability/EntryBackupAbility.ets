import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { AppLogger } from '../../core/logging/AppLogger';

const ENTRY_BACKUP_LOG_TAG: string = 'ShakeProEntryBackup';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    AppLogger.info(ENTRY_BACKUP_LOG_TAG, 'onBackup ok');
  }

  async onRestore(bundleVersion: BundleVersion) {
    AppLogger.info(ENTRY_BACKUP_LOG_TAG, 'onRestore ok %{public}s', JSON.stringify(bundleVersion));
  }
}
