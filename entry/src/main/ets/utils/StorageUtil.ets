// utils/StorageUtil.ets
import preferences from '@ohos.data.preferences';
import { LostItem, UserInfo, DEFAULT_USER_INFO } from '../model/DataModel';

const PREF_NAME: string = 'lost_found_data';
const KEY_ITEMS: string = 'items';
const KEY_FAVORITES: string = 'favorites';
const KEY_HISTORY: string = 'history';
const KEY_USER_INFO: string = 'user_info';

export class StorageUtil {
  private static pref: preferences.Preferences | null = null;

  static async init(context: Context): Promise<void> {
    try {
      StorageUtil.pref = await preferences.getPreferences(context, PREF_NAME);
    } catch (err) {
      console.error('Storage init failed:', JSON.stringify(err));
    }
  }

  // ========== 用户信息存储 ==========
  static async saveUserInfo(userInfo: UserInfo): Promise<void> {
    if (!StorageUtil.pref) {
      return;
    }
    try {
      await StorageUtil.pref.put(KEY_USER_INFO, JSON.stringify(userInfo));
      await StorageUtil.pref.flush();
    } catch (err) {
      console.error('Save user info failed:', JSON.stringify(err));
    }
  }

  static async loadUserInfo(): Promise<UserInfo> {
    if (!StorageUtil.pref) {
      return DEFAULT_USER_INFO;
    }
    try {
      const data: string = await StorageUtil.pref.get(KEY_USER_INFO, '') as string;
      if (data) {
        return JSON.parse(data) as UserInfo;
      }
      return DEFAULT_USER_INFO;
    } catch (err) {
      console.error('Load user info failed:', JSON.stringify(err));
      return DEFAULT_USER_INFO;
    }
  }

  // ========== 物品数据存储 ==========
  static async saveItems(items: LostItem[]): Promise<void> {
    if (!StorageUtil.pref) {
      return;
    }
    try {
      await StorageUtil.pref.put(KEY_ITEMS, JSON.stringify(items));
      await StorageUtil.pref.flush();
    } catch (err) {
      console.error('Save items failed:', JSON.stringify(err));
    }
  }

  static async loadItems(): Promise<LostItem[]> {
    if (!StorageUtil.pref) {
      return [];
    }
    try {
      const data: string = await StorageUtil.pref.get(KEY_ITEMS, '[]') as string;
      return JSON.parse(data) as LostItem[];
    } catch (err) {
      console.error('Load items failed:', JSON.stringify(err));
      return [];
    }
  }

  // ========== 收藏数据存储 ==========
  static async saveFavorites(favIds: string[]): Promise<void> {
    if (!StorageUtil.pref) {
      return;
    }
    try {
      await StorageUtil.pref.put(KEY_FAVORITES, JSON.stringify(favIds));
      await StorageUtil.pref.flush();
    } catch (err) {
      console.error('Save favorites failed:', JSON.stringify(err));
    }
  }

  static async loadFavorites(): Promise<string[]> {
    if (!StorageUtil.pref) {
      return [];
    }
    try {
      const data: string = await StorageUtil.pref.get(KEY_FAVORITES, '[]') as string;
      return JSON.parse(data) as string[];
    } catch (err) {
      console.error('Load favorites failed:', JSON.stringify(err));
      return [];
    }
  }

  static async toggleFavorite(itemId: string): Promise<boolean> {
    try {
      const favorites: string[] = await StorageUtil.loadFavorites();
      const index: number = favorites.indexOf(itemId);
      if (index >= 0) {
        favorites.splice(index, 1);
        await StorageUtil.saveFavorites(favorites);
        return false;
      } else {
        favorites.unshift(itemId);
        await StorageUtil.saveFavorites(favorites);
        return true;
      }
    } catch (err) {
      console.error('Toggle favorite failed:', JSON.stringify(err));
      return false;
    }
  }

  static async isFavorite(itemId: string): Promise<boolean> {
    try {
      const favorites: string[] = await StorageUtil.loadFavorites();
      return favorites.includes(itemId);
    } catch (err) {
      console.error('Is favorite failed:', JSON.stringify(err));
      return false;
    }
  }

  // ========== 浏览历史存储 ==========
  static async saveHistory(historyIds: string[]): Promise<void> {
    if (!StorageUtil.pref) {
      return;
    }
    try {
      await StorageUtil.pref.put(KEY_HISTORY, JSON.stringify(historyIds));
      await StorageUtil.pref.flush();
    } catch (err) {
      console.error('Save history failed:', JSON.stringify(err));
    }
  }

  static async loadHistory(): Promise<string[]> {
    if (!StorageUtil.pref) {
      return [];
    }
    try {
      const data: string = await StorageUtil.pref.get(KEY_HISTORY, '[]') as string;
      return JSON.parse(data) as string[];
    } catch (err) {
      console.error('Load history failed:', JSON.stringify(err));
      return [];
    }
  }

  static async addHistory(itemId: string): Promise<void> {
    try {
      const history: string[] = await StorageUtil.loadHistory();
      const filtered: string[] = history.filter((id: string) => id !== itemId);
      filtered.unshift(itemId);
      if (filtered.length > 20) {
        filtered.length = 20;
      }
      await StorageUtil.saveHistory(filtered);
    } catch (err) {
      console.error('Add history failed:', JSON.stringify(err));
    }
  }

  // ========== 清除所有数据 ==========
  static async clearAll(): Promise<void> {
    if (!StorageUtil.pref) {
      return;
    }
    try {
      await StorageUtil.pref.put(KEY_ITEMS, '[]');
      await StorageUtil.pref.put(KEY_FAVORITES, '[]');
      await StorageUtil.pref.put(KEY_HISTORY, '[]');
      await StorageUtil.pref.put(KEY_USER_INFO, '');
      await StorageUtil.pref.flush();
    } catch (err) {
      console.error('Clear all failed:', JSON.stringify(err));
    }
  }
}