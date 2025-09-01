# Path库 - MoonBit跨平台路径处理库

一个功能强大的跨平台文件路径处理库，支持Unix和Windows平台的路径操作。

## 特性

- ✅ 跨平台支持 (Unix/Linux/macOS 和 Windows)
- ✅ 路径规范化和清理
- ✅ 直观的路径构建和操作API
- ✅ 正确处理相对路径和绝对路径
- ✅ 支持父目录(..)和当前目录(.)处理
- ✅ 实现Show trait，支持字符串插值

## 快速开始

### 基本使用

```moonbit
test "基本路径操作" {
  // 创建路径
  let path = @path.Path::new("/home/user")
  inspect(path.to_string(), content="/home/user")
  
  // 添加路径组件
  path.push("documents")
  path.push("file.txt")
  inspect(path.to_string(), content="/home/user/documents/file.txt")
  
  // 移除最后一个组件
  path.pop()
  inspect(path.to_string(), content="/home/user/documents")
}
```

### 路径规范化

库会自动处理路径规范化，包括`.`和`..`的处理：

```moonbit
test "路径规范化" {
  let path = @path.Path::new("/home/user/../documents/./file.txt")
  inspect(path.to_string(), content="/home/documents/file.txt")
  
  let relative = @path.Path::new("src/../lib/./utils")
  inspect(relative.to_string(), content="lib/utils")
}
```

### 相对路径处理

```moonbit
test "相对路径操作" {
  let path = @path.Path::new("src/lib")
  inspect(path.is_absolute, content="false")
  
  path.push("..")
  path.push("test")
  inspect(path.to_string(), content="src/test")
}
```

### 父目录处理

```moonbit
test "父目录处理" {
  let path = @path.Path::new("/home/user/documents")
  path.push("..")  // 回到父目录
  inspect(path.to_string(), content="/home/user")
  
  // 相对路径中的父目录处理
  let rel_path = @path.Path::new("../../parent")
  inspect(rel_path.to_string(), content="../../parent")
}
```

### 复杂路径操作

```moonbit
test "复杂路径序列" {
  let path = @path.Path::new("/")
  path.push("home")
  path.push("user")
  path.push("documents")
  inspect(path.to_string(), content="/home/user/documents")
  
  // 使用相对路径组件
  path.push("../downloads")
  inspect(path.to_string(), content="/home/user/downloads")
  
  path.pop()
  path.push("desktop")
  path.push("project")
  inspect(path.to_string(), content="/home/user/desktop/project")
}
```

### 特殊情况处理

```moonbit
test "边界情况" {
  // 空路径
  let empty = @path.Path::new("")
  inspect(empty.to_string(), content=".")
  
  // 根目录
  let root = @path.Path::new("/")
  inspect(root.to_string(), content="/")
  
  // 多个连续分隔符
  let messy = @path.Path::new("/home//user///documents")
  inspect(messy.to_string(), content="/home/user/documents")
  
  // 当前目录
  let current = @path.Path::new("./current")
  inspect(current.to_string(), content="current")
}
```

## API参考

### 结构体

#### `Path`
表示一个文件系统路径。

**字段：**
- `components: Array[String]` - 路径的各个组件
- `is_absolute: Bool` - 是否为绝对路径

### 方法

#### `Path::new(path_str: String) -> Path`
从字符串创建新的Path对象。

**参数：**
- `path_str` - 路径字符串

**返回值：**
- 新的Path对象

**示例：**

```moonbit skip
let path = Path::new("/home/user/file.txt")
let relative = Path::new("src/lib")
```

#### `Path::push(self: Path, component: String) -> Unit`
向路径添加一个组件。如果组件包含路径分隔符，会自动分割处理。

**参数：**
- `component` - 要添加的路径组件

**示例：**
```moonbit skip
path.push("documents")
path.push("sub/dir")  // 会自动分割为 "sub" 和 "dir"
```

#### `Path::pop(self: Path) -> Unit`
移除路径的最后一个组件。

**示例：**
```moonbit skip
path.pop()  // 移除最后一个组件
```

#### `Path::to_string(self: Path) -> String`
将路径转换为字符串表示。

**返回值：**
- 路径的字符串表示

#### Show Trait
Path类型实现了Show trait，支持在字符串插值中直接使用：

```moonbit skip
let path = Path::new("/home/user")
println("路径是: \{path}")  // 输出: 路径是: /home/user
```

## 平台支持

### Unix/Linux/macOS
- 使用 `/` 作为路径分隔符
- 以 `/` 开头的路径为绝对路径
- 正确处理 `.` 和 `..` 组件

### Windows
- 使用 `\` 作为路径分隔符  
- 支持驱动器路径 (如 `C:\`)
- 支持UNC路径 (如 `\\server\share`)
- 兼容正斜杠 `/` 作为分隔符

**注意：** 当前实现默认运行在Unix平台。Windows支持通过修改全局变量 `platform = "windows"` 启用。

## 许可证

Apache-2.0

## 贡献

欢迎提交Issue和Pull Request！

## 更新日志

### v0.1.0
- 初始版本
- 基本路径操作功能
- 跨平台支持
- 路径规范化
- 完整的测试覆盖
