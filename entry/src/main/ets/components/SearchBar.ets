// components/SearchBar.ets
import { CATEGORIES, COLORS } from '../common/Constant';

@Component
export struct SearchBar {
  @State keyword: string = '';
  @State selectedCategory: string = '全部';
  onSearch?: (keyword: string, category: string) => void;

  build() {
    Column() {
      // 搜索框
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ right: 8 })

        TextInput({
          placeholder: '搜索物品名称、地点...',
          text: this.keyword
        })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .fontSize(14)
          .placeholderColor(COLORS.textSecondary)
          .height(36)
          .onChange((value: string) => {
            this.keyword = value;
          })
          .onSubmit(() => {
            this.onSearch?.(this.keyword, this.selectedCategory);
          })

        if (this.keyword.length > 0) {
          Text('✕')
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
            .padding(4)
            .onClick(() => {
              this.keyword = '';
              this.onSearch?.('', this.selectedCategory);
            })
        }

        Button('搜索')
          .fontSize(14)
          .fontColor(COLORS.primary)
          .backgroundColor(Color.Transparent)
          .padding({ left: 8, right: 8 })
          .height(36)
          .onClick(() => {
            this.onSearch?.(this.keyword, this.selectedCategory);
          })
      }
      .width('100%')
      .height(42)
      .backgroundColor('#F2F2F7')
      .borderRadius(21)
      .padding({ left: 14, right: 8 })

      // 分类标签
      Scroll() {
        Row({ space: 8 }) {
          ForEach(CATEGORIES, (cat: string) => {
            Text(cat)
              .fontSize(13)
              .padding({ left: 16, right: 16, top: 7, bottom: 7 })
              .borderRadius(16)
              .backgroundColor(this.selectedCategory === cat ? COLORS.primary : '#F2F2F7')
              .fontColor(this.selectedCategory === cat ? '#FFFFFF' : COLORS.textSecondary)
              .fontWeight(this.selectedCategory === cat ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.selectedCategory = cat;
                this.onSearch?.(this.keyword, cat);
              })
          })
        }
        .padding({ top: 10, bottom: 6 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .height(44)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 6, bottom: 2 })
    .backgroundColor(Color.Transparent)
  }
}