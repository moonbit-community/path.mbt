///|
test "Path::new - 基本路径创建" {
  let unix_abs = Path::new("/home/user")
  inspect(unix_abs.to_string(), content="/home/user")
  let unix_rel = Path::new("src/lib")
  inspect(unix_rel.to_string(), content="src/lib")
  let empty_path = Path::new("")
  inspect(empty_path.to_string(), content=".")
}

///|
test "Path::new - 路径规范化" {
  let path1 = Path::new("/home/user/../documents/./file.txt")
  inspect(path1.to_string(), content="/home/documents/file.txt")
  let path2 = Path::new("src/../lib/./utils")
  inspect(path2.to_string(), content="lib/utils")
  let path3 = Path::new("../../parent")
  inspect(path3.to_string(), content="../../parent")
}

///|
test "Path::push - 添加组件" {
  let path = Path::new("/home/user")
  path.push("documents")
  inspect(path.to_string(), content="/home/user/documents")
  path.push("file.txt")
  inspect(path.to_string(), content="/home/user/documents/file.txt")

  // 测试添加包含分隔符的组件
  let path2 = Path::new("base")
  path2.push("sub/dir")
  inspect(path2.to_string(), content="base/sub/dir")
}

///|
test "Path::push - 父目录处理" {
  let path = Path::new("/home/user/documents")
  path.push("..")
  inspect(path.to_string(), content="/home/user")
  let rel_path = Path::new("src/lib")
  rel_path.push("..")
  rel_path.push("test")
  inspect(rel_path.to_string(), content="src/test")
}

///|
test "Path::pop - 移除组件" {
  let path = Path::new("/home/user/documents/file.txt")
  let _ = path.pop()
  inspect(path.to_string(), content="/home/user/documents")
  let _ = path.pop()
  inspect(path.to_string(), content="/home/user")

  // 测试空路径的pop
  let empty_path = Path::new("")
  let _ = empty_path.pop()
  inspect(empty_path.to_string(), content=".")
}

///|
test "路径类型检测" {
  let abs_path = Path::new("/absolute/path")
  inspect(abs_path.is_absolute, content="true")
  let rel_path = Path::new("relative/path")
  inspect(rel_path.is_absolute, content="false")
  let current_path = Path::new(".")
  inspect(current_path.is_absolute, content="false")
}

///|
test "特殊字符和边界情况" {
  // 测试点和双点
  let path1 = Path::new("./current")
  inspect(path1.to_string(), content="current")
  let path2 = Path::new("../parent")
  inspect(path2.to_string(), content="../parent")

  // 测试多个连续分隔符
  let path3 = Path::new("/home//user///documents")
  inspect(path3.to_string(), content="/home/user/documents")

  // 测试只有分隔符的路径
  let root_path = Path::new("/")
  inspect(root_path.to_string(), content="/")
}

///|
test "复杂路径操作序列" {
  let path = Path::new("/")
  path.push("home")
  path.push("user")
  path.push("documents")
  inspect(path.to_string(), content="/home/user/documents")
  path.push("../downloads")
  inspect(path.to_string(), content="/home/user/downloads")
  let _ = path.pop()
  path.push("desktop")
  path.push("project")
  inspect(path.to_string(), content="/home/user/desktop/project")
}

///|
test "Path::to_absolute - 相对路径转绝对路径" {
  // 测试绝对路径保持不变
  let abs_path = Path::new("/home/user/file.txt")
  inspect(abs_path.to_absolute(), content="/home/user/file.txt")

  // 测试相对路径转换为绝对路径
  let rel_path = Path::new("relative/path")
  let abs_result = rel_path.to_absolute()
  // 绝对路径应该以/开头且包含原路径
  match abs_result.strip_prefix("/") {
    Some(_) => () // 以/开头，正确
    None =>
      if abs_result != "unknown" {
        fail("Absolute path should start with / or be 'unknown'")
      }
  }
  if abs_result != "unknown" && not(abs_result.contains("relative/path")) {
    fail("Absolute path should contain the relative path")
  }
}

///|
test "Path::to_string vs to_absolute 区别" {
  // 测试绝对路径：to_string和to_absolute应该相同
  let abs_path = Path::new("/home/user/file.txt")
  inspect(abs_path.to_string(), content="/home/user/file.txt")
  inspect(abs_path.to_absolute(), content="/home/user/file.txt")

  // 测试相对路径：to_string保持相对，to_absolute返回绝对
  let rel_path = Path::new("relative/path")
  inspect(rel_path.to_string(), content="relative/path")
  let abs_result = rel_path.to_absolute()
  // 验证to_absolute返回的是绝对路径
  match abs_result.strip_prefix("/") {
    Some(_) => () // 以/开头，正确
    None =>
      if abs_result != "unknown" {
        fail("to_absolute should return absolute path or 'unknown'")
      }
  }

  // 验证两者不同
  if rel_path.to_string() == abs_result {
    fail("to_string and to_absolute should differ for relative paths")
  }
}

///|
test "当前目录处理特殊情况" {
  // 测试空路径
  let empty_path = Path::new("")
  let abs_empty = empty_path.to_absolute()
  match abs_empty.strip_prefix("/") {
    Some(_) => () // 以/开头，正确
    None =>
      if abs_empty != "unknown" {
        fail("Empty path should resolve to absolute path or 'unknown'")
      }
  }

  // 测试当前目录
  let current_path = Path::new(".")
  let abs_current = current_path.to_absolute()
  match abs_current.strip_prefix("/") {
    Some(_) => () // 以/开头，正确
    None =>
      if abs_current != "unknown" {
        fail("Current directory should resolve to absolute path or 'unknown'")
      }
  }
}
