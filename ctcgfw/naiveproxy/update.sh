#!/bin/bash

set -e

if [ -z "$GITHUB_TOKEN" ] && [ -f ".git-credentials" ]; then
    GITHUB_TOKEN=$(grep -oP 'https://[^:]+:\K[^@]+' ".git-credentials" | head -n1)
fi

export CURDIR="$(cd "$(dirname "$0")"; pwd)"

# 远程源定义
NAIVEPROXY_API="https://api.github.com/repos/klzgrad/naiveproxy/releases/latest"
BUILD_SH="https://raw.githubusercontent.com/klzgrad/naiveproxy/master/src/build.sh"
CLANG_UPDATE_PY="https://raw.githubusercontent.com/klzgrad/naiveproxy/master/src/tools/clang/scripts/update.py"
LINUX_PGO_TXT="https://raw.githubusercontent.com/klzgrad/naiveproxy/master/src/chrome/build/linux.pgo.txt"
DEPS_FILE="https://raw.githubusercontent.com/klzgrad/naiveproxy/master/src/DEPS"
# 本地路径定义
INIT_ENV_SH="$CURDIR/src/init_env.sh"
# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

trim() {
    local var="$1"
    var="$(echo "$var" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    printf '%s' "$var"
}

# 获取 build.sh 内容
# 全局变量，由 get_build_content 异步填充
BUILD_CONTENT=""

get_build_content() {
    if [ -n "$BUILD_CONTENT" ]; then
        return 0
    fi
    log_info "正在从 GitHub 获取 build.sh ..." >&2
    BUILD_CONTENT="$(curl -sL "$BUILD_SH")"
    if [ -z "$BUILD_CONTENT" ]; then
        log_error "无法获取 build.sh 内容" >&2
        return 1
    fi
}

# 获取 NaiveProxy 最新版本（日志输出到 stderr）
get_naiveproxy_version() {
    log_info "获取 NaiveProxy 最新版本..." >&2
    local tag
    tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$NAIVEPROXY_API" | jq -r ".tag_name")"
    
    if [ -z "$tag" ] || [ "$tag" = "null" ]; then
        log_error "无法获取 NaiveProxy 版本" >&2
        return 1
    fi
    
    local version="${tag#v}"
    log_success "NaiveProxy 版本: $version" >&2
    echo "$version"
}

# 获取源码 SHA256（日志输出到 stderr）
get_source_hash() {
    local version="$1"
    local sha

    version="$(trim "$version")"
    
    if [ -z "$version" ]; then
        log_error "传入 get_source_hash 的版本号为空！" >&2
        return 1
    fi
    
    log_info "正在获取版本 '$version' 的源码 SHA256..." >&2

    sha="$(curl -sL "https://codeload.github.com/klzgrad/naiveproxy/tar.gz/v$version" | sha256sum | awk '{print $1}')"
    
    if [ -z "$sha" ] || [ "$sha" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]; then
        log_error "源码包下载失败或连接超时，获取到的是空哈希！" >&2
        return 1
    fi
    
    log_success "版本 '$version' 的 SHA256 计算完成" >&2
    echo "$sha"
}


