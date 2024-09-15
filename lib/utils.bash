#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for micro.
GH_REPO="https://github.com/zyedidia/micro"
TOOL_NAME="micro"
TOOL_TEST="micro --version"

# CUSTOMIZE
get_download_url() {
	local version; version="$1"
	local platform; platform="$2"
	local arch; arch="$3"

	local build
  case "${platform}" in
    darwin)
			if [[ "${arch}" == "aarch64" ]]; then
				build='macos-arm64'
			else
				build='macos-arm64'
			fi
      ;;
    linux)
			if [[ "${arch}" == "aarch64" ]]; then
				build='linux-arm64'
			elif [[ "${arch}" == "x86_64" ]]; then
				build='linux64'
			else
				build='linux32'
			fi
      ;;
  esac

	# https://github.com/zyedidia/micro/releases/download/v2.0.14/micro-2.0.14-linux-arm64.tgz
	echo -n "$GH_REPO/releases/download/v${version}/${TOOL_NAME}-${version}-${build}.tar.gz"
}

# CUSTOMIZE
list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' |
		grep -v rc |
		grep -v nightly \
		# NOTE: You might want to adapt this sed to remove non-version strings from tags
}

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if micro is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
	# TODO: Adapt this. By default we simply list the tag names from GitHub releases.
	# Change this function if micro has other means of determining installable versions.
	list_github_tags
}

# MOD - update
download_release() {
	local version; version="$1"
	local filename; filename="$2"
	local platform; platform="$(get_raw_platform)"
	local arch; arch="$(get_raw_arch)"
	local url; url="$(get_download_url "$version" "$platform" "$arch")"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		# TODO: Assert micro executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}

# MOD - new
get_arch() {
  local arch; arch=$(uname -m | tr '[:upper:]' '[:lower:]')
  local platform; platform=$(get_raw_platform)
  case ${arch} in
  arm64)
    if [[ "${platform}" == "darwin" ]]; then
      arch='x86_64'
    else
      arch='aarch64'
    fi
    ;;
  armv7l)
    arch='arm'
    ;;
  esac

  echo "${arch}"
}

get_platform() {
  local plat; plat=$(get_raw_platform)
  case ${plat} in
  darwin)
    plat='apple-darwin'
    ;;
  linux)
    plat='unknown-linux-gnu'
    [[ $(get_arch) == "arm" ]] && plat='unknown-linux-gnueabihf'
    ;;
  windows)
    plat='pc-windows-msvc'
    ;;
  esac

  echo -n "${plat}"
}

get_raw_platform() {
	# MAC: darwin
	# LINUX: linux
  uname | tr '[:upper:]' '[:lower:]'
}

get_raw_arch() {
	# MAC: arm64
	# LINUX: aarch64
	# LINUX: x86_64
  uname -m | tr '[:upper:]' '[:lower:]'
}

get_raw_kernel() {
	# MAC: darwin
	# LINUX: linux
  uname -s | tr '[:upper:]' '[:lower:]'
}

get_raw_processor() {
	# MAC: arm
	# LINUX: x86_64
	# LINUX: unknown
  uname | tr '[:upper:]' '[:lower:]'
}

