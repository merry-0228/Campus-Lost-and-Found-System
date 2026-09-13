// pages/Index.ets
import { LostItem } from '../model/DataModel';
import { COLORS } from '../common/Constant';
import { ItemCard } from '../components/ItemCard';
import { SearchBar } from '../components/SearchBar';
import { EmptyState } from '../components/EmptyState';
import { filterByCategory, searchByKeyword } from '../model/DataModel';
import { StorageUtil } from '../utils/StorageUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Index {
  @State items: LostItem[] = [];
  @State filteredItems: LostItem[] = [];
  @State currentTab: number = 0;
  @State keyword: string = '';
  @State selectedCategory: string = '全部';
  @State isLoading: boolean = true;
  @State bottomTabIndex: number = 0;
  private tabsController: TabsController = new TabsController();
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
      const savedItems: LostItem[] = await StorageUtil.loadItems();
      if (savedItems && savedItems.length > 0) {
        this.items = savedItems;
      } else {
        const dataModule = await import('../model/DataModel');
        this.items = dataModule.INITIAL_ITEMS;
        await StorageUtil.saveItems(this.items);
      }
      const favoriteIds: string[] = await StorageUtil.loadFavorites();
      this.items.forEach((item: LostItem) => {
        item.isCollected = favoriteIds.includes(item.id);
      });
      this.applyFilter();
    } catch (err) {
      console.error('Load data failed:', JSON.stringify(err));
    }
    this.isLoading = false;
  }

  async refreshDataQuietly(): Promise<void> {
    try {
      const savedItems: LostItem[] = await StorageUtil.loadItems();
      if (savedItems && savedItems.length > 0) {
        this.items = savedItems;
        const favoriteIds: string[] = await StorageUtil.loadFavorites();
        this.items.forEach((item: LostItem) => {
          item.isCollected = favoriteIds.includes(item.id);
        });
        this.applyFilter();
      }
    } catch (err) {
      console.error('Refresh data failed:', JSON.stringify(err));
    }
  }

  applyFilter(): void {
    let result: LostItem[] = this.items;
    const type: string = this.currentTab === 0 ? 'lost' : 'found';
    result = result.filter((item: LostItem) => item.type === type);
    result = filterByCategory(result, this.selectedCategory);
    result = searchByKeyword(result, this.keyword);
    result = this.sortItems(result);
    this.filteredItems = result;
  }

  sortItems(items: LostItem[]): LostItem[] {
    return [...items].sort((a: LostItem, b: LostItem) => {
      if (a.isUrgent && !b.isUrgent && a.status === 'active') {
        return -1;
      }
      if (!a.isUrgent && b.isUrgent && b.status === 'active') {
        return 1;
      }
      if (a.status === 'active' && b.status === 'resolved') {
        return -1;
      }
      if (a.status === 'resolved' && b.status === 'active') {
        return 1;
      }
      return 0;
    });
  }

  onSearch(keyword: string, category: string): void {
    this.keyword = keyword;
    this.selectedCategory = category;
    this.applyFilter();
  }

  onTabChange(index: number): void {
    this.currentTab = index;
    this.keyword = '';
    this.selectedCategory = '全部';
    this.applyFilter();
  }

  goToDetail(item: LostItem): void {
    router.pushUrl({
      url: 'pages/Detail',
      params: { id: item.id }
    }).catch((err: object) => {
      console.error('Navigate to detail failed:', JSON.stringify(err));
    });
  }

  async onCollectChange(itemId: string, isCollected: boolean): Promise<void> {
    const target: LostItem | undefined = this.items.find((i: LostItem) => i.id === itemId);
    if (target) {
      target.isCollected = isCollected;
      try {
        await StorageUtil.toggleFavorite(itemId);
      } catch (err) {
        console.error('Toggle favorite failed:', JSON.stringify(err));
      }
      this.applyFilter();
    }
  }

  goToPublish(): void {
    router.pushUrl({ url: 'pages/Publish' })
      .catch((err: object) => {
        console.error('Navigate to publish failed:', JSON.stringify(err));
      });
  }

  goToProfile(): void {
    router.pushUrl({ url: 'pages/Profile' })
      .catch((err: object) => {
        console.error('Navigate to profile failed:', JSON.stringify(err));
      });
  }

  switchTab(index: number): void {
    if (this.bottomTabIndex === index) {
      return;
    }
    this.bottomTabIndex = index;
    if (index === 0) {
      this.refreshDataQuietly();
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('校觅归物')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.primary)
          .margin({ left: 4 })

        Blank()

        Text('🔔')
          .fontSize(20)
          .margin({ right: 14 })
          .onClick(() => {
            promptAction.showToast({
              message: '暂无新消息',
              duration: 1000
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 4 })
      .backgroundColor(COLORS.background)

      // 内容区域
      Column() {
        if (this.bottomTabIndex === 0) {
          if (this.isLoading) {
            Column() {
              Text('加载中...')
                .fontSize(16)
                .fontColor(COLORS.textSecondary)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            Column() {
              SearchBar({
                onSearch: (keyword: string, category: string) => {
                  this.onSearch(keyword, category);
                }
              })

              Row() {
                Text(`共 ${this.filteredItems.length} 条信息`)
                  .fontSize(12)
                  .fontColor(COLORS.textSecondary)
              }
              .width('100%')
              .padding({ left: 16, top: 2, bottom: 6 })

              Tabs({
                index: this.currentTab,
                controller: this.tabsController
              }) {
                TabContent() {
                  this.buildList('lost')
                }
                .tabBar(this.TabBarBuilder('📢', '失物招领', 0))

                TabContent() {
                  this.buildList('found')
                }
                .tabBar(this.TabBarBuilder('🔍', '寻物启事', 1))
              }
              .barMode(BarMode.Fixed)
              .scrollable(false)
              .onChange((index: number) => {
                this.onTabChange(index);
              })
              .layoutWeight(1)
              .backgroundColor(COLORS.background)
            }
            .width('100%')
            .height('100%')
            .backgroundColor(COLORS.background)
          }
        } else if (this.bottomTabIndex === 1) {
          Column() {
            Text('📝')
              .fontSize(56)
              .margin({ top: 30 })
              .opacity(0.8)
            Text('发布信息')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.textPrimary)
              .margin({ top: 16 })
            Text('帮助丢失物品尽快找到主人')
              .fontSize(14)
              .fontColor(COLORS.textSecondary)
              .margin({ top: 4 })
            Button('📤 开始发布')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor(COLORS.primary)
              .padding({ left: 44, right: 44, top: 14, bottom: 14 })
              .borderRadius(26)
              .margin({ top: 28 })
              .onClick(() => {
                this.goToPublish();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(COLORS.background)
        } else {
          Column() {
            Column() {
              Text('👤')
                .fontSize(56)
                .width(90)
                .height(90)
                .textAlign(TextAlign.Center)
                .borderRadius(45)
                .backgroundColor(COLORS.primaryLight)
                .margin({ top: 20 })
            }
            Text('个人中心')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.textPrimary)
              .margin({ top: 16 })
            Text('管理你的信息和收藏')
              .fontSize(14)
              .fontColor(COLORS.textSecondary)
              .margin({ top: 4 })
            Button('👤 进入个人中心')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor(COLORS.primary)
              .padding({ left: 44, right: 44, top: 14, bottom: 14 })
              .borderRadius(26)
              .margin({ top: 28 })
              .onClick(() => {
                this.goToProfile();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(COLORS.background)
        }
      }
      .layoutWeight(1)
      .width('100%')

      // 底部导航栏
      Row() {
        this.buildTabItem('🏠', '首页', 0)
        this.buildTabItem('➕', '发布', 1)
        this.buildTabItem('👤', '我的', 2)
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#E8E8E8' })
      .padding({ top: 6, bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }

  @Builder
  TabBarBuilder(icon: string, text: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(16)
      Text(text)
        .fontSize(12)
        .fontColor(this.currentTab === index ? COLORS.primary : COLORS.textSecondary)
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 1 })
    }
    .padding({ top: 6, bottom: 6 })
    .border({
      width: { bottom: this.currentTab === index ? 2.5 : 0 },
      color: COLORS.primary
    })
  }

  @Builder
  buildTabItem(icon: string, label: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(22)
        .margin({ bottom: 1 })
      Text(label)
        .fontSize(11)
        .fontColor(this.bottomTabIndex === index ? COLORS.primary : COLORS.textSecondary)
        .fontWeight(this.bottomTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('33.3%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.switchTab(index);
    })
  }

  @Builder
  buildList(type: string) {
    List({ space: 6 }) {
      if (this.filteredItems.length === 0) {
        ListItem() {
          EmptyState({
            icon: type === 'lost' ? '🔍' : '🔎',
            title: type === 'lost' ? '暂无失物信息' : '暂无寻物信息',
            description: '点击下方发布按钮发布信息',
            buttonText: '去发布',
            onButtonClick: () => {
              this.goToPublish();
            }
          })
        }
        .width('100%')
        .height('100%')
      } else {
        ForEach(this.filteredItems, (item: LostItem) => {
          ListItem() {
            ItemCard({
              item: item,
              onItemClick: () => {
                this.goToDetail(item);
              },
              onCollectChange: (itemId: string, isCollected: boolean) => {
                this.onCollectChange(itemId, isCollected);
              }
            })
          }
        }, (item: LostItem) => item.id)
      }
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 4 })
  }
}