# 获取 CLANG 版本（日志输出到 stderr）
get_clang_version() {
    log_info "获取 CLANG 版本信息..." >&2
    local clang_content
    clang_content="$(curl -sL "$CLANG_UPDATE_PY")"
    
    if [ -z "$clang_content" ]; then
        log_error "无法获取 CLANG 版本信息" >&2
        return 1
    fi
    
    local clang_revision
    clang_revision="$(echo "$clang_content" | grep -E "CLANG_REVISION\s*=\s*'[^']+'" | head -1 | sed "s/.*CLANG_REVISION\s*=\s*'\([^']*\)'.*/\1/")"
    
    local clang_sub_revision
    clang_sub_revision="$(echo "$clang_content" | grep -E "CLANG_SUB_REVISION\s*=\s*[0-9]+" | head -1 | sed "s/.*CLANG_SUB_REVISION\s*=\s*\([0-9]*\).*/\1/")"
    
    if [ -z "$clang_revision" ]; then
        log_error "无法提取 CLANG_REVISION" >&2
        return 1
    fi
    
    if [ -z "$clang_sub_revision" ]; then
        clang_sub_revision="0"
    fi
    
    local clang_ver="${clang_revision#llvmorg-}-${clang_sub_revision}"
    
    log_success "CLANG 版本: $clang_ver" >&2
    echo "$clang_ver"
}

# 获取 CLANG HASH（从远程服务器获取）
get_clang_hash() {
    local clang_ver="$1"          # 接收传入的版本号
    local sha
    local clang_version=""        # 使用独立的变量名

    # 使用独立的变量名，避免与参数同名
    clang_version="$(trim "$clang_ver")"
    
    # 调试输出，确认版本号已传入
    log_info "get_clang_hash 接收到的版本号: '$clang_version'" >&2

    if [ -z "$clang_version" ]; then
        log_error "get_clang_hash: clang_ver 为空！" >&2
        return 1
    fi
    
    local clang_url="https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64"
    local clang_file="clang-llvmorg-${clang_version}.tar.xz"
    local full_url="${clang_url}/${clang_file}"
    
    log_info "正在从远程获取 CLANG 文件哈希: ${full_url}" >&2
    
    # 下载文件并实时计算 SHA256
    sha="$(curl -sL "${full_url}" | sha256sum | awk '{print $1}')"
    
    if [ -z "$sha" ]; then
        log_error "获取 CLANG 文件哈希失败，请检查网络或 URL" >&2
        return 1
    fi
    
    log_success "CLANG HASH 获取成功: $sha" >&2
    echo "$sha"
}

# 获取 GN 版本（从 DEPS 文件中提取 gn_version）
get_gn_version() {
    log_info "获取 GN 版本信息..." >&2
    local deps_content
    deps_content="$(curl -sL "$DEPS_FILE")"
    
    if [ -z "$deps_content" ]; then
        log_error "无法获取 DEPS 文件内容" >&2
        return 1
    fi
    
    # 提取 'gn_version': 'git_revision:3357c4f51b1a9e676378c695dd9c7e9911c35ee6'
    local gn_version_line
    gn_version_line="$(echo "$deps_content" | grep -E "'gn_version':\s*'git_revision:[a-f0-9]+'" | head -1)"
    
    if [ -z "$gn_version_line" ]; then
        log_error "无法在 DEPS 文件中找到 gn_version" >&2
        return 1
    fi
    
    # 提取 commit hash (git_revision: 后面的部分)
    local gn_commit
    gn_commit="$(echo "$gn_version_line" | sed "s/.*'gn_version':\s*'git_revision:\([a-f0-9]*\)'.*/\1/")"
    
    if [ -z "$gn_commit" ]; then
        log_error "无法提取 gn_version 的 commit hash" >&2
        return 1
    fi
    
    log_success "GN 版本 (commit): $gn_commit" >&2
    echo "$gn_commit"
}

# 获取 GN 工具的哈希值（下载对应平台的 GN 二进制文件并计算 SHA256）
get_gn_hash() {
    local gn_commit="$1"
    local sha
    local gn_commit_clean=""

    gn_commit_clean="$(trim "$gn_commit")"
    
    log_info "get_gn_hash 接收到的 commit: '$gn_commit_clean'" >&2

    if [ -z "$gn_commit_clean" ]; then
        log_error "get_gn_hash: gn_commit 为空！" >&2
        return 1
    fi

    local gn_url="https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+"
    local gn_file="git_revision:${gn_commit_clean}"
    local full_url="${gn_url}/${gn_file}"

    # 检测当前系统平台
    # local platform=""
    # local gn_url=""
    # case "$(uname -s)" in
    #     Linux*)
    #         platform="linux-amd64"
    #         ;;
    #     Darwin*)
    #         if [ "$(uname -m)" = "arm64" ]; then
    #             platform="mac-arm64"
    #         else
    #             platform="mac-amd64"
    #         fi
    #         ;;
    #     CYGWIN*|MINGW*|MSYS*)
    #         platform="windows-amd64"
    #         ;;
    #     *)
    #         log_error "不支持的平台: $(uname -s)" >&2
    #         return 1
    #         ;;
    # esac
    
    # GN 的 CIPD 下载 URL (使用 chrome-infra-packages 的 API)
    # 注意：这里使用 CIPD 的 API 来获取特定版本的 GN 二进制文件
    # gn_url="https://chrome-infra-packages.appspot.com/dl/gn/gn/${platform}/+/git_revision:${gn_commit_clean}"
    
    # log_info "正在从远程获取 GN 工具 (${platform}) 的哈希..." >&2
    log_info "正在从远程获取 GN 工具哈希: ${full_url}" >&2
    
    # 下载并计算 SHA256
    sha="$(curl -sL "${full_url}" | sha256sum | awk '{print $1}')"
    
    if [ -z "$sha" ]; then
        log_error "获取 GN 工具哈希失败，请检查网络或 URL" >&2
        return 1
    fi
    
    log_success "GN HASH 获取成功: $sha" >&2
    echo "$sha"
}

# 获取 PGO 版本
get_pgo_version() {
    log_info "获取 PGO 版本信息..." >&2
    local pgo_content
    pgo_content="$(curl -sL "$LINUX_PGO_TXT")"
    
    if [ -z "$pgo_content" ]; then
        log_error "无法获取 PGO 版本信息" >&2
        return 1
    fi
    
    # 从文件名中提取 PGO_VER
    # 格式: chrome-linux-{PGO_VER}.profdata
    local pgo_version
    pgo_version="$(echo "$pgo_content" | grep -o 'chrome-linux-[0-9]\+-[0-9]\+-[a-f0-9]\+-[a-f0-9]\+\.profdata' | sed 's/chrome-linux-\(.*\)\.profdata/\1/')"
    
    if [ -z "$pgo_version" ]; then
        log_error "无法提取 PGO_VER" >&2
        return 1
    fi
    
    log_success "PGO 版本: $pgo_version" >&2
    echo "$pgo_version"
}

# 获取 PGO HASH（从远程服务器获取）
get_pgo_hash() {
    local pgo_ver="$1"          # 接收传入的版本号
    local sha
    local pgo_version=""        # 使用独立的变量名

    # 使用独立的变量名，避免与参数同名
    pgo_version="$(trim "$pgo_ver")"
    
    # 调试输出，确认版本号已传入
    log_info "get_pgo_hash 接收到的版本号: '$pgo_version'" >&2

    if [ -z "$pgo_version" ]; then
        log_error "get_pgo_hash: PGO_VER 为空！" >&2
        return 1
    fi
    
    local pgo_url="https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles"
    local pgo_file="chrome-linux-${pgo_version}.profdata"
    local full_url="${pgo_url}/${pgo_file}"
    
    log_info "正在从远程获取 PGO 文件哈希: ${full_url}" >&2
    
    # 下载文件并实时计算 SHA256
    sha="$(curl -sL "${full_url}" | sha256sum | awk '{print $1}')"
    
    if [ -z "$sha" ]; then
        log_error "获取 PGO 文件哈希失败，请检查网络或 URL" >&2
        return 1
    fi
    
    log_success "PGO HASH 获取成功: $sha" >&2
    echo "$sha"
}

# 更新 Makefile
update_makefile() {
    local version="$1"
    local sha="$2"
    local clang_ver="$3"
    local clang_hash="$4"
    local gn_commit="$5"
    local gn_hash="$6"
    local pgo_ver="$7"
    local pgo_hash="$8"
    local line
    
    log_info "更新 Makefile..."
    
    # 更新 PKG_REAL_VERSION
    line="$(awk "/PKG_REAL_VERSION:=/ {print NR}" "$CURDIR/Makefile")"
    sed -i "$((line))s|PKG_REAL_VERSION:=.*|PKG_REAL_VERSION:=$version|" "$CURDIR/Makefile"
    log_success "PKG_REAL_VERSION 已更新为 $version"

    # 更新 PKG_HASH
    line="$(awk "/PKG_HASH:=/ {print NR}" "$CURDIR/Makefile")"
    sed -i "$((line))s|PKG_HASH:=.*|PKG_HASH:=$sha|" "$CURDIR/Makefile"
    log_success "PKG_HASH 已更新为 $sha"

    # 更新 CLANG_VER
    if [ -n "$clang_ver" ]; then
        line="$(awk "/CLANG_VER:=/ {print NR}" "$CURDIR/Makefile")"
        sed -i "$((line))s/CLANG_VER:=.*/CLANG_VER:=$clang_ver/" "$CURDIR/Makefile"
        log_success "CLANG_VER 已更新为 $clang_ver"
    fi

    # 更新 CLANG-LLVMORG 的 HASH
    if [ -n "$clang_hash" ]; then
        local hash_line
        hash_line="$(awk "/^[[:space:]]*FILE:=\\\$\\(CLANG_FILE\\)/ {print NR}" "$CURDIR/Makefile")"
        if [ -n "$hash_line" ]; then
            sed -i "$((hash_line + 1))s/HASH:=.*/HASH:=$clang_hash/" "$CURDIR/Makefile"
            log_success "CLANG_HASH  已更新为 $clang_hash"
        fi
    fi

    # 更新 GN_VER (如果 Makefile 中有定义)
    if [ -n "$gn_commit" ]; then
        # 检查 Makefile 中是否有 GN_VER 定义
        if grep -q "^GN_VER:=" "$CURDIR/Makefile"; then
            line="$(awk "/GN_VER:=/ {print NR}" "$CURDIR/Makefile")"
            sed -i "$((line))s/GN_VER:=.*/GN_VER:=$gn_commit/" "$CURDIR/Makefile"
            log_success "GN_VER 已更新为 $gn_commit"
        else
            log_warning "Makefile 中没有 GN_VER 定义，跳过"
        fi
    fi

    # 更新 GN 的 HASH (如果 Makefile 中有定义)
    if [ -n "$gn_hash" ]; then
        local hash_line
        hash_line="$(awk "/^[[:space:]]*FILE:=\\\$\\(GN_FILE\\)/ {print NR}" "$CURDIR/Makefile")"
        if [ -n "$hash_line" ]; then
            sed -i "$((hash_line + 1))s/HASH:=.*/HASH:=$gn_hash/" "$CURDIR/Makefile"
            log_success "GN_HASH 已更新为 $gn_hash"
        fi
    fi

    # 更新 PGO_VER
    if [ -n "$pgo_ver" ]; then
        line="$(awk "/PGO_VER:=/ {print NR}" "$CURDIR/Makefile")"
        sed -i "$((line))s/PGO_VER:=.*/PGO_VER:=$pgo_ver/" "$CURDIR/Makefile"
        log_success "PGO_VER 已更新为 $pgo_ver"
    fi
    
    # 更新 PGO_PROF 的 HASH
    if [ -n "$pgo_hash" ]; then
        local hash_line
        hash_line="$(awk "/^[[:space:]]*FILE:=\\\$\\(PGO_FILE\\)/ {print NR}" "$CURDIR/Makefile")"
        if [ -n "$hash_line" ]; then
            sed -i "$((hash_line + 1))s/HASH:=.*/HASH:=$pgo_hash/" "$CURDIR/Makefile"
            log_success "PGO_HASH 已更新为 $pgo_hash"
        fi
    fi
    
    log_success "Makefile 更新完成"
}

# 清理旧文件
clean_old_files() {
    local old_version="$1"
    local pkg_name="naiveproxy"

    # 清理指定包的编译缓存
    log_info "清理包的编译缓存..."
    if [ -n "$pkg_name" ]; then
        make package/${pkg_name}/clean V=s 2>/dev/null || log_warning "无法执行 make clean，跳过"
    fi

    log_info "清理旧文件..."
    
    # 清理 dl 目录
    if [ -d "dl" ]; then
        rm -f "dl/${pkg_name}-${old_version}.tar.gz" 2>/dev/null
        rm -f "dl/clang-llvmorg-*.tar.xz" 2>/dev/null
        rm -f "dl/chrome-linux-*.profdata" 2>/dev/null
        log_success "已清理 dl 目录"
    fi
}

extract_release_flags() {
    # 使用 awk 处理：当检测到 out=out/Release 开启 release 状态，
    # 遇到 flags=" 开启提取，直到遇到不带反斜杠结束的引号或匹配块结束。
    get_build_content
    echo "$BUILD_CONTENT" | awk '
    /out=out\/Release/ { in_release=1; next }
    /out=out\/Debug/   { in_release=0; next }  # 防止进入别的配置块
    in_release && /flags="/ {
        in_flags=1
        # 去掉行首的 flags="
        sub(/^[[:space:]]*flags="/, "")
        # 【核心修复】清洗掉可能存在的末尾反斜杠和空格
        sub(/\\$/, "")
        sub(/^[[:space:]]*$/, "")
        # 如果去掉 flags=" 之后这一行已经空了（说明真实数据在下一行开始），
        # 则直接跳到下一行，防止输出第一行为空行
        if ($0 == "") {
            next
        }
    }
    in_flags {
        # 去掉末尾的换行反斜杠
        sub(/\\$/, "")
        # 去掉多余的行首空格
        sub(/^[[:space:]]*/, "")
        # 检查是否到了本块的末尾引号
        if (/"$/ || /^"$/) {
            sub(/"$/, "")
            # 只有当内容非空时才打印，避免末尾也带出多余空行
            if ($0 != "") print $0
            in_flags=0
            in_release=0 # 提取完直接退出
            exit
        }
        print $0
    }'
}
# 提取 flags="$flags"' 后面的额外 flags
extract_extra_flags() {
    # 匹配 flags="$flags"'\'' 或类似特征开始，直到遇到单引号 '\'' 结束
    get_build_content
    echo "$BUILD_CONTENT" | awk '
    /flags="\$flags"'\''/ { in_extra=1; next }
    in_extra {
        # 如果遇到单独的单引号（可能带反斜杠换行），或者以单引号结束
        if (/^\x27$/ || /\x27$/ || /^\\\x27$/) {
            in_extra=0
            exit
        }
        # 去掉末尾的反斜杠
        sub(/\\$/, "")
        # 先清洗干净纯空格行，使其成为纯净的空行
        sub(/^[[:space:]]*$/, "")
        # 如果不是空行，才去掉行首空格
        if ($0 != "") {
            sub(/^[[:space:]]*/, "")
        }
        print $0
    }'
}

# 合并函数

# 合并两个 flags 输出，去重、过滤不需要的行
merge_flags() {
    local release_flags
    local extra_flags
    local merged_flags

    release_flags="$(extract_release_flags)"
    extra_flags="$(extract_extra_flags)"

    # 【修改处】合并两部分：如果在 release_flags 后面有 extra_flags，则在中间多插入一行空行
    if [ -n "$release_flags" ] && [ -n "$extra_flags" ]; then
        merged_flags="$(printf "%s\n\n%s" "$release_flags" "$extra_flags")"
    else
        merged_flags="$release_flags$extra_flags"
    fi

    # 去重（如果是空行，即字段数 NF==0，直接打印不加入去重；非空行才去重）
    # merged_flags="$(echo "$merged_flags" | awk 'NF==0 {print; next} !seen[$0]++')"
    
    # 过滤不需要的行（使用 || true 防止 grep 找不到目标时导致 set -e 退出脚本）
    merged_flags="$(echo "$merged_flags" | grep -v 'cc_wrapper' || true)"
    merged_flags="$(echo "$merged_flags" | grep -v 'target_sysroot' || true)"

    echo "$merged_flags"
}

# 从 init_env.sh 提取 flags

extract_naive_flags() {
    # 使用 awk 读取文件
    awk '
    # 1. 匹配到 export naive_flags=" 标志，开启提取状态
    /^[[:space:]]*export[[:space:]]+naive_flags="/ { 
        in_flags=1; 
        next 
    }
    # 2. 在提取状态中
    in_flags {
        # 如果遇到了 target_os，按照原脚本逻辑直接退出
        if ($0 ~ /target_os=/) {
            exit
        }
        # 清除每行末尾用来连接换行的反斜杠 \
        sub(/\\$/, "")
        # 清除行首和行尾的空白字符
        sub(/^[[:space:]]*$/, "") # 如果是纯空格行，清洗干净变成空行
        sub(/^[[:space:]]*/, "")
        sub(/[[:space:]]*$/, "")
        # 【核心修改处】
        # 只要符合变量名开头且带等号，就进行清洗并打印
        if ($0 ~ /^[a-zA-Z0-9_]+=/) {
            # 顺便清洗掉两端以及内部可能存在的转义引号 \" 还原为纯净的 true/false/数值
            gsub(/\\"/, "")
            sub(/^"/, "")
            sub(/"$/, "")
            print $0
        } else if ($0 == "") {
            # 如果是空行，原样保留输出
            print ""
        }
    }
    ' "$INIT_ENV_SH"
}

# 比较函数
sync_naive_flags() {
    local build_flags
    local init_flags

    log_info "从 build.sh 提取 flags..."
    build_flags="$(merge_flags)"
    if [ -z "$build_flags" ]; then
        log_error "提取 build.sh flags 失败"
        return 1
    fi
    build_flags="$build_flags"$'\n'
    local build_count="$(echo "$build_flags" | wc -l | tr -d ' ')"
    log_info "build.sh flags: $build_count 行"
    
    log_info "从 init_env.sh 提取 flags..."
    init_flags="$(extract_naive_flags)"
    # echo "$init_flags" > "$CURDIR/debug_flags.txt"
    if [ -z "$init_flags" ]; then
        log_error "提取 init_env.sh flags 失败，终止 flags 同步"
        return 1
    fi
    init_flags="$init_flags"$'\n'
    local init_count="$(echo "$init_flags" | wc -l | tr -d ' ')"
    log_info "init_env.sh flags: $init_count 行"
    
    # 排序后比较
    local build_sorted="$(echo "$build_flags" | sort)"
    local init_sorted="$(echo "$init_flags" | sort)"
    
    if [ "$build_sorted" = "$init_sorted" ]; then
        log_success "flags 完全一致，无需更新 init_env.sh"
        return 0
    fi

    log_warning "flags 不一致，正在更新 init_env.sh..."

    # 显示差异
    echo ""
    echo "=== 需要添加的 flags (build.sh 有，init_env.sh 没有) ==="
    local to_add="$(comm -23 <(echo "$build_sorted") <(echo "$init_sorted"))"
    if [ -n "$to_add" ]; then
        echo "$to_add"
    else
        echo "(无)"
    fi
    echo ""
    echo "=== 需要删除的 flags (init_env.sh 有，build.sh 没有) ==="
    local to_remove="$(comm -13 <(echo "$build_sorted") <(echo "$init_sorted"))"
    if [ -n "$to_remove" ]; then
        echo "$to_remove"
    else
        echo "(无)"
    fi
    echo ""

# ==================== 精准按行增删逻辑 ====================
#     # 更新 init_env.sh
#     local init_content
#     init_content="$(cat "$INIT_ENV_SH")"
# 
#     local new_content=""
#     local in_flags=0
#     local flags_replaced=0
# 
#     while IFS= read -r line || [ -n "$line" ]; do
#         # 1. 匹配到区域开始
#         if echo "$line" | grep -q '^[[:space:]]*export[[:space:]]\+naive_flags="'; then
#             new_content="$new_content$line"$'\n'
#             in_flags=1
#             continue
#         fi
# 
#         # 2. 局部精准增删核心
#         if [ $in_flags -eq 1 ]; then
#             # 如果遇到了结束标志 target_os
#             if echo "$line" | grep -q -E 'target_os=\\?"openwrt\\?"'; then
#                 # 【添加缺少的】在结束前，把需要补齐的 flags 按行写入
#                 if [ -n "$to_add" ]; then
#                     while IFS= read -r add_line; do
#                         [ -z "$add_line" ] && continue
#                         new_content="$new_content$add_line"$'\n'
#                     done <<< "$to_add"
#                 fi
#                 
#                 # 保持原样多一行空行的要求，并在最后放入 target_os 结束块
#                 new_content="$new_content"$'\n'
#                 new_content="$new_content$line"$'\n'
#                 in_flags=0
#                 flags_replaced=1
#                 continue
#             fi
# 
#             # 【删除多余的】检查当前行是不是属于需要被剔除的行
#             if [ -n "$to_remove" ] && echo "$to_remove" | grep -Fq -x "$line"; then
#                 # 匹配到了需要删除的行，直接 continue 跳过（不写入 new_content）
#                 continue
#             fi
#             
#             # 既不是结束符，又不需要被删除的行，原样保留
#             new_content="$new_content$line"$'\n'
#             continue
#         fi
# 
#         # 3. 区域外部内容，原样保留
#         new_content="$new_content$line"$'\n'
#     done <<< "$init_content"

    # 更新 init_env.sh
    local init_content
    init_content="$(cat "$INIT_ENV_SH")"

    local new_content=""
    local in_flags=0
    local flags_replaced=0

    while IFS= read -r line; do
        if echo "$line" | grep -q '^[[:space:]]*export[[:space:]]\+naive_flags="'; then
            new_content="$new_content$line"$'\n'
            in_flags=1
            continue
        fi

        if [ $in_flags -eq 1 ]; then
            # 兼容 target_os="openwrt" 和 target_os=\"openwrt\"
            if echo "$line" | grep -q -E 'target_os=\\?"openwrt\\?"'; then
                new_content="$new_content$build_flags"
                new_content="$new_content"$'\n'
                new_content="$new_content$line"$'\n'
                in_flags=0
                flags_replaced=1
                continue
            fi
            continue
        fi
        new_content="$new_content$line"$'\n'
    done <<< "$init_content"

    if [ $flags_replaced -eq 0 ]; then
        log_error "无法在 init_env.sh 中找到 target_os 行"
        return 1
    fi

    echo "$new_content" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' > "$INIT_ENV_SH"

    log_success "init_env.sh 编译 flags 同步完成！"
    return 0
}

# 主函数中的调用
main() {
    echo "=========================================="
    echo "  NaiveProxy 核心固件工具自动更新系统"
    echo "=========================================="

    local current_version latest_version sha clang_ver clang_hash gn_commit gn_hash pgo_ver pgo_hash
    
    # 1. 获取当前 NaiveProxy 版本
    local current_version
    current_version="$(awk -F "PKG_REAL_VERSION:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
    current_version="$(trim "$current_version")"
    log_info "本地当前版本: $current_version"
    
    # 2. 获取 NaiveProxy 最新版本
    local latest_version
    latest_version="$(get_naiveproxy_version)" || return 1
    latest_version="$(trim "$latest_version")"
    log_info "上游最新版本: $latest_version"
    
    # 3. 检查是否需要更新 NaiveProxy
    local need_update=0
    if [ "$latest_version" != "$current_version" ]; then
        need_update=1
    fi

    # 4. 如果 NaiveProxy 需要更新，获取源码 SHA256
    if [ $need_update -eq 1 ]; then
        local sha
        sha="$(get_source_hash "$latest_version")" || return 1
        sha="$(trim "$sha")"
        log_info "源码 SHA256: $sha"
    fi

    # 5. 获取 CLANG 版本并比较
    local clang_ver
    clang_ver="$(get_clang_version)" || return 1
    clang_ver="$(trim "$clang_ver")"
    log_info "CLANG 版本: $clang_ver"
    
    local clang_hash=""
    local current_clang_version
    current_clang_version="$(awk -F "CLANG_VER:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
    current_clang_version="$(trim "$current_clang_version")"
    log_info "本地 CLANG 版本: $current_clang_version"
    
    if [ "$clang_ver" != "$current_clang_version" ]; then
        clang_hash="$(get_clang_hash "$clang_ver")" || return 1
        clang_hash="$(trim "$clang_hash")"
        log_info "CLANG HASH: $clang_hash"
    fi

    # 6. 获取 GN 版本并比较
    local gn_commit
    gn_commit="$(get_gn_version)" || return 1
    gn_commit="$(trim "$gn_commit")"
    log_info "GN 版本 (commit): $gn_commit"
    
    local gn_hash=""
    local current_gn_version
    current_gn_version="$(awk -F "GN_VER:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
    current_gn_version="$(trim "$current_gn_version")"
    log_info "本地 GN 版本: $current_gn_version"
    
    if [ "$gn_commit" != "$current_gn_version" ]; then
        gn_hash="$(get_gn_hash "$gn_commit")" || return 1
        gn_hash="$(trim "$gn_hash")"
        log_info "GN HASH: $gn_hash"
    fi

    # 7. 获取 PGO 版本并比较
    local pgo_ver
    pgo_ver="$(get_pgo_version)" || return 1
    pgo_ver="$(trim "$pgo_ver")"
    log_info "PGO 版本: $pgo_ver"
    
    local pgo_hash=""
    local current_pgo_version
    current_pgo_version="$(awk -F "PGO_VER:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
    current_pgo_version="$(trim "$current_pgo_version")"
    log_info "本地 PGO 版本: $current_pgo_version"
    
    if [ "$pgo_ver" != "$current_pgo_version" ]; then
        pgo_hash="$(get_pgo_hash "$pgo_ver")" || return 1
        pgo_hash="$(trim "$pgo_hash")"
        log_info "PGO HASH: $pgo_hash"
    fi

    # 8. 如果没有任何更新，只同步 flags
    if [ $need_update -eq 0 ] && [ -z "$clang_hash" ] && [ -z "$gn_hash" ] && [ -z "$pgo_hash" ]; then
        log_success "所有组件已是最新版本"
        sync_naive_flags
        return 0
    fi

    # 9. 清理旧文件（只在有更新时执行）
    if [ $need_update -eq 1 ]; then
        clean_old_files "$current_version"
    fi
    
    # 10. 更新 Makefile
    update_makefile "$latest_version" "$sha" "$clang_ver" "$clang_hash" "$gn_commit" "$gn_hash" "$pgo_ver" "$pgo_hash"

    # 11. 更新 init_env.sh
    sync_naive_flags
    
    echo "=========================================="
    log_success "所有组件和编译 flags 完整更新完毕！"
    log_info "  旧版本: $current_version"
    log_info "  新版本: $latest_version"
    log_info "  SHA256: $sha"
    log_info "  CLANG: $clang_ver"
    log_info "  CLANG HASH: $clang_hash"
    log_info "  GN Commit: $gn_commit"
    log_info "  GN HASH: $gn_hash"
    log_info "  PGO: $pgo_ver"
    log_info "  PGO HASH: $pgo_hash"
    echo "=========================================="
}

# 执行主函数
main "$@"
