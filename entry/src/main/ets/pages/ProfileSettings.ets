// pages/ProfileSettings.ets
import { UserInfo, DEFAULT_USER_INFO } from '../model/DataModel';
import { COLORS } from '../common/Constant';
import { StorageUtil } from '../utils/StorageUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ProfileSettings {
  @State userName: string = '';
  @State userId: string = '';
  @State userType: string = 'student';
  @State isSaving: boolean = false;
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadUserInfo();
  }

  async loadUserInfo(): Promise<void> {
    this.isLoading = true;
    try {
      const userInfo: UserInfo = await StorageUtil.loadUserInfo();
      this.userName = userInfo.userName;
      this.userId = userInfo.userId;
      this.userType = userInfo.userType;
    } catch (err) {
      console.error('Load user info failed:', JSON.stringify(err));
    }
    this.isLoading = false;
  }

  async saveUserInfo(): Promise<void> {
    if (!this.userName.trim()) {
      promptAction.showToast({ message: '请输入姓名', duration: 1500 });
      return;
    }
    if (!this.userId.trim()) {
      promptAction.showToast({ message: '请输入学号或教工号', duration: 1500 });
      return;
    }

    this.isSaving = true;
    try {
      const userInfo: UserInfo = {
        userName: this.userName.trim(),
        userId: this.userId.trim(),
        userType: this.userType as 'student' | 'teacher'
      };
      await StorageUtil.saveUserInfo(userInfo);
      promptAction.showToast({ message: '✅ 个人信息保存成功', duration: 1500 });
      setTimeout(() => {
        router.back();
      }, 500);
    } catch (err) {
      console.error('Save user info failed:', JSON.stringify(err));
      promptAction.showToast({ message: '保存失败，请重试', duration: 1500 });
    }
    this.isSaving = false;
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor(COLORS.textPrimary)
          .onClick(() => { router.back(); })

        Text('个人信息设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('')
          .width(24)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(COLORS.cardBg)
      .border({ width: { bottom: 1 }, color: COLORS.divider })

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
        Scroll() {
          Column({ space: 20 }) {
            // 头像
            Column() {
              Text('👤')
                .fontSize(64)
                .width(100)
                .height(100)
                .textAlign(TextAlign.Center)
                .borderRadius(50)
                .backgroundColor(COLORS.primaryLight)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 16 })

            // 身份类型选择
            Column() {
              Text('身份类型')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              Row({ space: 12 }) {
                Button('👨‍🎓 学生')
                  .fontSize(14)
                  .layoutWeight(1)
                  .height(40)
                  .backgroundColor(this.userType === 'student' ? COLORS.primary : COLORS.background)
                  .fontColor(this.userType === 'student' ? '#FFFFFF' : COLORS.textSecondary)
                  .borderRadius(8)
                  .onClick(() => {
                    this.userType = 'student';
                  })

                Button('👨‍🏫 教师')
                  .fontSize(14)
                  .layoutWeight(1)
                  .height(40)
                  .backgroundColor(this.userType === 'teacher' ? COLORS.primary : COLORS.background)
                  .fontColor(this.userType === 'teacher' ? '#FFFFFF' : COLORS.textSecondary)
                  .borderRadius(8)
                  .onClick(() => {
                    this.userType = 'teacher';
                  })
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 姓名输入
            Column() {
              Text('姓名 *')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.textPrimary)
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({
                placeholder: '请输入您的姓名',
                text: this.userName
              })
                .width('100%')
                .height(44)
                .backgroundColor(COLORS.background)
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => { this.userName = value; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 学号/教工号输入
            Column() {
              Row() {
                Text('学号/教工号 *')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(COLORS.textPrimary)
                Text('（唯一标识）')
                  .fontSize(12)
                  .fontColor(COLORS.textSecondary)
                  .margin({ left: 4 })
              }
              .width('100%')
              .margin({ bottom: 8 })

              TextInput({
                placeholder: '请输入学号或教工号',
                text: this.userId
              })
                .width('100%')
                .height(44)
                .backgroundColor(COLORS.background)
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => { this.userId = value; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 提示信息
            Column() {
              Row() {
                Text('ℹ️')
                  .fontSize(16)
                Text('学号/教工号将作为您的唯一标识，请确保准确输入')
                  .fontSize(12)
                  .fontColor(COLORS.textSecondary)
                  .margin({ left: 6 })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(COLORS.primaryLight)
              .borderRadius(8)
            }
            .width('100%')

            // 保存按钮
            Button(this.isSaving ? '💾 保存中...' : '💾 保存个人信息')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor(COLORS.primary)
              .borderRadius(8)
              .enabled(!this.isSaving)
              .onClick(() => {
                this.saveUserInfo();
              })
              .margin({ top: 8 })
              .shadow({ radius: 8, color: COLORS.shadow, offsetY: 4 })
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .backgroundColor(COLORS.background)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}