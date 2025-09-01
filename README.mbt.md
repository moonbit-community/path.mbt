# Path Library - Cross-Platform Path Handling for MoonBit

A powerful, cross-platform file path manipulation library for MoonBit, providing intuitive and robust APIs for handling file paths on both Unix-like and Windows systems.

## Features

- ✅ **Cross-Platform:** Consistent behavior on Unix/Linux/macOS and Windows.
- ✅ **Path Normalization:** Automatically handles `.` (current directory) and `..` (parent directory).
- ✅ **Intuitive API:** Easy-to-use methods like `push` and `pop` for path manipulation.
- ✅ **Absolute & Relative Paths:** Correctly identifies and manages both absolute and relative paths.
- ✅ **Show Trait:** Implements the `Show` trait for easy printing and string interpolation.
- ✅ **Robust Parsing:** Handles multiple separators and other common path quirks.

## Quick Start

### Basic Usage

```moonbit
test "Basic Path Operations" {
  // Create a new path
  let path = @path.Path::new("/home/user")
  inspect(path.to_string(), content="/home/user")
  
  // Push new components
  path.push("documents")
  path.push("file.txt")
  inspect(path.to_string(), content="/home/user/documents/file.txt")
  
  // Pop the last component
  let _ = path.pop()
  inspect(path.to_string(), content="/home/user/documents")
}
```

### Path Normalization

The library automatically cleans up paths, resolving `.` and `..`.

```moonbit
test "Path Normalization" {
  let path = @path.Path::new("/home/user/../documents/./file.txt")
  inspect(path.to_string(), content="/home/documents/file.txt")
  
  let relative = @path.Path::new("src/../lib/./utils")
  inspect(relative.to_string(), content="lib/utils")
}
```

### Platform Support

The library abstracts away the differences between platforms.

- **Unix/Linux/macOS:** Uses `/` as the separator. Paths starting with `/` are absolute.
- **Windows:** Uses `\` as the separator. Supports drive letters (`C:\`) and UNC paths (`\\server\share`). It also correctly handles forward slashes (`/`) as separators for better compatibility.

*Note: The current implementation defaults to Unix behavior. To enable Windows-specific logic, you can modify the internal `platform` variable.*

## API Reference

### `struct Path`
Represents a file system path.

- `components: Array[String]` - The individual parts of the path.
- `is_absolute: Bool` - `true` if the path is absolute.

### Methods

#### `Path::new(path_str: String) -> Path`
Creates a new `Path` object from a string.

```moonbit skip
let path = Path::new("/home/user/file.txt")
let relative = Path::new("src/lib")
```

#### `Path::push(self: Path, component: String) -> Unit`
Appends a new component to the path. If the component contains separators, it will be split accordingly.

```moonbit skip
path.push("documents")
path.push("sub/dir") // Automatically split into "sub" and "dir"
```

#### `Path::pop(self: Path) -> Unit`
Removes the last component from the path.

```moonbit skip
let _ = path.pop()
```

#### `Path::to_string(self: Path) -> String`
Converts the path into its string representation.

#### `Show` Trait
The `Path` type implements `Show`, allowing for direct use in string interpolation.

```moonbit skip
let path = Path::new("/home/user")
println("The path is: \{path}") // Output: The path is: /home/user
```

## License

This project is licensed under the Apache-2.0 License.

---

# Path 库 - MoonBit 跨平台路径处理库

一个功能强大、跨平台的文件路径处理库，为 MoonBit 提供了在 Unix 和 Windows 系统上直观且健壮的路径操作 API。

## 特性

- ✅ **跨平台支持:** 在 Unix/Linux/macOS 和 Windows 上行为一致。
- ✅ **路径规范化:** 自动处理 `.` (当前目录) 和 `..` (父目录)。
- ✅ **直观的 API:** 提供易于使用的 `push` 和 `pop` 等方法来操作路径。
- ✅ **绝对与相对路径:** 能正确识别和管理绝对路径与相对路径。
- ✅ **Show Trait:** 实现了 `Show` 特征，便于打印和字符串插值。
- ✅ **健壮的解析:** 能处理多个连续的分隔符和其他常见的路径问题。

## 快速开始

### 基本使用

```moonbit
test "基本路径操作" {
  // 创建一个新路径
  let path = @path.Path::new("/home/user")
  inspect(path.to_string(), content="/home/user")
  
  // 添加新的路径组件
  path.push("documents")
  path.push("file.txt")
  inspect(path.to_string(), content="/home/user/documents/file.txt")
  
  // 移除最后一个组件
  let _ = path.pop()
  inspect(path.to_string(), content="/home/user/documents")
}
```

### 路径规范化

该库会自动清理路径，解析 `.` 和 `..`。

```moonbit
test "路径规范化" {
  let path = @path.Path::new("/home/user/../documents/./file.txt")
  inspect(path.to_string(), content="/home/documents/file.txt")
  
  let relative = @path.Path::new("src/../lib/./utils")
  inspect(relative.to_string(), content="lib/utils")
}
```

### 平台支持

该库抽象了不同平台之间的差异。

- **Unix/Linux/macOS:** 使用 `/` 作为分隔符。以 `/` 开头的路径是绝对路径。
- **Windows:** 使用 `\` 作为分隔符。支持驱动器号 (`C:\`) 和 UNC 路径 (`\\server\share`)。同时为了更好的兼容性，它也能正确处理正斜杠 (`/`) 作为分隔符。

*注意：当前实现默认为 Unix 行为。要启用 Windows 特定的逻辑，可以修改内部的 `platform` 变量。*

## API 参考

### `struct Path`
表示一个文件系统路径。

- `components: Array[String]` - 路径的各个组成部分。
- `is_absolute: Bool` - 如果路径是绝对路径，则为 `true`。

### 方法

#### `Path::new(path_str: String) -> Path`
从字符串创建一个新的 `Path` 对象。

```moonbit skip
let path = Path::new("/home/user/file.txt")
let relative = Path::new("src/lib")
```

#### `Path::push(self: Path, component: String) -> Unit`
向路径追加一个新组件。如果组件包含分隔符，它将被相应地拆分。

```moonbit skip
path.push("documents")
path.push("sub/dir") // 会被自动拆分为 "sub" 和 "dir"
```

#### `Path::pop(self: Path) -> Unit`
从路径中移除最后一个组件。

```moonbit skip
path.pop()
```

#### `Path::to_string(self: Path) -> String`
将路径转换为其字符串表示形式。

#### `Show` Trait
`Path` 类型实现了 `Show` 特征，允许在字符串插值中直接使用。

```moonbit skip
let path = Path::new("/home/user")
println("路径是: \{path}") // 输出: 路径是: /home/user
```

## 许可证

本项目采用 Apache-2.0 许可证。
