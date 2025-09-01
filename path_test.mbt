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
  path.pop()
  inspect(path.to_string(), content="/home/user/documents")
  path.pop()
  inspect(path.to_string(), content="/home/user")

  // 测试空路径的pop
  let empty_path = Path::new("")
  empty_path.pop()
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
  path.pop()
  path.push("desktop")
  path.push("project")
  inspect(path.to_string(), content="/home/user/desktop/project")
}
