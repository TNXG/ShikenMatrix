#!/bin/bash
# 只构建 Rust 库的脚本

# 不要在错误时退出，让脚本继续运行
set +e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUST_LIB_DIR="$SCRIPT_DIR/rust-lib"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  构建 Rust 库${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$PROJECT_ROOT"

# 检查是否传入 --debug 参数
BUILD_MODE="release"
if [ "$1" = "--debug" ]; then
    BUILD_MODE="debug"
    TARGET_DIR="target/debug"
    echo -e "${YELLOW}使用 Debug 模式构建${NC}"
else
    TARGET_DIR="target/release"
    echo -e "${YELLOW}使用 Release 模式构建（启用优化）${NC}"
fi
echo ""

# 构建 Rust 库
echo "编译 Rust 库..."
if [ "$BUILD_MODE" = "release" ]; then
    cargo build --release
else
    cargo build
fi

# 检查构建是否成功
if [ ! -f "$TARGET_DIR/libshikenmatrix.dylib" ]; then
    echo -e "${RED}❌ 构建失败${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Rust 库编译成功${NC}"
echo ""

# 生成 C 头文件
echo "生成 C 头文件..."
cbindgen --config cbindgen.toml --crate shikenmatrix --output shikenmatrix.h
echo -e "${GREEN}✓ 生成 shikenmatrix.h${NC}"
echo ""

# 复制文件
echo "复制库文件到 macOS UI 项目..."
mkdir -p "$RUST_LIB_DIR"

cp "$PROJECT_ROOT/$TARGET_DIR/libshikenmatrix.dylib" "$RUST_LIB_DIR/"
if [ -f "$PROJECT_ROOT/shikenmatrix.h" ]; then
    cp "$PROJECT_ROOT/shikenmatrix.h" "$RUST_LIB_DIR/"
fi

# 修复库的安装路径
echo "修复库的安装路径..."
install_name_tool -id "@rpath/libshikenmatrix.dylib" "$RUST_LIB_DIR/libshikenmatrix.dylib"

# Release 模式下优化文件大小
if [ "$BUILD_MODE" = "release" ]; then
    echo "优化库文件大小..."
    strip -x "$RUST_LIB_DIR/libshikenmatrix.dylib"
fi

# 重新签名（使用开发者证书或 ad-hoc 签名）
echo "重新签名库文件..."
# 先尝试使用特定的开发者证书，如果失败则使用 ad-hoc 签名（开发模式）
if codesign --force --sign "LG25FB2235" "$RUST_LIB_DIR/libshikenmatrix.dylib" 2>/dev/null; then
    echo -e "${GREEN}✓ 使用 Team ID LG25FB2235 签名${NC}"
elif codesign --force --sign "Apple Development: tianxiang_tnxg@outlook.com" "$RUST_LIB_DIR/libshikenmatrix.dylib" 2>/dev/null; then
    echo -e "${GREEN}✓ 使用 Apple Development 证书签名${NC}"
else
    # 使用 ad-hoc 签名（开发环境，无需证书）
    echo -e "${YELLOW}使用 ad-hoc 签名（开发模式）${NC}"
    codesign --force --sign - "$RUST_LIB_DIR/libshikenmatrix.dylib"
fi

echo -e "${GREEN}✓ 文件复制完成${NC}"
echo ""

# 显示文件信息
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ 构建完成！${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "库文件位置:"
echo -e "  ${BLUE}$RUST_LIB_DIR/libshikenmatrix.dylib${NC}"
if [ -f "$RUST_LIB_DIR/shikenmatrix.h" ]; then
    echo -e "  ${BLUE}$RUST_LIB_DIR/shikenmatrix.h${NC}"
fi
echo ""
echo "库文件大小:"
ls -lh "$RUST_LIB_DIR/libshikenmatrix.dylib" | awk '{print "  " $5}'
echo ""
echo "下一步: 在 Xcode 中 Clean Build Folder (Cmd+Shift+K)，然后 Run (Cmd+R)"
echo ""
