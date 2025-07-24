#!/usr/bin/zsh
_complete_option_flag() {
    local already_typed="$1"
    local options="$2"
    local value="${already_typed##*=}"
    local flag="${already_typed%%=*}="
    COMPREPLY=("${(@f)$(compgen -P "${flag}" -W "${options}" -- "${value}")}")
}

_complete_options() {
    local already_typed="$1"
    local options="$2"
    COMPREPLY=("${(@f)$(compgen -W "${options}" -- "${already_typed}")}")
}

_c3c() {
    local commands=(
        "compile"
        "init"
        "init-lib"
        "build"
        "benchmark"
        "test"
        "clean"
        "run"
        "dist"
        "clean-run"
        "compile-run"
        "compile-only"
        "compile-benchmark"
        "compile-test"
        "static-lib"
        "dynamic-lib"
        "vendor-fetch"
        "project"
    )
    local options=(
        "-h" "-hh" "--help" "-V" "--version" "-q" "--quiet" "-v" "-vv" "-vvv" "-E" "-P" "-C" "-"
        "-o" "-O0" "-O1" "-O2" "-O3" "-O4" "-O5" "-Os" "-Oz" "-D" "-U" "--about" "--build-env"
        "--run-dir" "--libdir" "--lib" "--sources" "--validation=" "--stdlib" "--no-entry" "--path"
        "--template" "--symtab" "--run-once" "--suppress-run" "--trust=" "--output-dir" "--build-dir"
        "--obj-out" "--script-dir" "--llvm-out" "--asm-out" "--header-output" "--emit-llvm" "--emit-asm"
        "--obj" "--no-obj" "--no-headers" "--target" "--threads" "--safe=" "--panic-msg=" "--optlevel="
        "--optsize=" "--single-module=" "--show-backtrace=" "--lsp" "--use-old-slice-copy" "-g" "-g0"
        "--ansi=" "--test-filter" "--test-breakpoint" "--test-nosort" "--test-noleak" "--test-nocapture"
        "--test-quiet" "-l" "-L" "-z" "--cc" "--linker=" "--use-stdlib=" "--link-libc=" "--emit-stdlib="
        "--panicfn" "--testfn" "--benchfn" "--reloc=" "--x86cpu=" "--x86vec=" "--riscvfloat="
        "--memory-env=" "--strip-unused=" "--fp-math=" "--win64-simd=" "--win-debug=" "--max-vector-size"
        "--print-linking" "--benchmarking" "--testing" "--list-attributes" "--list-builtins"
        "--list-keywords" "--list-operators" "--list-precedence" "--list-project-properties"
        "--list-manifest-properties" "--list-targets" "--list-type-properties" "--print-output"
        "--print-input" "--winsdk" "--wincrt=" "--windef" "--win-vs-dirs" "--macossdk"
        "--macos-min-version" "--macos-sdk-version" "--linux-crt" "--linux-crtbegin" "--android-ndk"
        "--android-api" "--sanitize="
    )

    local project_view_filters=(
        "-h" "--help" "-v" "-vv" "--authors" "--version" "--language-revision" "--warnings-used"
        "--c3l-lib-search-paths" "--c3l-lib-dependencies" "--source-paths" "--output-location"
        "--default-optimization" "--targets"
    )

    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in
        c3c)
            if [[ "${cur}" == -* ]]; then
                _complete_options "${cur}" "${options[*]}"
            else
                _complete_options "${cur}" "${commands[*]} -"
            fi
            return
            ;;
        project)
            _complete_options "${cur}" "view add-target fetch"
            return
            ;;
        build|run|dist|directives|bench|clean-run)
            local project_targets=$(c3c project view --targets 2>/dev/null)
            _complete_options "${cur}" "${project_targets}"
            return
            ;;
        view)
            _complete_options "${cur}" "${project_view_filters[*]}"
            return
            ;;
        --template) # TODO: this only possible after `init`
            _complete_options "${cur}" "exe static-lib dynamic-lib"
            COMPREPLY+=(${(f)"$(compgen -o default -- "${cur}")"})
            return
            ;;
        --target)
            local available_targets=$(
                c3c --list-targets 2>/dev/null \
                | tail -n +2 \
                | sed "s/^ *\([^ ]*\) *$/\1/" \
                | tr '\n' ' '
            )
            _complete_options "${cur}" "${available_targets}"
            return
            ;;
        *)
            if [[ "${cur}" == -* ]]; then
                _complete_options "${cur}" "${options[*]}"
            fi
            ;;
    esac

    local opts=()
    case "${cur}" in
        --validation=*) opts=( "lenient" "strict" "obnoxious" ) ;;
        --trust=*) opts=( "none" "include" "full" ) ;;
        --optlevel=*) opts=( "none" "less" "more" "max" ) ;;
        --optsize=*) opts=( "none" "small" "tiny" ) ;;
        --linker=*) opts=( "builtin" "cc" "custom" ) ;;
        --reloc=*) opts=( "none" "pic" "PIC" "pie" "PIE" ) ;;
        --x86cpu=*) opts=( "baseline" "ssse6" "sse4" "avx1" "avx2-v1" "avx2-v2" "avx512" "native" ) ;;
        --x86vec=*) opts=( "none" "mmx" "sse" "avx" "avx512" "default" ) ;;
        --riscvfloat=*) opts=( "none" "float" "double" ) ;;
        --memory-env=*) opts=( "normal" "small" "tiny" "none" ) ;;
        --fp-math=*) opts=( "strict" "relaxed" "fast" ) ;;
        --win64-simd=*) opts=( "array" "full" ) ;;
        --win-debug=*) opts=( "codeview" "dwarf" ) ;;
        --wincrt=*) opts=( "none" "static-debug" "static" "dynamic-debug" "dynamic" ) ;;
        --sanitize=*) opts=( "address" "memory" "thread" ) ;;
        --safe=*|--panic-msg=*|--single-module=*|--show-backtrace=*|--ansi=*|--use-stdlib=*|--link-libc=*|--emit-stdlib=*|--strip-unused=*)
            opts=( "yes" "no" )
            ;;
    esac
    if (( ${#opts[@]} >= 1 )); then
        _complete_option_flag "${cur}" "${opts[*]}"
    fi

    if [[ "${#COMPREPLY[@]}" -eq 1 && "${COMPREPLY[0]}" == *= ]]; then
        compopt -o nospace 2>/dev/null || :
    fi
}

autoload -U +X bashcompinit && bashcompinit
complete -o default -F _c3c c3c
