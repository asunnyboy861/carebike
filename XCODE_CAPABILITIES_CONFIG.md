# BikeCare Pro - Xcode Capabilities 配置指南

本文档说明需要在 Xcode 中手动配置的 Capabilities 和设置。

---

## 1. 项目基本信息设置

### Bundle Identifier
1. 选择项目 → 选择 Target → General
2. 设置 Bundle Identifier: `com.zzoutuo.carebike`

### Deployment Info
1. iOS Deployment Target: `iOS 17.0`
2. Devices: `iPhone`, `iPad`

---

## 2. 必需的 Capabilities 配置

### 2.1 iCloud (CloudKit) ✅ 已配置

**用途**: 数据同步到 iCloud，实现跨设备数据同步

**配置步骤**:
1. 选择项目 → 选择 Target → Signing & Capabilities
2. 点击 `+ Capability`
3. 搜索并添加 `iCloud`
4. 在 iCloud 部分:
   - 勾选 `CloudKit`
   - 点击 `+` 添加 Container
   - Container 名称: `iCloud.com.zzoutuo.carebike`

**注意事项**:
- 需要有效的 Apple Developer 账户
- CloudKit Container 需要在 Developer Portal 中创建

---

### 2.2 Background Modes ✅ 已配置

**用途**: 支持后台位置追踪和后台任务

**配置步骤**:
1. 选择项目 → 选择 Target → Signing & Capabilities
2. 点击 `+ Capability`
3. 搜索并添加 `Background Modes`
4. 勾选以下选项:
   - ✅ Location updates
   - ✅ Background fetch
   - ✅ Background processing

---

### 2.3 Push Notifications ✅ 已配置

**用途**: 发送维护提醒和组件更换通知

**配置步骤**:
1. 选择项目 → 选择 Target → Signing & Capabilities
2. 点击 `+ Capability`
3. 搜索并添加 `Push Notifications`

**注意**: 此功能需要 Apple Developer 账户和 APNs 配置

---

### 2.4 App Groups ✅ 已配置

**用途**: 在 App 和 Widget 之间共享数据

**配置步骤**:
1. 选择项目 → 选择 Target → Signing & Capabilities
2. 点击 `+ Capability`
3. 搜索并添加 `App Groups`
4. 点击 `+` 添加 App Group
5. App Group ID: `group.com.zzoutuo.carebike`

---

## 3. Info.plist 配置 ✅ 已配置

### 3.1 位置权限描述

在 Info.plist 中已添加以下键值:

| Key | Value |
|-----|-------|
| `NSLocationWhenInUseUsageDescription` | "BikeCare needs your location to track your rides and record distance." |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | "BikeCare needs your location to track rides in background and provide accurate distance measurements." |
| `NSLocationAlwaysUsageDescription` | "BikeCare needs your location to track rides in background." |

### 3.2 后台模式描述

| Key | Value |
|-----|-------|
| `UIBackgroundModes` | `location`, `fetch`, `processing` |

---

## 4. Privacy Manifest (PrivacyInfo.xcprivacy) ✅ 已配置

文件已创建在: `/Volumes/Untitled/app/20260309/carebike/carebike/carebike/PrivacyInfo.xcprivacy`

包含以下配置:
- 位置数据收集声明
- UserDefaults API 访问
- FileTimestamp API 访问
- CloudKit API 访问

---

## 5. 代码配置 ✅ 已更新

### 5.1 PersistenceController.swift
已更新为使用正确的标识符:
- App Group: `group.com.zzoutuo.carebike`
- CloudKit Container: `iCloud.com.zzoutuo.carebike`

### 5.2 Constants.swift
已添加标识符常量:
```swift
enum Storage {
    static let appGroupIdentifier = "group.com.zzoutuo.carebike"
    static let cloudKitContainerIdentifier = "iCloud.com.zzoutuo.carebike"
}
```

---

## 6. Signing & Capabilities 完整配置清单

配置完成后，您的 Signing & Capabilities 应包含:

