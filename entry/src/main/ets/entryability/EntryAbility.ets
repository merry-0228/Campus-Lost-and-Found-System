// entry/src/main/ets/entryability/EntryAbility.ets
import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { StorageUtil } from '../utils/StorageUtil';
import { INITIAL_ITEMS } from '../model/DataModel';
import type { LostItem } from '../model/DataModel';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    this.initStorage();
  }

  async initStorage(): Promise<void> {
    try {
      await StorageUtil.init(this.context);
      const items: LostItem[] = await StorageUtil.loadItems();
      if (items.length === 0) {
        await StorageUtil.saveItems(INITIAL_ITEMS);
      }
    } catch (err) {
      console.error('Init storage failed:', JSON.stringify(err));
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err: object) => {
      if (err) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}