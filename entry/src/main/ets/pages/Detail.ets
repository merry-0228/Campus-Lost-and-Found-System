// pages/Detail.ets
import { LostItem, findItemById } from '../model/DataModel';
import { COLORS } from '../common/Constant';
import { StorageUtil } from '../utils/StorageUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import pasteboard from '@ohos.pasteboard';

@Entry
@Component
struct Detail {
  @State item: LostItem | null = null;
  @State isCollected: boolean = false;
  @State isLoading: boolean = true;
  private itemId: string = '';

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    this.itemId = (params?.id as string) || '';
    this.loadItem();
  }

  async loadItem(): Promise<void> {
    this.isLoading = true;
    try {
      const items: LostItem[] = await StorageUtil.loadItems();
      const found: LostItem | undefined = findItemById(items, this.itemId);
      if (found) {
        this.item = found;
        this.isCollected = found.isCollected || false;
        found.viewCount = (found.viewCount || 0) + 1;
        await StorageUtil.saveItems(items);
        await StorageUtil.addHistory(found.id);
      }
    } catch (err) {
      console.error('Load item failed:', JSON.stringify(err));
    }
    this.isLoading = false;
  }

  async toggleCollect(): Promise<void> {
    if (!this.item) {
      return;
    }
    this.isCollected = !this.isCollected;
    this.item.isCollected = this.isCollected;
    await StorageUtil.toggleFavorite(this.item.id);
    const items: LostItem[] = await StorageUtil.loadItems();
    const target: LostItem | undefined = items.find((i: LostItem) => i.id === this.item!.id);
    if (target) {
      target.isCollected = this.isCollected;
      await StorageUtil.saveItems(items);
    }
    promptAction.showToast({
      message: this.isCollected ? '❤️ 已收藏' : '已取消收藏',
      duration: 1000
    });
  }

  copyContact(): void {
    if (!this.item) {
      return;
    }
    const systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    const pasteData: pasteboard.PasteData = pasteboard.createPlainTextData(this.item.contact);
    systemPasteboard.setData(pasteData);
    promptAction.showToast({
      message: '📋 联系方式已复制',
      duration: 1500
    });
  }

  goBack(): void {
    router.back();
  }

  build() {
    Column() {
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
      } else if (!this.item) {
        Column() {
          Text('信息不存在')
            .fontSize(16)
            .fontColor(COLORS.textSecondary)
          Button('返回')
            .margin({ top: 16 })
            .onClick(() => { this.goBack(); })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          // 顶部导航
          Row() {
            Text('←')
              .fontSize(24)
              .fontColor(COLORS.textPrimary)
              .onClick(() => { this.goBack(); })

            Text('信息详情')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Text(this.isCollected ? '❤️' : '🤍')
              .fontSize(24)
              .onClick(() => { this.toggleCollect(); })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(COLORS.cardBg)

          Scroll() {
            Column({ space: 12 }) {
              // 状态标签
              Row({ space: 8 }) {
                Text(this.item.type === 'lost' ? '📢 失物招领' : '🔍 寻物启事')
                  .fontSize(13)
                  .fontColor(COLORS.primary)
                  .backgroundColor(COLORS.primaryLight)
                  .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                  .borderRadius(16)

                if (this.item.status === 'resolved') {
                  Text('✅ 已解决')
                    .fontSize(13)
                    .fontColor(COLORS.success)
                    .backgroundColor('#E8F8ED')
                    .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                    .borderRadius(16)
                }

                if (this.item.isUrgent && this.item.status === 'active') {
                  Text('🚨 紧急')
                    .fontSize(13)
                    .fontColor(Color.White)
                    .backgroundColor(COLORS.danger)
                    .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                    .borderRadius(16)
                }
              }
              .width('100%')

              Text(this.item.title)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(COLORS.textPrimary)
                .width('100%')

              Row({ space: 16 }) {
                Text('📂 ' + this.item.category)
                  .fontSize(14)
                  .fontColor(COLORS.textSecondary)
              }
              .width('100%')

              Row() {
                Text('📍 ' + this.item.location)
                  .fontSize(14)
                  .fontColor(COLORS.textSecondary)
              }
              .width('100%')

              Row() {
                Text('🕐 ' + this.item.time)
                  .fontSize(14)
                  .fontColor(COLORS.textSecondary)
              }
              .width('100%')

              Text('📅 发布时间：' + this.item.createdAt)
                .fontSize(12)
                .fontColor(COLORS.textSecondary)
                .width('100%')

              Divider().color(COLORS.divider).margin({ top: 4, bottom: 8 })

              Text('📝 详细描述')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')

              Text(this.item.description)
                .fontSize(14)
                .fontColor(COLORS.textPrimary)
                .lineHeight(24)
                .width('100%')

              Row() {
                Text('📞 联系方式：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(COLORS.textPrimary)

                Text(this.item.contact)
                  .fontSize(14)
                  .fontColor(COLORS.primary)
                  .margin({ left: 4 })
                  .layoutWeight(1)

                Button('复制')
                  .fontSize(12)
                  .fontColor(COLORS.primary)
                  .backgroundColor(COLORS.primaryLight)
                  .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                  .borderRadius(12)
                  .onClick(() => { this.copyContact(); })
              }
              .width('100%')
              .padding({ top: 12, bottom: 12, left: 14, right: 14 })
              .backgroundColor(COLORS.background)
              .borderRadius(8)

              Text('👁️ 浏览 ' + (this.item.viewCount || 0) + ' 次')
                .fontSize(12)
                .fontColor(COLORS.textSecondary)
                .width('100%')
                .textAlign(TextAlign.End)
            }
            .width('100%')
            .padding(16)
          }
          .layoutWeight(1)
          .backgroundColor(COLORS.background)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}