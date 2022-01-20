#!/usr/bin/env bash

set -euo pipefail

main() {
	need_cmd curl
	need_cmd grep
	need_cmd tar
	need_cmd jq
	need_cmd chmod
	build
}

build() {

  CDIR="$(cd "$(dirname "$0")" && pwd)"
  build_dir="$CDIR/build"

  while getopts A:K:q option
  do
    case "${option}"
    in
      q) QUIET=1;;
      A) ARCH=${OPTARG};;
      K) KERNEL=${OPTARG};;
    esac
  done

  rm -rf "$build_dir"
  mkdir -p "$build_dir"

  for f in prerun.sh pluginrc.fish pluginrc.sh pluginrc.zsh pluginrc.xsh
  do
      cp "$CDIR/$f" "$build_dir/"
  done

  cd $build_dir

  _cputype="x86_64"
  _clibtype="musl"
  _ostype=unknown-linux-$_clibtype
  _target="$_cputype-$_ostype"
  filename="starship-$_target"

  url="$(curl -f -sL "https://api.github.com/repos/starship/starship/releases/latest" | jq -r '.assets[].browser_download_url' | grep '.tar.gz$' | grep "$_target")"

  echo "Downloading starship..."
  curl -sL "$url" -o "${build_dir}/${filename}"
  rm "${build_dir}/${filename}"

  tar -xf "${build_dir}/${filename}" ${build_dir}/starship
  chmod +x starship

}

cmd_chk() {
  >&2 echo Check "$1"
	command -v "$1" >/dev/null 2>&1
}

need_cmd() {
  if ! cmd_chk "$1"; then
    error "need $1 (command not found)"
    exit 1
  fi
}

main "$@" || exit 1
