# Radxa Cubie A7A Armbian 自动构建

基于 GitHub Actions 的 Armbian 第三方固件自动编译与发布仓库，目标设备为 **Radxa Cubie A7A**。

## 编译参数

| 参数 | 值 |
|------|----|
| Board | `radxa-cubie-a7a` |
| Release | `trixie` (Debian 13) |
| Kernel Branch | `vendor` |
| Desktop | 关闭 |
| Minimal | 关闭 |

上游源码仓库：[NickAlilovic/build](https://github.com/NickAlilovic/build)，分支 `Radxa-A7A`。

## 触发方式

- **手动触发**：在 GitHub Actions 页面点击 "Run workflow"，可选 `force_build` 强制构建。
- **自动触发**：每 6 小时检测上游 `Radxa-A7A` 分支是否有新 commit，有则自动编译。已构建过的 commit 会被跳过。

## 定制内容

- **内核配置追加**：启用 `CONFIG_IP_ADVANCED_ROUTER`、`CONFIG_IP_MULTIPLE_TABLES`、`CONFIG_IPV6_MULTIPLE_TABLES`。
- **镜像源预设**：Debian 和 Armbian 软件源替换为 USTC 镜像，首次开机即生效。

## 仓库结构

```
.github/workflows/build.yml   # GitHub Actions 工作流
userpatches/lib.config         # 内核配置追加
userpatches/customize-image.sh # 镜像源定制
agent.md                       # 任务约束与实施说明
README.md                      # 本文件
```

## Release 命名

格式：`Armbian_<版本号>_<上游commit短hash>`

编译产物通过 GitHub Release 发布，不纳入 Git 仓库。
