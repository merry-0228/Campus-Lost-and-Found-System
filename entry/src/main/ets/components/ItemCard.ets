// components/ItemCard.ets
import { LostItem } from '../model/DataModel';
import { COLORS, CATEGORY_ICONS } from '../common/Constant';
import promptAction from '@ohos.promptAction';

@Component
export struct ItemCard {
  @Prop item: LostItem;
  @State isCollected: boolean = false;
  onItemClick?: () => void;
  onCollectChange?: (itemId: string, isCollected: boolean) => void;

  aboutToAppear(): void {
    this.isCollected = this.item.isCollected;
  }

  build() {
    Row() {
      // 分类图标
      Column() {
        Text(this.getCategoryIcon(this.item.category))
          .fontSize(26)
      }
      .width(48)
      .height(48)
      .borderRadius(12)
      .backgroundColor(COLORS.primaryLight)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 信息区
      Column() {
        Row() {
          Text(this.item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLORS.textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.item.status === 'resolved') {
            Text('✅')
              .fontSize(13)
              .margin({ left: 4 })
          }
          if (this.item.isUrgent && this.item.status === 'active') {
            Text('🚨')
              .fontSize(13)
              .margin({ left: 4 })
          }
        }
        .width('100%')

        Row() {
          Text('📍')
            .fontSize(11)
            .margin({ right: 2 })
          Text(this.item.location)
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
            .maxLines(1)
          Text(' · ')
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
          Text('📅')
            .fontSize(10)
            .margin({ right: 2 })
          Text(this.item.time)
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
            .maxLines(1)
        }
        .width('100%')
        .margin({ top: 2 })

        Row({ space: 6 }) {
          Text(this.item.type === 'lost' ? '📢 失物' : '🔍 寻物')
            .fontSize(11)
            .fontColor(this.item.type === 'lost' ? COLORS.primary : '#FF6B35')
            .backgroundColor(this.item.type === 'lost' ? COLORS.primaryLight : '#FFF0E8')
            .padding({ left: 10, right: 10, top: 3, bottom: 3 })
            .borderRadius(12)

          Text(this.item.category)
            .fontSize(11)
            .fontColor(COLORS.textSecondary)
            .backgroundColor(COLORS.background)
            .padding({ left: 10, right: 10, top: 3, bottom: 3 })
            .borderRadius(12)

          if (this.item.status === 'resolved') {
            Text('已解决')
              .fontSize(11)
              .fontColor(COLORS.success)
              .backgroundColor('#E8F8ED')
              .padding({ left: 10, right: 10, top: 3, bottom: 3 })
              .borderRadius(12)
          }
        }
        .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 收藏按钮
      Text(this.isCollected ? '❤️' : '🤍')
        .fontSize(20)
        .onClick(() => {
          this.isCollected = !this.isCollected;
          this.onCollectChange?.(this.item.id, this.isCollected);
          promptAction.showToast({
            message: this.isCollected ? '❤️ 已收藏' : '已取消收藏',
            duration: 800
          });
        })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .margin({ left: 2, right: 2, top: 3, bottom: 3 })
    .onClick(() => {
      this.onItemClick?.();
    })
  }

  getCategoryIcon(category: string): string {
    return CATEGORY_ICONS[category] || CATEGORY_ICONS['其他'];
  }
}