| Capability | 状态 | 标识符 |
|------------|------|---------|
| ✅ App Groups | 已配置 | `group.com.zzoutuo.carebike` |
| ✅ Background Modes | 已配置 | Location updates, Background fetch, Background processing |
| ✅ iCloud | 已配置 | `iCloud.com.zzoutuo.carebike` |
| ✅ Push Notifications | 已配置 | - |

---

## 7. Apple Developer Portal 配置

### 7.1 创建 App ID
1. 登录 [Apple Developer](https://developer.apple.com)
2. 进入 Certificates, Identifiers & Profiles
3. 创建新的 App ID: `com.zzoutuo.carebike`
4. 启用以下服务:
   - iCloud (CloudKit)
   - Push Notifications
   - App Groups

### 7.2 创建 CloudKit Container
1. 在 Developer Portal 中创建 CloudKit Container
2. Container ID: `iCloud.com.zzoutuo.carebike`
3. 关联到 App ID: `com.zzoutuo.carebike`

### 7.3 创建 App Group
1. 在 Developer Portal 中创建 App Group
2. Group ID: `group.com.zzoutuo.carebike`
3. 关联到 App ID: `com.zzoutuo.carebike`

### 7.4 创建 Provisioning Profile
1. 创建 Development Provisioning Profile
2. 选择 App ID: `com.zzoutuo.carebike`
3. 选择开发证书
4. 选择测试设备
5. 下载并导入 Xcode

---

## 8. 可选配置

### 8.1 HealthKit (可选)
如果需要与 Apple Health 集成:
1. 添加 `HealthKit` Capability
2. 在 Info.plist 添加:
   - `NSHealthShareUsageDescription`
   - `NSHealthUpdateUsageDescription`

### 8.2 Sign in with Apple (可选)
如果提供社交登录:
1. 添加 `Sign in with Apple` Capability
2. 必须实现 Apple 登录功能

---

## 9. 测试配置

### 9.1 验证 iCloud
```swift
// 在代码中验证
let container = CKContainer(identifier: "iCloud.com.zzoutuo.carebike")
container.accountStatus { status, error in
    print("iCloud status: \(status)")
}
```

### 9.2 验证位置权限
运行 App 后，应该弹出位置权限请求对话框。

### 9.3 验证通知
```swift
// 在代码中测试
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
    print("Notification granted: \(granted)")
}
```

---

## 10. 常见问题

### Q: CloudKit 同步不工作?
A: 确保:
- 已登录 iCloud 账户
- 设备网络正常
- Container ID 正确: `iCloud.com.zzoutuo.carebike`

### Q: 后台位置追踪不工作?
A: 确保:
- 已请求 "Always" 位置权限
- Background Modes 中已勾选 Location updates
- 设备设置中允许后台应用刷新

### Q: 通知不显示?
A: 确保:
- 已请求通知权限
- 设备设置中允许通知
- App 在前台时需要处理通知

---

## 11. 配置完成检查表

- [x] Bundle Identifier 已设置: `com.zzoutuo.carebike`
- [x] iCloud Capability 已添加并配置 Container: `iCloud.com.zzoutuo.carebike`
- [x] Background Modes 已添加并勾选必要选项
- [x] Push Notifications 已添加
- [x] App Groups 已添加: `group.com.zzoutuo.carebike`
- [x] Info.plist 位置权限描述已添加
- [x] Privacy Manifest 已创建
- [ ] Apple Developer Portal 中 App ID 已创建
- [ ] Apple Developer Portal 中 CloudKit Container 已创建
- [ ] Apple Developer Portal 中 App Group 已创建
- [ ] Provisioning Profile 已下载并安装
- [x] 项目编译成功
- [ ] 真机测试通过

---

## 12. 下一步操作

1. 在 Apple Developer Portal 创建以下资源:
   - App ID: `com.zzoutuo.carebike`
   - CloudKit Container: `iCloud.com.zzoutuo.carebike`
   - App Group: `group.com.zzoutuo.carebike`
   - Provisioning Profile

2. 在 Xcode 中选择正确的 Team

3. Clean Build Folder (Cmd+Shift+K)

4. 重新编译项目

5. 在真机上测试运行

---

**文档版本**: 1.1  
**最后更新**: 2026-03-12  
**Bundle ID**: `com.zzoutuo.carebike`
