// pages/Profile.ets
import { LostItem } from '../model/DataModel';
import { COLORS } from '../common/Constant';
import { StorageUtil } from '../utils/StorageUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { UserInfo } from '../model/DataModel';

@Entry
@Component
struct Profile {
  @State myPosts: LostItem[] = [];
  @State myFavorites: LostItem[] = [];
  @State myHistory: LostItem[] = [];
  @State currentTab: number = 0;
  @State isLoading: boolean = true;
  @State userName: string = '我的账号';
  @State userId: string = '202401XXXX';
  @State userType: string = 'student';
  private loadTimer: number = 0;
  private isFirstLoad: boolean = true;

  aboutToAppear(): void {
    this.loadData();
  }

  onPageShow(): void {
    if (!this.isFirstLoad) {
      if (this.loadTimer) {
        clearTimeout(this.loadTimer);
      }
      this.loadTimer = setTimeout(() => {
        this.refreshDataQuietly();
      }, 300);
    }
    this.isFirstLoad = false;
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      await this.doLoadData();
    } catch (err) {
      console.error('Load data failed:', JSON.stringify(err));
    }
    this.isLoading = false;
  }

  async refreshDataQuietly(): Promise<void> {
    try {
      await this.doLoadData();
    } catch (err) {
      console.error('Refresh data failed:', JSON.stringify(err));
    }
  }

  async doLoadData(): Promise<void> {
    const items: LostItem[] = await StorageUtil.loadItems();
    const favIds: string[] = await StorageUtil.loadFavorites();
    const historyIds: string[] = await StorageUtil.loadHistory();

    // 加载用户信息
    try {
      const userInfo: UserInfo = await StorageUtil.loadUserInfo();
      this.userName = userInfo.userName;
      this.userId = userInfo.userId;
      this.userType = userInfo.userType;
    } catch (err) {
      console.error('Load user info failed:', JSON.stringify(err));
    }

    this.myPosts = items.slice(0, 20);
    this.myFavorites = items.filter((item: LostItem) => favIds.includes(item.id));
    this.myHistory = [];
    for (const id of historyIds) {
      const found: LostItem | undefined = items.find((item: LostItem) => item.id === id);
      if (found) {
        this.myHistory.push(found);
      }
    }
  }

  // 跳转到个人信息设置页
  goToSettings(): void {
    router.pushUrl({ url: 'pages/ProfileSettings' })
      .catch((err: object) => {
        console.error('Navigate to settings failed:', JSON.stringify(err));
      });
  }

  async deletePost(itemId: string): Promise<void> {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这条信息吗？删除后无法恢复。',
      primaryButton: {
        value: '🗑️ 删除',
        action: () => {
          this.doDeletePost(itemId);
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  async doDeletePost(itemId: string): Promise<void> {
    try {
      const items: LostItem[] = await StorageUtil.loadItems();
      const filtered: LostItem[] = items.filter((item: LostItem) => item.id !== itemId);
      await StorageUtil.saveItems(filtered);
      await this.doLoadData();
      promptAction.showToast({ message: '🗑️ 已删除', duration: 1000 });
    } catch (err) {
      console.error('Delete failed:', JSON.stringify(err));
    }
  }

  async cancelFavorite(itemId: string): Promise<void> {
    AlertDialog.show({
      title: '取消收藏',
      message: '确定要取消收藏这条信息吗？',
      primaryButton: {
        value: '确定',
        action: () => {
          this.doCancelFavorite(itemId);
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  async doCancelFavorite(itemId: string): Promise<void> {
    try {
      await StorageUtil.toggleFavorite(itemId);
      const items: LostItem[] = await StorageUtil.loadItems();
      const target: LostItem | undefined = items.find((i: LostItem) => i.id === itemId);
      if (target) {
        target.isCollected = false;
        await StorageUtil.saveItems(items);
      }
      await this.doLoadData();
      promptAction.showToast({ message: '已取消收藏', duration: 1000 });
    } catch (err) {
      console.error('Cancel favorite failed:', JSON.stringify(err));
    }
  }

  async clearHistory(): Promise<void> {
    AlertDialog.show({
      title: '清除浏览记录',
      message: '确定要清除所有浏览记录吗？',
      primaryButton: {
        value: '清除',
        action: () => {
          this.doClearHistory();
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  async doClearHistory(): Promise<void> {
    try {
      await StorageUtil.saveHistory([]);
      await this.doLoadData();
      promptAction.showToast({ message: '已清除浏览记录', duration: 1000 });
    } catch (err) {
      console.error('Clear history failed:', JSON.stringify(err));
    }
  }

  async clearAllData(): Promise<void> {
    AlertDialog.show({
      title: '⚠️ 清除所有数据',
      message: '这将清除所有本地数据（发布、收藏、浏览记录），确定继续吗？',
      primaryButton: {
        value: '确定清除',
        action: () => {
          this.doClearAllData();
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  async doClearAllData(): Promise<void> {
    try {
      await StorageUtil.clearAll();
      await this.doLoadData();
      promptAction.showToast({ message: '已清除所有数据', duration: 2000 });
    } catch (err) {
      console.error('Clear all failed:', JSON.stringify(err));
    }
  }

  goToDetail(item: LostItem): void {
    router.pushUrl({
      url: 'pages/Detail',
      params: { id: item.id }
    }).catch((err: object) => {
      console.error('Navigate to detail failed:', JSON.stringify(err));
    });
  }

  getCategoryIcon(category: string): string {
    const iconMap: Record<string, string> = {
      '数码': '📱',
      '书籍': '📚',
      '生活用品': '🔑',
      '证件': '🪪',
      '衣物': '👔',
      '其他': '📦'
    };
    return iconMap[category] || '📦';
  }

  getTabTitle(): string {
    const titles: string[] = ['📝 我的发布', '❤️ 我的收藏', '👁️ 浏览记录'];
    return titles[this.currentTab] || '我的';
  }

  getTabCount(): number {
    const counts: number[] = [this.myPosts.length, this.myFavorites.length, this.myHistory.length];
    return counts[this.currentTab] || 0;
  }

  build() {
    Column() {
      // ===== 顶部用户信息（点击跳转设置页） =====
      Row() {
        Column() {
          Text('👤')
            .fontSize(38)
            .width(64)
            .height(64)
            .textAlign(TextAlign.Center)
            .borderRadius(32)
            .backgroundColor(COLORS.primaryLight)
        }
        .margin({ right: 14 })

        Column() {
          Row() {
            Text(this.userName || '我的账号')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.textPrimary)

            Text('✏️')
              .fontSize(14)
              .fontColor(COLORS.textSecondary)
              .margin({ left: 8 })
          }

          Row() {
            Text(this.userType === 'student' ? '🎓' : '👨‍🏫')
              .fontSize(12)
            Text(this.userId || '学号: 202401XXXX')
              .fontSize(13)
              .fontColor(COLORS.textSecondary)
              .margin({ left: 2 })
          }
          .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 14, bottom: 14 })
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
      .onClick(() => {
        this.goToSettings();
      })

      // ===== 标题栏（跟随Tab变化） =====
      Row() {
        Text(this.getTabTitle())
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.textPrimary)
          .layoutWeight(1)

        Text(`共${this.getTabCount()}条`)
          .fontSize(13)
          .fontColor(COLORS.textSecondary)
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 12, bottom: 8 })
      .backgroundColor(COLORS.background)

      // ===== 内容区域 =====
      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // Swiper内容
        Swiper() {
          this.buildPostList()
          this.buildFavoriteList()
          this.buildHistoryList()
        }
        .index(this.currentTab)
        .indicator(false)
        .onChange((index: number) => {
          this.currentTab = index;
        })
        .layoutWeight(1)

        // 清除按钮（在Tab导航栏上方）
        Button('🗑️ 清除所有本地数据')
          .width('94%')
          .height(38)
          .fontSize(12)
          .fontColor(COLORS.danger)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: COLORS.danger })
          .borderRadius(8)
          .margin({ top: 4, bottom: 4 })
          .onClick(() => {
            this.clearAllData();
          })

        // 自定义Tab切换栏（在底部）
        Row() {
          this.buildTabItem('📝', '发布', 0)
          this.buildTabItem('❤️', '收藏', 1)
          this.buildTabItem('👁️', '记录', 2)
        }
        .width('100%')
        .height(44)
        .backgroundColor(Color.White)
        .border({ width: { top: 1 }, color: '#E8E8E8' })
        .padding({ top: 4, bottom: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }

  @Builder
  buildTabItem(icon: string, text: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(16)
      Text(text)
        .fontSize(11)
        .fontColor(this.currentTab === index ? COLORS.primary : COLORS.textSecondary)
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 1 })
    }
    .width('33.3%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentTab = index;
    })
  }

  // ========== 统一的卡片组件 ==========
  @Builder
  UnifiedListItem(item: LostItem, showDelete: boolean, showUnfavorite: boolean) {
    Row() {
      Column() {
        Text(this.getCategoryIcon(item.category))
          .fontSize(22)
      }
      .width(42)
      .height(42)
      .borderRadius(10)
      .backgroundColor(COLORS.primaryLight)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Row() {
          Text(item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLORS.textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.type === 'lost' ? '失物' : '寻物')
            .fontSize(10)
            .fontColor(item.type === 'lost' ? COLORS.primary : '#FF6B35')
            .backgroundColor(item.type === 'lost' ? COLORS.primaryLight : '#FFF0E8')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10)
        }
        .width('100%')

        Row() {
          Text('📍')
            .fontSize(10)
            .margin({ right: 1 })
          Text(item.location)
            .fontSize(11)
            .fontColor(COLORS.textSecondary)
            .maxLines(1)
          Text(' · ')
            .fontSize(11)
            .fontColor(COLORS.textSecondary)
          Text('📅')
            .fontSize(10)
            .margin({ right: 1 })
          Text(item.time)
            .fontSize(11)
            .fontColor(COLORS.textSecondary)
            .maxLines(1)
        }
        .margin({ top: 1 })

        Row({ space: 4 }) {
          Text(item.status === 'active' ? '🟢 进行中' : '✅ 已解决')
            .fontSize(10)
            .fontColor(item.status === 'active' ? COLORS.primary : COLORS.success)
            .backgroundColor(item.status === 'active' ? COLORS.primaryLight : '#E8F8ED')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10)

          if (item.isUrgent && item.status === 'active') {
            Text('🚨 紧急')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor(COLORS.danger)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(10)
          }
        }
        .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })

      if (showDelete) {
        Text('🗑️')
          .fontSize(18)
          .onClick(() => {
            this.deletePost(item.id);
          })
      } else if (showUnfavorite) {
        Text('❤️')
          .fontSize(18)
          .onClick(() => {
            this.cancelFavorite(item.id);
          })
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 3, color: 'rgba(0,0,0,0.04)', offsetY: 1 })
    .onClick(() => {
      this.goToDetail(item);
    })
  }

  // ========== 我的发布 ==========
  @Builder
  buildPostList() {
    if (this.myPosts.length === 0) {
      Column() {
        Text('📝')
          .fontSize(44)
        Text('暂无发布')
          .fontSize(16)
          .fontColor(COLORS.textSecondary)
          .margin({ top: 8 })
        Text('点击底部"发布"按钮发布信息')
          .fontSize(12)
          .fontColor(COLORS.textSecondary)
          .margin({ top: 4 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 6 }) {
        ForEach(this.myPosts, (item: LostItem) => {
          ListItem() {
            this.UnifiedListItem(item, true, false)
          }
        }, (item: LostItem) => item.id)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12, top: 4 })
      .layoutWeight(1)
    }
  }

  // ========== 我的收藏 ==========
  @Builder
  buildFavoriteList() {
    if (this.myFavorites.length === 0) {
      Column() {
        Text('❤️')
          .fontSize(44)
        Text('暂无收藏')
          .fontSize(16)
          .fontColor(COLORS.textSecondary)
          .margin({ top: 8 })
        Text('在详情页点击❤️收藏您感兴趣的信息')
          .fontSize(12)
          .fontColor(COLORS.textSecondary)
          .margin({ top: 4 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 6 }) {
        ForEach(this.myFavorites, (item: LostItem) => {
          ListItem() {
            this.UnifiedListItem(item, false, true)
          }
        }, (item: LostItem) => item.id)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12, top: 4 })
      .layoutWeight(1)
    }
  }

  // ========== 浏览记录 ==========
  @Builder
  buildHistoryList() {
    if (this.myHistory.length === 0) {
      Column() {
        Text('👁️')
          .fontSize(44)
        Text('暂无浏览记录')
          .fontSize(16)
          .fontColor(COLORS.textSecondary)
          .margin({ top: 8 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      Column() {
        Row() {
          Text(`共 ${this.myHistory.length} 条记录`)
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
            .layoutWeight(1)

          Text('清除记录')
            .fontSize(12)
            .fontColor(COLORS.danger)
            .onClick(() => {
              this.clearHistory();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 6, bottom: 2 })

        List({ space: 6 }) {
          ForEach(this.myHistory, (item: LostItem) => {
            ListItem() {
              this.UnifiedListItem(item, false, false)
            }
          }, (item: LostItem) => item.id)
        }
        .width('100%')
        .height('100%')
        .padding({ left: 12, right: 12, top: 4 })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
  }
}