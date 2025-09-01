/// Path库 - 跨平台路径处理
/// 
/// 这个库提供了跨平台的路径操作功能，支持Unix和Windows平台

///|
/// 平台配置
let platform = "unix"

///|
/// Path结构体定义
/// 表示一个文件系统路径
pub struct Path {
  /// 路径的各个组件
  components : Array[String]
  /// 是否为绝对路径
  is_absolute : Bool
}

///|
/// 获取平台分隔符
fn get_separator() -> String {
  if platform == "windows" {
    "\\"
  } else {
    "/"
  }
}

///|
/// 获取当前工作目录
fn get_current_dir() -> String {
  match @env.current_dir() {
    Some(dir) => dir
    None => "unknown"
  }
}

///|
/// 检查字符是否为路径分隔符
fn is_separator(c : String) -> Bool {
  if platform == "windows" {
    c == "\\" || c == "/"
  } else {
    c == "/"
  }
}

///|
/// Path构造函数
/// 从字符串创建Path对象
/// 
/// # 参数
/// - `path_str`: 路径字符串
/// 
/// # 返回值
/// 返回新的Path对象
/// 
/// # 示例
/// ```mbt
/// let p1 = Path::new("/home/user/file.txt") //  创建绝对路径
/// let p2 = Path::new("relative/path") // 创建相对路径
///
/// inspect(p1, content="/home/user/file.txt")
/// inspect(p2, content="relative/path")
/// ```
pub fn Path::new(path_str : String) -> Path {
  if path_str == "" {
    return { components: [], is_absolute: false }
  }
  let is_abs = if platform == "windows" {
    // Windows: 检查是否以驱动器字母开头或UNC路径
    path_str.length() >= 2 &&
    (
      path_str.substring(start=1, end=2) == ":" ||
      path_str.strip_prefix("\\\\") != None
    )
  } else {
    // Unix: 检查是否以/开头
    path_str.strip_prefix("/") != None
  }

  // 分割路径字符串
  let parts = split_path(path_str)
  let components = Array::new()
  for part in parts {
    if part != "" && part != "." {
      if part == ".." {
        // 处理父目录
        if components.length() > 0 &&
          components[components.length() - 1] != ".." {
          if is_abs || components[components.length() - 1] != ".." {
            components.pop() |> ignore
          } else {
            components.push(part)
          }
        } else if not(is_abs) {
          components.push(part)
        }
      } else {
        components.push(part)
      }
    }
  }
  { components, is_absolute: is_abs }
}

///|
/// 分割路径字符串
fn split_path(path : String) -> Array[String] {
  let result = Array::new()
  let mut current = ""
  for i = 0; i < path.length(); i = i + 1 {
    let char = path.substring(start=i, end=i + 1)
    if is_separator(char) {
      if current != "" {
        result.push(current)
        current = ""
      }
    } else {
      current = current + char
    }
  }
  if current != "" {
    result.push(current)
  }
  result
}

///|
/// 向路径添加组件
/// 
/// # 参数
/// - `component`: 要添加的路径组件
/// 
/// # 示例
/// ```
/// let p = Path::new("/home/user")
/// p.push("documents")
/// p.push("file.txt")
/// ```
pub fn Path::push(self : Path, component : String) -> Unit {
  if component == "" || component == "." {
    return
  }
  if component == ".." {
    let _ = self.pop()

  } else {
    // 如果组件包含分隔符，需要分割
    let parts = split_path(component)
    for part in parts {
      if part != "" && part != "." {
        if part == ".." {
          let _ = self.pop()

        } else {
          self.components.push(part)
        }
      }
    }
  }
}

///|
/// 移除路径的最后一个组件
/// 
/// # 示例
/// ```mbt
/// let p = Path::new("/home/user/file.txt")
/// let _ = p.pop() // 现在路径是 "/home/user"
/// inspect(p, content="/home/user")
/// ```
pub fn Path::pop(self : Path) -> String? {
  if self.components.length() > 0 {
    self.components.pop()
  } else {
    None
  }
}

