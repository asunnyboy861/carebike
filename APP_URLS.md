# CareBike App URLs 配置

本文档记录了 CareBike 应用相关的所有重要 URL，用于 App Store 提交和应用内使用。

## 必需链接（App Store 提交）

### 1. 技术支持页面
- **URL**: `https://carebike-support.zzoutuo.com`
- **用途**: 
  - App Store Connect 技术支持 URL 字段
  - 应用内"关于"页面 - 帮助与支持链接
- **部署位置**: GitHub Pages (asunnyboy861/carebike-support)
- **自定义域名**: carebike-support.zzoutuo.com
- **联系邮箱**: iocompile67692@gmail.com

### 2. 隐私政策页面
- **URL**: `https://carebike-privacy.zzoutuo.com`
- **用途**: 
  - App Store Connect 隐私政策 URL 字段
  - 应用内"关于"页面 - 隐私政策链接
  - iOS 隐私清单 (PrivacyInfo.xcprivacy) 引用
- **部署位置**: GitHub Pages (asunnyboy861/carebike-privacy)
- **自定义域名**: carebike-privacy.zzoutuo.com
- **最后更新**: 2025 年 3 月 14 日

## 应用内使用示例

### Swift 代码中使用

```swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("Support") {
                Link("技术支持", destination: URL(string: "https://carebike-support.zzoutuo.com")!)
                Link("隐私政策", destination: URL(string: "https://carebike-privacy.zzoutuo.com")!)
            }
            
            Section("Contact") {
                Link("发送邮件", destination: URL(string: "mailto:iocompile67692@gmail.com")!)
            }
        }
    }
}
```

### 在 Info.plist 中配置

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>mailto</string>
    <string>https</string>
</array>
```

## App Store Connect 配置

提交 App 时，在以下字段填写对应 URL：

1. **技术支持 URL** (Support URL)
   - 填写：`https://carebike-support.zzoutuo.com`

2. **隐私政策 URL** (Privacy Policy URL)
   - 填写：`https://carebike-privacy.zzoutuo.com`

3. **营销 URL** (Marketing URL) - 可选
   - 可填写技术支持 URL 或官网地址

## 维护说明

- 当需要更新政策内容时，修改对应 GitHub 仓库的 `index.html` 文件
- 推送后会自动同步到自定义域名
- 隐私政策更新日期应在页面中更新

## 相关文件

- 本地源文件：
  - `/support/index.html` - 技术支持页面源文件
  - `/privacy/index.html` - 隐私政策页面源文件
  
- GitHub 仓库：
  - `git@github.com:asunnyboy861/carebike-support.git`
  - `git@github.com:asunnyboy861/carebike-privacy.git`
