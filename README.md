# rime-greek-mizuochi

一个面向多调希腊文的 Rime 输入方案。基础字母采用近似 ELOT 1260 的键位，附加符号放在字母后输入；送气、重音、下标 iota 等附加成分可以乱序输入。

## 特性

- 多调希腊文预组字符输出。
- 附加成分顺序自由，例如 `aJq/`、`aq/J`、`a/qJ` 都输出 `ᾅ`。
- `q` 表示粗气，`Q` 表示柔气；单独输入 `q`/`Q` 时输出希腊标点。
- 不可继续组合时自动提交，适合连续输入单词。
- 输入 `;help` 查看方案内置帮助。

## 安装

需要 Rime 和 librime-lua。

把这些文件复制到 Rime 用户目录：

```text
greek_mizuochi.schema.yaml
greek_mizuochi.dict.yaml
lua/greek_mizuochi_core.lua
lua/greek_mizuochi_translator.lua
lua/greek_mizuochi_auto_commit.lua
```

如果你的 Rime 用户目录没有 `rime.lua`，也复制本仓库的 `rime.lua`。

如果已经有 `rime.lua`，只需要把下面两行合并进去：

```lua
greek_mizuochi_auto_commit = require("greek_mizuochi_auto_commit")
greek_mizuochi_translator = require("greek_mizuochi_translator")
```

然后在 `default.custom.yaml` 或你的方案列表里加入：

```yaml
patch:
  schema_list:
    - schema: greek_mizuochi
```

重新部署 Rime 后，选择「古希腊语」即可使用。

## 键位

| 输入 | 输出 |
| --- | --- |
| `a b g d e` | `α β γ δ ε` |
| `z h u i k l m n` | `ζ η θ ι κ λ μ ν` |
| `j o p r s t y f x c v` | `ξ ο π ρ σ τ υ φ χ ψ ω` |
| `w` | `ς` |
| `A B G D ...` | `Α Β Γ Δ ...` |

## 附加符号

| 输入 | 含义 | 示例 |
| --- | --- | --- |
| `q` 或 `` ` `` | 粗气 | `aq` -> `ἁ`, `eq` -> `ἑ` |
| `Q` 或 `'` | 柔气 | `aQ` -> `ἀ`, `eQ` -> `ἐ` |
| `/` | 锐音 | `o/` -> `ό` |
| `?` | 钝音 | `o?` -> `ὸ` |
| `^` 或 `\` | 曲音 | `a^` -> `ᾶ` |
| `J` | 下标 iota | `aJ` -> `ᾳ` |
| `"` | 分音符 | `i"` -> `ϊ`, `y"` -> `ϋ` |

附加符号的顺序不固定：

```text
aJq/ = aq/J = a/qJ = ᾅ
vJQ? = v?QJ = vQJ? = ᾢ
```

## 标点

| 输入 | 输出 |
| --- | --- |
| `q` | `·` |
| `Q` | `;` |

`q`/`Q` 接在基础字母或附加符号后时，分别作为粗气/柔气处理；单独输入时才作为标点。

## 开发

语法检查：

```sh
luac -p lua/greek_mizuochi_core.lua lua/greek_mizuochi_translator.lua lua/greek_mizuochi_auto_commit.lua rime.lua
```

单方案编译检查：

```sh
rime_deployer --compile greek_mizuochi.schema.yaml "$PWD" "$PWD" "$PWD/build"
```
