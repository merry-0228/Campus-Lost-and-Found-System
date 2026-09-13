// pages/Publish.ets
import { LostItem } from '../model/DataModel';
import { COLORS, CATEGORIES, PUBLISH_TYPES } from '../common/Constant';
import { StorageUtil } from '../utils/StorageUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 添加接口定义
interface PublishTypeItem {
  label: string;
  value: string;
}

@Entry
@Component
struct Publish {
  @State publishType: string = 'lost';
  @State title: string = '';
  @State category: string = '数码';
  @State location: string = '';
  @State time: string = '';
  @State description: string = '';
  @State contact: string = '';
  @State isUrgent: boolean = false;
  @State isSubmitting: boolean = false;
  @State showCategoryPicker: boolean = false;

  aboutToAppear(): void {
    const now: Date = new Date();
    this.time = this.formatDate(now);
  }

  formatDate(date: Date): string {
    const pad = (n: number): string => n.toString().padStart(2, '0');
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
  }

  showToastMessage(message: string): void {
    try {
      promptAction.showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error('Show toast failed:', JSON.stringify(err));
    }
  }

  async submitPublish(): Promise<void> {
    if (!this.title.trim()) {
      this.showToastMessage('请输入物品名称');
      return;
    }
    if (!this.location.trim()) {
      this.showToastMessage('请输入地点');
      return;
    }
    if (!this.description.trim()) {
      this.showToastMessage('请输入详细描述');
      return;
    }
    if (!this.contact.trim()) {
      this.showToastMessage('请输入联系方式');
      return;
    }

    this.isSubmitting = true;

    const newItem: LostItem = {
      id: Date.now().toString() + '_' + Math.random().toString(36).substring(2, 6),
      type: this.publishType,
      title: this.title.trim(),
      category: this.category,
      location: this.location.trim(),
      time: this.time,
      description: this.description.trim(),
      contact: this.contact.trim(),
      status: 'active',
      isUrgent: this.isUrgent && this.publishType === 'found',
      isCollected: false,
      createdAt: this.formatDate(new Date()),
      viewCount: 0,
    };

    try {
      const items: LostItem[] = await StorageUtil.loadItems();
      items.unshift(newItem);
      await StorageUtil.saveItems(items);
      try {
        promptAction.showToast({ message: '✅ 发布成功！', duration: 2000 });
      } catch (err) {
        console.error('Show toast failed:', JSON.stringify(err));
      }
    } catch (err) {
      try {
        promptAction.showToast({ message: '❌ 发布失败，请重试', duration: 2000 });
      } catch (toastErr) {
        console.error('Show toast failed:', JSON.stringify(toastErr));
      }
      console.error('Publish failed:', JSON.stringify(err));
    }

    this.isSubmitting = false;
    setTimeout(() => {
      router.back();
    }, 500);
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor(COLORS.textPrimary)
            .onClick(() => { router.back(); })

          Text('发布信息')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Row().width(24)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(COLORS.cardBg)

        Scroll() {
          Column({ space: 16 }) {
            // 发布类型
            Column() {
              Text('📋 发布类型')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              Row({ space: 12 }) {
                ForEach(PUBLISH_TYPES, (type: PublishTypeItem) => {
                  Button(type.label)
                    .fontSize(14)
                    .layoutWeight(1)
                    .height(40)
                    .backgroundColor(this.publishType === type.value ? COLORS.primary : COLORS.background)
                    .fontColor(this.publishType === type.value ? '#FFFFFF' : COLORS.textSecondary)
                    .borderRadius(8)
                    .onClick(() => {
                      this.publishType = type.value;
                      if (type.value === 'lost') {
                        this.isUrgent = false;
                      }
                    })
                })
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 物品名称
            Column() {
              Text('📝 物品名称 *')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({
                placeholder: '请输入物品名称',
                text: this.title
              })
                .width('100%')
                .height(44)
                .backgroundColor(COLORS.background)
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => { this.title = value; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 物品分类
            Column() {
              Text('📂 物品分类 *')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              Row() {
                Text(this.category)
                  .fontSize(14)
                  .fontColor(COLORS.textPrimary)
                  .layoutWeight(1)

                Text('▼')
                  .fontSize(12)
                  .fontColor(COLORS.textSecondary)
              }
              .width('100%')
              .height(44)
              .backgroundColor(COLORS.background)
              .borderRadius(8)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.showCategoryPicker = true;
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 地点
            Column() {
              Text('📍 地点 *')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({
                placeholder: '请输入丢失/捡到地点',
                text: this.location
              })
                .width('100%')
                .height(44)
                .backgroundColor(COLORS.background)
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => { this.location = value; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 发生时间
            Column() {
              Text('🕐 发生时间 *')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({
                placeholder: '请选择时间',
                text: this.time
              })
                .width('100%')
                .height(44)
                .backgroundColor(COLORS.background)
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => { this.time = value; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 详细描述
            Column() {
              Text('📄 详细描述 *')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              TextArea({
                placeholder: '请详细描述物品特征、丢失/捡到经过等',
                text: this.description
              })
                .width('100%')
                .height(120)
                .backgroundColor(COLORS.background)
                .borderRadius(8)
                .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                .onChange((value: string) => { this.description = value; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 联系方式
            Column() {
              Text('📞 联系方式 *')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({
                placeholder: '请输入手机号/QQ/微信等',
                text: this.contact
              })
                .width('100%')
                .height(44)
                .backgroundColor(COLORS.background)
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => { this.contact = value; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 紧急标记
            if (this.publishType === 'found') {
              Row() {
                Toggle({ type: ToggleType.Switch, isOn: this.isUrgent })
                  .width(44)
                  .height(24)
                  .onChange((isOn: boolean) => {
                    this.isUrgent = isOn;
                  })

                Text('🚨 标记为紧急（寻物启事）')
                  .fontSize(14)
                  .fontColor(COLORS.textSecondary)
                  .margin({ left: 10 })
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })
            }

            // 提交按钮
            Button(this.isSubmitting ? '⏳ 发布中...' : '📤 发布信息')
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor(COLORS.primary)
              .borderRadius(12)
              .enabled(!this.isSubmitting)
              .onClick(() => {
                this.submitPublish();
              })
              .margin({ top: 8, bottom: 20 })
              .shadow({ radius: 8, color: COLORS.shadow, offsetY: 4 })
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

      // 分类选择弹窗
      if (this.showCategoryPicker) {
        Column() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.4)')
            .onClick(() => {
              this.showCategoryPicker = false;
            })

          Column() {
            Text('选择分类')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(16)

            Divider().color(COLORS.divider)

            ForEach(CATEGORIES.filter((c: string) => c !== '全部'), (cat: string) => {
              Text(cat)
                .fontSize(14)
                .width('100%')
                .padding({ left: 16, top: 12, bottom: 12 })
                .backgroundColor(this.category === cat ? COLORS.primaryLight : Color.Transparent)
                .fontColor(this.category === cat ? COLORS.primary : COLORS.textPrimary)
                .onClick(() => {
                  this.category = cat;
                  this.showCategoryPicker = false;
                })
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 16, topRight: 16 })
          .position({ x: 0, y: '70%' })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
  }
}