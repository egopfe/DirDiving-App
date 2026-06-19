#!/usr/bin/env bash
# Serialize XcodeGen against DIRDiving.xcodeproj — safe for parallel validators.
set -euo pipefail

_xcodegen_once_root() {
  if [[ -n "${XCODEGEN_ONCE_ROOT:-}" ]]; then
    printf '%s\n' "${XCODEGEN_ONCE_ROOT}"
    return 0
  fi
  local lib_dir
  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${lib_dir}/../.." && pwd
}

xcodegen_once() {
  local root stamp lock_dir lock_file project_yml project_dir
  root="$(_xcodegen_once_root)"
  lock_dir="${root}/.build/xcodegen"
  lock_file="${lock_dir}/generate.lock"
  stamp="${lock_dir}/project.stamp"
  project_yml="${root}/project.yml"
  project_dir="${root}/DIRDiving.xcodeproj"

  if [[ "${DIR_DIVING_SKIP_XCODEGEN:-}" == "1" && -d "${project_dir}" ]]; then
    echo "[xcodegen-once] reuse existing project (DIR_DIVING_SKIP_XCODEGEN=1)"
    return 0
  fi

  mkdir -p "${lock_dir}"

  local spec_hash=""
  if command -v shasum >/dev/null 2>&1; then
    spec_hash="$(shasum -a 256 "${project_yml}" | awk '{print $1}')"
  elif command -v sha256sum >/dev/null 2>&1; then
    spec_hash="$(sha256sum "${project_yml}" | awk '{print $1}')"
  fi

  if [[ -n "${spec_hash}" && -f "${stamp}" && -d "${project_dir}" ]]; then
    if [[ "$(cat "${stamp}")" == "${spec_hash}" ]]; then
      echo "[xcodegen-once] project up to date for project.yml"
      return 0
    fi
  fi

  local lock_acquired=0
  local wait_start wait_now
  wait_start="$(date +%s)"
  while ! mkdir "${lock_file}" 2>/dev/null; do
    wait_now="$(date +%s)"
    if (( wait_now - wait_start > 300 )); then
      echo "[xcodegen-once] timed out waiting for XcodeGen lock: ${lock_file}" >&2
      return 1
    fi
    sleep 0.2
  done
  lock_acquired=1
  trap 'if [[ "${lock_acquired}" == "1" ]]; then rm -rf "'"${lock_file}"'"; fi' EXIT INT TERM

  if [[ -n "${spec_hash}" && -f "${stamp}" && -d "${project_dir}" ]]; then
    if [[ "$(cat "${stamp}")" == "${spec_hash}" ]]; then
      echo "[xcodegen-once] project up to date (post-lock)"
      rm -rf "${lock_file}"
      lock_acquired=0
      trap - EXIT INT TERM
      return 0
    fi
  fi

  echo "[xcodegen-once] running xcodegen generate"
  (
    cd "${root}"
    xcodegen generate
  )
  if [[ -n "${spec_hash}" ]]; then
    printf '%s\n' "${spec_hash}" > "${stamp}"
  fi

  rm -rf "${lock_file}"
  lock_acquired=0
  trap - EXIT INT TERM
  echo "[xcodegen-once] project ready"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  xcodegen_once "$@"
fi