///|
pub fn Path::is_dir(self : Path) -> Bool {
  let s = self.to_string()
  @fs.is_dir(s) catch {
    _ => false
  }
}

///|
pub fn Path::is_file(self : Path) -> Bool {
  let s = self.to_string()
  @fs.is_file(s) catch {
    _ => false
  }
}

///|
pub fn Path::is_exists(self : Path) -> Bool {
  let s = self.to_string()
  @fs.path_exists(s)
}

///|
pub fn Path::file_name(self : Path) -> String? {
  let len = self.components.length()
  if len > 0 {
    if self.is_file() {
      Some(self.components[len - 1])
    } else {
      None
    }
  } else {
    None
  }
}

///|
pub fn Path::parent(self : Path) -> Path? {
  let len = self.components.length()
  if len == 0 {
    None
  } else {
    let parent_components = Array::new()
    for i = 0; i < len - 1; i = i + 1 {
      parent_components.push(self.components[i])
    }
    Some({ components: parent_components, is_absolute: self.is_absolute })
  }
}

///|
/// 将路径转换为绝对路径
/// 如果路径已经是绝对路径，则直接返回其字符串表示
/// 如果是相对路径，则与当前工作目录组合生成绝对路径
/// 
/// # 返回值
/// 返回绝对路径的字符串表示
/// 
/// # 示例
pub fn Path::to_absolute(self : Path) -> String {
  if self.is_absolute {
    self.to_string()
  } else {
    let current_dir = get_current_dir()
    let current_path = Path::new(current_dir)
    // 将当前路径的组件复制到新的组件数组中
    let absolute_components = Array::new()
    for component in current_path.components {
      absolute_components.push(component)
    }
    // 添加相对路径的组件
    for component in self.components {
      if component == ".." {
        // 处理父目录
        if absolute_components.length() > 0 {
          absolute_components.pop() |> ignore
        }
      } else {
        absolute_components.push(component)
      }
    }

    // 构建绝对路径字符串
    let sep = get_separator()
    if absolute_components.length() == 0 {
      sep
    } else {
      let mut result = sep
      for i = 0; i < absolute_components.length(); i = i + 1 {
        if i > 0 {
          result = result + sep
        }
        result = result + absolute_components[i]
      }
      result
    }
  }
}

///|
///
/// ```mbt
/// let p1 = Path::new("/home/user/file.txt")
/// let p2 = Path::new("relative/path")
/// inspect(p1.to_string(), content="/home/user/file.txt")
/// inspect(p2.to_string(), content="relative/path")
/// ```
pub impl Show for Path with output(self, logger) {
  let sep = get_separator()
  let s = if self.is_absolute {
    if platform == "windows" {
      // Windows绝对路径处理
      if self.components.length() > 0 {
        let first = self.components[0]
        if first.length() == 2 && first.substring(start=1, end=2) == ":" {
          // 驱动器路径
          let mut result = first + sep
          for i = 1; i < self.components.length(); i = i + 1 {
            if i > 1 {
              result = result + sep
            }
            result = result + self.components[i]
          }
          result
        } else {
          // UNC路径或其他绝对路径
          let mut result = sep
          for i = 0; i < self.components.length(); i = i + 1 {
            if i > 0 {
              result = result + sep
            }
            result = result + self.components[i]
          }
          result
        }
      } else {
        sep
      }
    } else {
      // Unix绝对路径
      let mut result = sep
      for i = 0; i < self.components.length(); i = i + 1 {
        if i > 0 {
          result = result + sep
        }
        result = result + self.components[i]
      }
      result
    }
    // 相对路径
  } else if self.components.length() == 0 {
    "."
  } else {
    let mut result = ""
    for i = 0; i < self.components.length(); i = i + 1 {
      if i > 0 {
        result = result + sep
      }
      result = result + self.components[i]
    }
    result
  }
  logger.write_string(s)
}
