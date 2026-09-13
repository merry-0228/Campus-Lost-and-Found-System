// components/EmptyState.ets
import { COLORS } from '../common/Constant';

@Component
export struct EmptyState {
  @Prop icon: string = '📭';
  @Prop title: string = '暂无数据';
  @Prop description: string = '';
  @Prop buttonText: string = '';
  onButtonClick?: () => void;

  build() {
    Column() {
      Text(this.icon)
        .fontSize(64)
        .opacity(0.6)

      Text(this.title)
        .fontSize(18)
        .fontColor(COLORS.textPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16 })

      if (this.description) {
        Text(this.description)
          .fontSize(14)
          .fontColor(COLORS.textSecondary)
          .margin({ top: 6 })
      }

      if (this.buttonText) {
        Button(this.buttonText)
          .fontSize(14)
          .fontColor(COLORS.primary)
          .backgroundColor(COLORS.primaryLight)
          .padding({ left: 28, right: 28, top: 10, bottom: 10 })
          .borderRadius(20)
          .margin({ top: 16 })
          .onClick(() => {
            this.onButtonClick?.();
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(32)
  }
}