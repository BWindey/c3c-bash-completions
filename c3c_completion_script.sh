function _complete_option_flag() {
	already_typed="$1"
	options="$2"
	value="${already_typed##*=}"
	flag="${already_typed%%=*}="
	mapfile -t COMPREPLY < <(compgen -P "${flag}" -W "${options}" -- "${value}")
}

function _complete_options() {
	already_typed="$1"
	options="$2"
	mapfile -t COMPREPLY < <(compgen -W "${options}" -- "${already_typed}")
}

function _add_default_completions() {
	mapfile -t _DEFAULTS < <(compgen -o default -- "${cur}")
	# Filter empty otherwise there would be empty thing to complete and that
	# prevents actual completion
	if [[ "${_DEFAULTS[*]}" != "" ]]; then
		COMPREPLY+=("${_DEFAULTS[@]}")
	fi
}

function _c3c_complete() {
	commands=(
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
		"fetch-sdk"
		"docgen"
	)
	options=(
		"-h"
		"-hh"
		"--help"
		"-V"
		"--version"
		"-q"
		"--quiet"
		"-v"
		"-vv"
		"-vvv"
		"-E"
		"-P"
		"-C"
		"-"
		"-o"
		"-O0"
		"-O1"
		"-O2"
		"-O3"
		"-O4"
		"-O5"
		"-Os"
		"-Oz"
		"-D"
		"-U"
		"--about"
		"--build-env"
		"--run-dir"
		"--libdir"
		"--lib"
		"--sources"
		"--validation="
		"--stdlib"
		"--no-entry"
		"--path"
		"--template"
		"--symtab"
		"--max-mem"
		"--run-once"
		"--suppress-run"
		"--trust="
		"--output-dir"
		"--build-dir"
		"--obj-out"
		"--script-dir"
		"--exec-dir"
		"--llvm-out"
		"--asm-out"
		"--header-output"
		"--emit-llvm"
		"--emit-asm"
		"--obj"
		"--no-obj"
		"--no-headers"
		"--target"
		"--threads"
		"--safe="
		"--panic-msg="
		"--optlevel="
		"--optsize="
		"--unroll-loops="
		"--loop-vectorize="
		"--slp-vectorize="
		"--merge-functions="
		"--single-module="
		"--show-backtrace="
		"--lsp"
		"--print-large-functions="
		"--warn-deadcode="
		"--warn-methodvisibility="
		"--warn-methodsnotresolved="
		"--warn-deprecation="
		"--warn-builtin="
		"-g"
		"-g0"
		"--ansi="
		"--echo-prefix"
		"--test-filter"
		"--test-breakpoint"
		"--test-nosort"
		"--test-noleak"
		"--test-nocapture"
		"--test-quiet"
		"--test-log-level="
		"--benchmark-csv-report"
		"-l"
		"-L"
		"-z"
		"--cc"
		"--linker="
		"--use-stdlib="
		"--link-libc="
		"--emit-stdlib="
		"--emit-only"
		"--panicfn"
		"--testfn"
		"--benchfn"
		"--reloc="
		"--cpu-flags"
		"--x86cpu="
		"--x86vec="
		"--riscv-abi="
		"--riscv-cpu="
		"--memory-env="
		"--strip-unused="
		"--fp-math="
		"--win64-simd="
		"--win-debug="
		"--max-vector-size"
		"--max-stack-object-size"
		"--max-macro-iterations"
		"--print-linking"
		"--benchmarking"
		"--testing"
		"--list-attributes"
		"--list-builtins"
		"--list-keywords"
		"--list-operators"
		"--list-precedence"
		"--list-project-properties"
		"--list-manifest-properties"
		"--list-targets"
		"--list-type-properties"
		"--list-asm"
		"--print-output"
		"--print-input"
		"--win-sdk"
		"--wincrt="
		"--windef"
		"--win-vs-dirs"
		"--win-subsystem="
		"--macossdk"
		"--macos-min-version"
		"--macos-sdk-version"
		"--linux-libc="
		"--linux-crt"
		"--linux-crtbegin"
		"--android-ndk"
		"--android-api"
		"--bsd-sysroot"
		"--sanitize="
	)

	project_view_filters=(
		"-h"
		"--help"
		"-v"
		"-vv"
		"--authors"
		"--version"
		"--language-revision"
		"--warnings-used"
		"--c3l-lib-search-paths"
		"--c3l-lib-dependencies"
		"--source-paths"
		"--output-location"
		"--default-optimization"
		"--targets"
	)

	local cur prev
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	# Check first if we can complete 'fetch-sdk' subcommand
	if [[ "${COMP_WORDS[*]}" == *fetch-sdk* ]]; then
		case "${prev}" in
			windows)
				fetch_win_flags=(
					"--accept-license"
					"--show-versions"
					"--msvc-version"
					"--sdk-version"
					"--arch"
				)
				_complete_options "${cur}" "${fetch_win_flags[*]}"
				return
				;;
			macos)
				fetch_mac_flags=(
					"--accept-license"
					"--list"
					"--sdk-version"
				)
				_complete_options "${cur}" "${fetch_mac_flags[*]}"
				return
				;;
			android)
				_complete_options "${cur}" "--accept-license"
				return
				;;
			--arch)
				_complete_options "${cur}" "x64 arm64"
				return
				;;
		esac
	fi

	# Now general completion
	case "${prev}" in
		# Main command
		c3c)
			if [[ "${cur}" == -* ]]; then
				_complete_options "${cur}" "${options[*]}"
			else
				_complete_options "${cur}" "${commands[*]} -..."
			fi
			;;
		build|run|dist|directives|bench|clean-run)
			if [[ "${cur}" == -* ]]; then
				_complete_options "${cur}" "${options[*]}"
			else
				project_targets=$(c3c project view --targets 2>/dev/null)
				if ! [[ "${project_targets}" == "" ]]; then
					_complete_options "${cur}" "${project_targets} -..."
				fi
			fi
			;;
		compile-*|static-lib|dynamic-lib)
			if [[ "${cur}" == -* ]]; then
				_complete_options "${cur}" "${options[*]}"
			else
				_complete_options "${cur}" "-..."
				_add_default_completions
			fi
			;;
		project)
			_complete_options "${cur}" "view add-target fetch -h --help"
			return
			;;
		view)
			_complete_options "${cur}" "${project_view_filters[*]}"
			return
			;;
		fetch-sdk)
			_complete_options "${cur}" "windows macos android -h --help"
			return
			;;
		--template) # TODO: this only possible after `init`
			_complete_options "${cur}" "exe static-lib dynamic-lib"
			# Append the default options as a path is also valid
			_add_default_completions
			return
			;;
		--target)
			available_targets=$( \
				c3c --list-targets \
				| tail -n +2 \
				| sed "s/^ *\([^ ]*\) *$/\1/" \
				| tr '\n' ' ' \
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

	# Remove '=' from word-breaks so we can do some magic
	COMP_WORDBREAKS="${COMP_WORDBREAKS//=/}"

	# Prevent inserting a space after completing '--<flag>=', so that we can
	# double tab again to see the possible values for the flag
	if [[ "${#COMPREPLY[@]}" -eq 1 && "${COMPREPLY[0]}" == *= ]]; then
		compopt -o nospace
	fi

	# Big switch statement to catch all available flags and fill the opts
	# array with their possible values
	local opts=()
	case "${cur}" in
		--validation=*)
			opts=( "lenient" "strict" "obnoxious" )
			;;
		--trust=*)
			opts=( "none" "include" "full" )
			;;
		--optlevel=*)
			opts=( "none" "less" "more" "max" )
			;;
		--optsize=*)
			opts=( "none" "small" "tiny" )
			;;
		--test-log-level=*)
			opts=( "verbose" "debug" "info" "warn" "error" "critical" )
			;;
		--linker=*)
			opts=( "builtin" "cc" "custom" )
			;;
		--reloc=*)
			opts=( "none" "pic" "PIC" "pie" "PIE" )
			;;
		--x86cpu=*)
			opts=( "baseline" "ssse6" "sse4" "avx1" "avx2-v1" "avx2-v2" "avx512" "native" )
			;;
		--x86vec=*)
			opts=( "none" "mmx" "sse" "avx" "avx512" "default"  )
			;;
		--riscv-abi=*)
			opts=( "int-only" "float" "double" )
			;;
		--riscv-cpu=*)
			opts=( "rvi" "rvimac" "rvimafc" "rvgc" "rvgcv" )
			;;
		--memory-env=*)
			opts=( "normal" "small" "tiny" "none" )
			;;
		--fp-math=*)
			opts=( "strict" "relaxed" "fast" )
			;;
		--win64-simd=*)
			opts=( "array" "full" )
			;;
		--win-debug=*)
			opts=( "codeview" "dwarf" )
			;;
		--wincrt=*)
			opts=( "none" "static-debug" "static" "dynamic-debug" "dynamic" )
			;;
		--win-subsystem=*)
			opts=(
				"console" "windows" "native" "posix" "boot" "efi-app"
				"efi-boot" "efi-rom" "efi-runtime"
			)
			;;
		--linux-libc=*)
			opts=( "host" "gnu" "musl" )
			;;
		--sanitize=*)
			opts=( "address" "memory" "thread" )
			;;
		# Yes or no flags
		--safe=*|--panic-msg=*|--unroll-loops=*|--loop-vectorize=*| \
			--slp-vectorize=*|--merge-functions=*|--single-module=*| \
			--show-bactrace=*|--ansi=*|--use-stdlib=*|--link-libc=*| \
			--emit-stdlib=*|--strip-unused=*)
			opts=( "yes" "no" )
			;;
		# Warning flags
		--print-large-functions=*|--warn-deadcode=*|--warn-methodvisibility=*| \
			--warn-methodsnotresolved=*|--warn-deprecation=*|--warn-builtin=*)
			opts=( "yes" "no" "error" )
	esac
	if (( "${#opts[*]}" >= 1)); then
		_complete_option_flag "${cur}" "${opts[*]}"
	fi
}

complete -o default -F _c3c_complete c3c
