///|
fn main {
  // 演示Path库的基本功能

  // 创建Unix路径
  let unix_path = @lib.Path::new("/home/user/documents")
  println("Unix路径: \{unix_path.to_string()}")

  // 添加文件名
  unix_path.push("file.txt")
  println("添加文件名后: \{unix_path.to_string()}")

  // 创建相对路径
  let relative_path = @lib.Path::new("src/lib")
  println("相对路径: \{relative_path.to_string()}")

  // 添加多个组件
  relative_path.push("utils")
  relative_path.push("helper.mbt")
  println("添加组件后: \{relative_path.to_string()}")

  // 演示pop操作
  relative_path.pop()
  println("Pop后: \{relative_path.to_string()}")

  // 演示复杂路径处理
  let complex_path = @lib.Path::new("./src/../lib/./utils")
  println("复杂路径规范化: \{complex_path.to_string()}")
}
