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

///|
test "Path::extension - 获取文件扩展名" {
  // 测试普通文件扩展名
  let p1 = Path::new("file.txt")
  inspect(p1.extension(), content="Some(\"txt\")")
  
  let p2 = Path::new("/home/user/document.pdf")
  inspect(p2.extension(), content="Some(\"pdf\")")
  
  // 测试多个点的情况
  let p3 = Path::new("archive.tar.gz")
  inspect(p3.extension(), content="Some(\"gz\")")
  
  // 测试没有扩展名的文件
  let p4 = Path::new("/home/user/README")
  inspect(p4.extension(), content="None")
  
  // 测试只有点的情况（隐藏文件）
  let p5 = Path::new(".gitignore")
  inspect(p5.extension(), content="None")
  
  // 测试以点结尾
  let p6 = Path::new("file.")
  inspect(p6.extension(), content="None")
}

///|
test "Path::file_stem - 获取不带扩展名的文件名" {
  // 测试普通文件
  let p1 = Path::new("file.txt")
  inspect(p1.file_stem(), content="Some(\"file\")")
  
  let p2 = Path::new("/home/user/document.pdf")
  inspect(p2.file_stem(), content="Some(\"document\")")
  
  // 测试多个点的情况
  let p3 = Path::new("archive.tar.gz")
  inspect(p3.file_stem(), content="Some(\"archive.tar\")")
  
  // 测试没有扩展名
  let p4 = Path::new("/home/user/README")
  inspect(p4.file_stem(), content="Some(\"README\")")
  
  // 测试隐藏文件
  let p5 = Path::new(".gitignore")
  inspect(p5.file_stem(), content="Some(\".gitignore\")")
}

///|
test "Path::with_extension - 替换文件扩展名" {
  // 测试替换扩展名
  let p1 = Path::new("/home/user/file.txt")
  let p2 = p1.with_extension("md")
  inspect(p2.to_string(), content="/home/user/file.md")
  
  // 测试移除扩展名
  let p3 = Path::new("/home/user/file.txt")
  let p4 = p3.with_extension("")
  inspect(p4.to_string(), content="/home/user/file")
  
  // 测试没有扩展名的文件
  let p5 = Path::new("/home/user/README")
  let p6 = p5.with_extension("md")
  inspect(p6.to_string(), content="/home/user/README.md")
  
  // 测试相对路径
  let p7 = Path::new("src/main.mbt")
  let p8 = p7.with_extension("rs")
  inspect(p8.to_string(), content="src/main.rs")
  
  // 测试空路径
  let p9 = Path::new("")
  let p10 = p9.with_extension("txt")
  inspect(p10.to_string(), content=".")
}

///|
test "Path::join - 连接路径组件" {
  // 测试基本连接
  let p1 = Path::new("/home/user")
  let p2 = p1.join(["documents", "file.txt"])
  inspect(p2.to_string(), content="/home/user/documents/file.txt")
  
  // 测试空数组
  let p3 = Path::new("/home/user")
  let p4 = p3.join([])
  inspect(p4.to_string(), content="/home/user")
  
  // 测试相对路径
  let p5 = Path::new("src")
  let p6 = p5.join(["lib", "utils.mbt"])
  inspect(p6.to_string(), content="src/lib/utils.mbt")
  
  // 测试包含 .. 的组件
  let p7 = Path::new("/home/user")
  let p8 = p7.join(["documents", "..", "downloads"])
  inspect(p8.to_string(), content="/home/user/downloads")
  
  // 测试单个组件
  let p9 = Path::new("/home")
  let p10 = p9.join(["user"])
  inspect(p10.to_string(), content="/home/user")
}

///|
test "Path::starts_with - 检查路径前缀" {
  // 测试绝对路径前缀
  let p1 = Path::new("/home/user/documents")
  let prefix1 = Path::new("/home/user")
  inspect(p1.starts_with(prefix1), content="true")
  
  let prefix2 = Path::new("/home")
  inspect(p1.starts_with(prefix2), content="true")
  
  let prefix3 = Path::new("/home/user/documents")
  inspect(p1.starts_with(prefix3), content="true")
  
  // 测试不匹配的前缀
  let prefix4 = Path::new("/home/other")
  inspect(p1.starts_with(prefix4), content="false")
  
  let prefix5 = Path::new("/home/user/documents/file")
  inspect(p1.starts_with(prefix5), content="false")
  
  // 测试相对路径
  let p2 = Path::new("src/lib/utils")
  let prefix6 = Path::new("src")
  inspect(p2.starts_with(prefix6), content="true")
  
  let prefix7 = Path::new("src/lib")
  inspect(p2.starts_with(prefix7), content="true")
  
  // 测试绝对路径和相对路径混合
  let prefix8 = Path::new("/src")
  inspect(p2.starts_with(prefix8), content="false")
}

