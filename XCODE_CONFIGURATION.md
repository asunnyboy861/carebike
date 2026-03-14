# SafeParents - Xcode 配置指南

## 概述
本文档描述了SafeParents应用需要在Xcode中手动配置的Capabilities和设置。

---

## 1. App Groups (必需)

### 用途
App Groups允许主应用和Widget扩展共享数据，用于在Widget中显示最新的签到状态。

### 配置步骤

1. 在Xcode中选择项目导航器中的 `safeparents` 项目
2. 选择 `safeparents` target
3. 点击 "Signing & Capabilities" 标签
4. 点击 "+ Capability" 按钮
5. 搜索并添加 "App Groups"
6. 点击 "+" 按钮添加新的App Group:
   - **Group ID**: `group.com.zzoutuo.safeparents`

### Widget扩展配置
重复以上步骤为 `SafeParentsWidgetExtension` target配置相同的App Group:
1. 选择 `SafeParentsWidgetExtension` target
2. 添加相同的App Group: `group.com.zzoutuo.safeparents`

---

## 2. Push Notifications (推荐)

### 用途
用于发送签到提醒和错过签到的紧急通知。

### 配置步骤

1. 选择 `safeparents` target
2. 点击 "Signing & Capabilities" 标签
3. 点击 "+ Capability" 按钮
4. 搜索并添加 "Push Notifications"
5. 这将自动生成 `.entitlements` 文件

---

## 3. Background Modes (推荐)

### 用途
用于后台任务调度，定时检查签到状态和发送通知。

### 配置步骤

1. 选择 `safeparents` target
2. 点击 "Signing & Capabilities" 标签
3. 点击 "+ Capability" 按钮
4. 搜索并添加 "Background Modes"
5. 勾选以下选项:
   - ✅ Background fetch
   - ✅ Remote notifications
   - ✅ Background processing (iOS 13+)

---

## 4. iCloud / CloudKit (可选)

### 用途
用于在iCloud上同步家庭成员和签到数据。

### 配置步骤

1. 选择 `safeparents` target
2. 点击 "Signing & Capabilities" 标签
3. 点击 "+ Capability" 按钮
4. 搜索并添加 "iCloud"
5. 勾选 "CloudKit"
6. 点击 "+" 添加Container:
   - **Container ID**: `iCloud.com.zzoutuo.safeparents`

### CloudKit Dashboard配置
1. 登录 [CloudKit Console](https://icloud.developer.apple.com/)
2. 选择创建的Container
3. 创建以下Record Types:
   - `CheckIn`
   - `CheckInSchedule`
   - `FamilyCircle`
   - `Parent`

---

## 5. Info.plist 配置

### 后台模式配置
在 `Info.plist` 中添加以下配置（如果通过Background Modes添加会自动生成）:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
    <string>processing</string>
</array>
```

### 通知权限描述
确保 `Info.plist` 包含:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>SafeParents needs to send you check-in reminders and alerts about your family members.</string>
```

---

## 6. Signing & Capabilities 总结

### 主应用 (safeparents)
- [x] App Groups: `group.com.zzoutuo.safeparents`
- [x] Push Notifications
- [x] Background Modes
- [ ] iCloud (可选)

### Widget扩展 (SafeParentsWidgetExtension)
- [x] App Groups: `group.com.zzoutuo.safeparents` (必须与主应用相同)

---

## 7. 代码中使用的常量

在 `AppConstants.swift` 中已定义以下常量，请确保与Xcode配置匹配:

```swift
struct AppGroup {
    static let identifier = "group.com.zzoutuo.safeparents"
    static let parentName = "parentName"
    static let checkInStatus = "checkInStatus"
    static let lastCheckInTime = "lastCheckInTime"
}

struct CloudKit {
    static let containerIdentifier = "iCloud.com.zzoutuo.safeparents"
}
```

---

## 8. 测试配置

### 验证App Groups配置
```swift
// 在代码中测试
if let sharedDefaults = UserDefaults(suiteName: "group.com.zzoutuo.safeparents") {
    print("App Groups configured correctly")
} else {
    print("App Groups configuration failed")
}
```

### 验证通知权限
运行应用后，检查通知授权状态:
```swift
UNUserNotificationCenter.current().getNotificationSettings { settings in
    print("Notification status: \(settings.authorizationStatus)")
}
```

---

## 9. 常见问题

### Q: Widget显示"No data available"
**A:** 检查App Groups是否正确配置，确保主应用和Widget使用相同的Group ID。

### Q: 通知不工作
**A:** 
1. 确认Push Notifications capability已添加
2. 检查通知权限是否已授权
3. 确认设备设置中应用的通知权限已开启

### Q: CloudKit同步失败
**A:** 
1. 确认iCloud capability已正确配置
2. 检查Container ID是否正确
3. 确认用户已登录iCloud账户

---

## 配置完成后

完成以上配置后，请:
1. Clean Build Folder (Cmd+Shift+K)
2. 重新编译项目
3. 在真机上测试通知和Widget功能

---

**注意**: 某些功能（如Push Notifications和CloudKit）需要Apple开发者账户才能在真机上使用。模拟器上可以测试大部分功能，但通知和iCloud同步需要真机测试。
