# bstools

用工具同步本地环境，有点意思了不是吗？

## 使用须知

- **如果是已有环境，请先备份好$HOME下的已有配置文件，脚本涉及部分文件的删除替换。**

- **如果是 _intel_ 处理器需要手动预装 `Homebrew`。**
```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```
  
- **如果没有安装过 `Xcode Command Line`，需要手动安装。**
```
xcode-select --install
```

## 安装命令
```
curl https://raw.githubusercontent.com/orzcrz/bstools/master/setup.sh | bash
```

## 包含配置

- oh-my-zsh
- dk_lldb
- zlldb

### 工具包

- homebrew
- pyenv
- wget
- cookiecutter
- tree
- rbenv
- cocoapods
- lldb_chisel
- node

### 软链

- ~/.zshrc
- ~/.zsh_profile
- ~/.lldbinit
- ~/.pip
- ~/.gitignore_global

### App

- VSCode

## 附加项

### 关于git的提交附带表情

- 出处
在gitmoji里扒扒看 ，传送门：https://gitmoji.dev/

#### 常用emoji整理
<table>
  <thead>
    <tr>
      <th align="left">emoji</th>
      <th align="left">emoji 代码</th>
      <th align="left">commit 说明</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">🎉</td>
      <td align="left"><code>:tada:</code></td>
      <td align="left">初始化项目</td>
    </tr>
    <tr>
      <td align="left">🎨</td>
      <td align="left"><code>:art:</code></td>
      <td align="left">改进代码结构/代码格式</td>
    </tr>
    <tr>
      <td align="left">⚡️</td>
      <td align="left"><code>:zap:</code></td>
      <td align="left">提升性能</td>
    </tr>
    <tr>
      <td align="left">🔥</td>
      <td align="left"><code>:fire:</code></td>
      <td align="left">移除代码或文件</td>
    </tr>
    <tr>
      <td align="left">🐛</td>
      <td align="left"><code>:bug:</code></td>
      <td align="left">修复 BUG</td>
    </tr>
    <tr>
      <td align="left">🚑️</td>
      <td align="left"><code>:ambulance:</code></td>
      <td align="left">重要补丁</td>
    </tr>
    <tr>
      <td align="left">✨</td>
      <td align="left"><code>:sparkles:</code></td>
      <td align="left">引入新功能</td>
    </tr>
    <tr>
      <td align="left">📝</td>
      <td align="left"><code>:memo:</code></td>
      <td align="left">撰写文档</td>
    </tr>
    <tr>
      <td align="left">💄</td>
      <td align="left"><code>:lipstick:</code></td>
      <td align="left">更新 UI 和样式文件</td>
    </tr>
    <tr>
      <td align="left">♻️</td>
      <td align="left"><code>:recycle:</code></td>
      <td align="left">重大重构</td>
    </tr>
    <tr>
      <td align="left">🙈</td>
      <td align="left"><code>:see_no_evil:</code></td>
      <td align="left">更新.gitignore文件</td>
    </tr>
    <tr>
      <td align="left">➕</td>
      <td align="left"><code>:heavy_plus_sign:</code></td>
      <td align="left">加了依赖</td>
    </tr>
    <tr>
      <td align="left">⬆️</td>
      <td align="left"><code>:arrow_up:</code></td>
      <td align="left">依赖升级</td>
    </tr>
    <tr>
      <td align="left">⬇️</td>
      <td align="left"><code>:arrow_down:</code></td>
      <td align="left">依赖降级</td>
    </tr>
    <tr>
      <td align="left">⚰️</td>
      <td align="left"><code>:coffin:</code></td>
      <td align="left">清理dead code</td>
    </tr>
    <tr>
      <td align="left">🔧</td>
      <td align="left"><code>:wrench:</code></td>
      <td align="left">更新配置文件</td>
    </tr>
    <tr>
      <td align="left">🔨</td>
      <td align="left"><code>:hammer:</code></td>
      <td align="left">更新开发工具</td>
    </tr>
    <tr>
      <td align="left">📄</td>
      <td align="left"><code>:page_facing_up:</code></td>
      <td align="left">更新License</td>
    </tr>
    <tr>
      <td align="left">💡</td>
      <td align="left"><code>:bulb:</code></td>
      <td align="left">增加注释</td>
    </tr>
    <tr>
      <td align="left">🍱</td>
      <td align="left"><code>:bento:</code></td>
      <td align="left">更新资源文件</td>
    </tr>
  </tbody>
</table>