///|
test "Path::ends_with - 检查路径后缀" {
  // 测试绝对路径后缀
  let p1 = Path::new("/home/user/documents/file.txt")
  let suffix1 = Path::new("file.txt")
  inspect(p1.ends_with(suffix1), content="true")
  
  let suffix2 = Path::new("documents/file.txt")
  inspect(p1.ends_with(suffix2), content="true")
  
  let suffix3 = Path::new("user/documents/file.txt")
  inspect(p1.ends_with(suffix3), content="true")
  
  // 测试不匹配的后缀
  let suffix5 = Path::new("other.txt")
  inspect(p1.ends_with(suffix5), content="false")
  
  // 绝对路径可以以相对路径的子部分结尾
  let suffix6 = Path::new("documents/file.txt")
  inspect(p1.ends_with(suffix6), content="true")
  
  // 测试完全相同的相对路径
  let p1_rel = Path::new("home/user/documents/file.txt")
  let suffix7 = Path::new("home/user/documents/file.txt")
  inspect(p1_rel.ends_with(suffix7), content="true")
  
  // 测试相对路径
  let p2 = Path::new("src/lib/utils.mbt")
  let suffix8 = Path::new("utils.mbt")
  inspect(p2.ends_with(suffix8), content="true")
  
  let suffix9 = Path::new("lib/utils.mbt")
  inspect(p2.ends_with(suffix9), content="true")
  
  // 测试空路径
  let empty1 = Path::new("")
  let empty2 = Path::new("")
  inspect(empty1.ends_with(empty2), content="true")
}

///|
test "Path::file_name - 获取文件名" {
  // 测试文件路径
  let p1 = Path::new("path_test.mbt")
  match p1.file_name() {
    Some(name) => inspect(name, content="path_test.mbt")
    None => fail("Should return file name")
  }
  
  // 测试绝对路径
  let p2 = Path::new("/home/user/document.txt")
  match p2.file_name() {
    Some(name) => inspect(name, content="document.txt")
    None => fail("Should return file name")
  }
  
  // 测试空路径
  let p3 = Path::new("")
  inspect(p3.file_name(), content="None")
  
  // 测试目录路径
  let p4 = Path::new("/home/user/documents")
  match p4.file_name() {
    Some(name) => inspect(name, content="documents")
    None => fail("Should return last component")
  }
}

///|
test "Path::parent - 获取父目录" {
  // 测试绝对路径
  let p1 = Path::new("/home/user/documents/file.txt")
  match p1.parent() {
    Some(parent) => inspect(parent.to_string(), content="/home/user/documents")
    None => fail("Should have parent")
  }
  
  // 测试多级父目录
  let p2 = Path::new("/home/user")
  match p2.parent() {
    Some(parent) => inspect(parent.to_string(), content="/home")
    None => fail("Should have parent")
  }
  
  // 测试根目录
  let p3 = Path::new("/")
  inspect(p3.parent(), content="None")
  
  // 测试相对路径
  let p4 = Path::new("src/lib/utils.mbt")
  match p4.parent() {
    Some(parent) => inspect(parent.to_string(), content="src/lib")
    None => fail("Should have parent")
  }
  
  // 测试单个组件的相对路径
  let p5 = Path::new("file.txt")
  match p5.parent() {
    Some(parent) => inspect(parent.to_string(), content=".")
    None => fail("Should have parent (empty relative path)")
  }
  
  // 测试空路径
  let p6 = Path::new("")
  inspect(p6.parent(), content="None")
}

///|
test "Path::is_dir - 检查是否为目录" {
  // 测试当前目录
  let p1 = Path::new(".")
  inspect(p1.is_dir(), content="true")
  
  // 测试文件
  let p2 = Path::new("path_test.mbt")
  inspect(p2.is_dir(), content="false")
  
  // 测试不存在的路径
  let p3 = Path::new("/nonexistent/path")
  inspect(p3.is_dir(), content="false")
}

///|
test "Path::is_file - 检查是否为文件" {
  // 测试文件
  let p1 = Path::new("path_test.mbt")
  inspect(p1.is_file(), content="true")
  
  // 测试目录
  let p2 = Path::new(".")
  inspect(p2.is_file(), content="false")
  
  // 测试不存在的路径
  let p3 = Path::new("/nonexistent/file.txt")
  inspect(p3.is_file(), content="false")
}

///|
test "Path::is_exists - 检查路径是否存在" {
  // 测试存在的文件
  let p1 = Path::new("path_test.mbt")
  inspect(p1.is_exists(), content="true")
  
  // 测试存在的目录
  let p2 = Path::new(".")
  inspect(p2.is_exists(), content="true")
  
  // 测试不存在的路径
  let p3 = Path::new("/nonexistent/path")
  inspect(p3.is_exists(), content="false")
}

///|
test "边界情况 - extension 和 file_stem" {
  // 测试只有点的文件名
  let p1 = Path::new(".")
  inspect(p1.extension(), content="None")
  inspect(p1.file_stem(), content="None")
  
  // 测试空路径
  let p2 = Path::new("")
  inspect(p2.extension(), content="None")
  inspect(p2.file_stem(), content="None")
}

///|
test "综合测试 - 复杂路径操作" {
  // 创建路径并进行多种操作
  let base = Path::new("/home/user")
  
  // 使用 join 添加路径
  let doc_path = base.join(["documents", "project"])
  inspect(doc_path.to_string(), content="/home/user/documents/project")
  
  // 检查前缀
  let prefix = Path::new("/home/user")
  inspect(doc_path.starts_with(prefix), content="true")
  
  // 检查后缀
  let suffix = Path::new("documents/project")
  inspect(doc_path.ends_with(suffix), content="true")
  
  // 添加文件
  let file_path = doc_path.join(["main.mbt"])
  inspect(file_path.to_string(), content="/home/user/documents/project/main.mbt")
  
  // 替换扩展名
  let rust_file = file_path.with_extension("rs")
  inspect(rust_file.to_string(), content="/home/user/documents/project/main.rs")
  
  // 获取父目录
  match rust_file.parent() {
    Some(parent) => inspect(parent.to_string(), content="/home/user/documents/project")
    None => fail("Should have parent")
  }
}
