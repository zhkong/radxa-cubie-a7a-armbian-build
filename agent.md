# Agent.md

## 目标

在本仓库中维护一个基于 GitHub Actions 的 Armbian 第三方固件编译方案，目标设备为 `Radxa cubie a7a`。
上游源码仓库为：`https://github.com/NickAlilovic/build.git`
跟踪分支为：`Radxa-A7A`

本仓库的职责不是直接保存编译产物源码修改以外的二进制内容，而是作为自动化编译与发布的管理仓库，使用 Git 管理工作流、说明文档、补丁和用户定制内容。

## 交付范围

本仓库后续应包含但不限于以下内容：

- GitHub Actions 工作流定义，用于自动拉取上游 `Radxa-A7A` 分支并执行编译。
- 用于 Armbian 构建系统的用户补丁与定制文件。
- 版本命名与 Release 发布规则说明。
- 上游同步策略说明。
- 编译参数与内核附加配置说明。

当前阶段只生成文档，不直接生成实现代码。

## 编译目标

- 设备：`Radxa cubie a7a`
- 系统：`Debian 13`
- Armbian Release 参数：`trixie`
- 内核分支：`vendor`
- 图形桌面：关闭
- 最小化构建：关闭

标准编译命令：

```bash
./compile.sh build BOARD=radxa-cubie-a7a BRANCH=vendor BUILD_DESKTOP=no BUILD_MINIMAL=no RELEASE=trixie
```

## Git 管理要求

- 本目录必须作为独立 Git 仓库维护。
- 默认开发分支建议使用 `main`。
- 所有对工作流、补丁、文档和定制脚本的修改都通过 Git 提交管理。
- 禁止将大体积编译产物直接提交到 Git 仓库。
- 编译产物应通过 GitHub Release 发布，而不是纳入版本库。

## 上游仓库策略

上游仓库信息：

- URL：`https://github.com/NickAlilovic/build.git`
- Branch：`Radxa-A7A`

后续实现时应遵循以下策略：

- GitHub Actions 在运行时拉取或检出上游仓库 `Radxa-A7A` 分支内容作为编译源。
- 需要具备手动触发能力，便于按需发起编译。
- 需要具备自动触发能力，当上游 `Radxa-A7A` 分支出现新的 commit 时自动开始新的编译任务。
- 自动触发可以通过定时轮询对比最新 commit，或其他可稳定检测上游提交变化的机制实现。
- 为避免重复构建，应记录最近一次已构建的上游 commit，并在工作流中跳过未变化的重复任务。

## GitHub Actions 触发要求

后续工作流必须同时支持以下两类触发方式：

- 手动触发：允许在 GitHub Actions 页面中手动运行编译。
- 自动触发：当上游 `Radxa-A7A` 分支有新的 commit 时，自动开始编译。

推荐设计原则：

- 手动触发用于临时验证、强制重编译或测试变更。
- 自动触发用于持续跟踪上游分支。
- 自动触发逻辑应尽量减少无效运行，避免在上游无更新时重复浪费 GitHub Actions 额度。

## Release 命名规范

编译完成后发布 GitHub Release，Release 名称必须包含：

- Armbian 版本号
- 上游 commit hash

命名原则：

- 需要从编译结果或构建上下文中提取实际 Armbian 版本。
- commit hash 应对应本次构建所使用的上游 `Radxa-A7A` 最新提交。
- 建议使用短 hash，前提是仍能唯一标识该次构建来源。

示例格式（仅作命名参考，不代表固定字符串）：

```text
Armbian_<version>_<short_commit>
```

或

```text
armbian-<version>-<short_commit>
```

最终实现时必须保证名称中同时具备版本号与 commit hash。

## 内核附加配置要求

在编译过程中需要额外启用以下内核配置项：

- `CONFIG_IPV6_MULTIPLE_TABLES`
- `CONFIG_IP_MULTIPLE_TABLES`
- `CONFIG_IP_ADVANCED_ROUTER`

实现要求：

- 这些配置应以 Armbian 支持的用户补丁或内核配置追加方式纳入构建流程。
- 不应依赖手工交互式修改。
- 配置变更必须可重复、可追踪，并由 Git 管理。

## 镜像源定制要求

目标系统为 Debian 13，编译出的系统镜像默认软件源需要预设为 USTC 镜像。

实现要求：

- 必须通过 `userpatches/customize-image.sh` 在镜像生成阶段完成写入。
- 应将 Debian 默认仓库源直接替换为 USTC 镜像地址。
- 应将 Armbian 默认仓库源直接替换为 USTC 镜像地址。
- 该定制必须在首次开机前就已经生效，而不是依赖用户登录后再修改。
- 应确保与 `trixie` 目标系统版本匹配。

## 目录规划建议

后续实现时建议采用清晰的仓库结构，例如：

- `.github/workflows/`：GitHub Actions 工作流
- `userpatches/`：Armbian 用户补丁与定制脚本
- `docs/`：补充说明文档
- `agent.md`：本任务约束与实施说明

## 自动化实现约束

后续编写工作流或脚本时，应满足以下要求：

- 尽量复用上游 Armbian 构建逻辑，不重写核心编译流程。
- 所有自动化步骤应支持无交互运行。
- 对上游 commit 的识别、去重和发布命名应保持一致。
- Release 发布前应明确关联本次构建所用的版本号与 commit hash。
- 如果 GitHub Actions 运行环境需要额外依赖，应在工作流中显式声明。

## 验收标准

当后续实现完成时，应至少满足以下验收条件：

- 可以在 GitHub Actions 页面手动触发构建。
- 当上游 `Radxa-A7A` 分支有新的 commit 后，仓库能自动触发新的构建任务。
- 构建命令严格等价于指定命令参数。
- 产物面向 `radxa-cubie-a7a`，系统为 Debian 13。
- 内核包含指定的三项附加配置。
- 镜像默认软件源已经预设为 USTC。
- GitHub Release 名称包含 Armbian 版本号和上游 commit hash。
- 所有实现文件均由 Git 管理，编译产物不直接入库。

## 当前状态

当前仓库仅完成初始化与需求文档落地。
后续如果继续实施，应在本仓库中补充：

- GitHub Actions 工作流文件
- `userpatches/customize-image.sh`
- 内核配置补丁或配置追加文件
- 上游 commit 检测与去重机制
