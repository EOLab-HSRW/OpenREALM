#!/bin/bash
# Install dependencies for OpenREALM (Ubunut 22.04)
#
# This file is part of the EOLab Drones Ecosystem (drones.eolab.de) with
# the home repository in: https://github.com/EOLab-HSRW/OpenREALM
#
# Copyright (C) 2025  Harley Lara
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# SYNOPSIS
#   install-deps.sh [OPTIONS]
#
# DESCRIPTION
#   Installs build prerequisites via apt, then builds and installs:
#     • g2o (pinned commit)
#     • OpenVSLAM (laxnpander/openvslam)
#   The script is idempotent (safe to re-run) and configurable via flags.
#
# OPTIONS
#   --prefix DIR           Installation prefix (default: /usr/local)
#   --src-dir DIR          Checkout/build directory (default: $HOME/src)
#   --g2o-repo URL         g2o Git repository (default: https://github.com/RainerKuemmerle/g2o.git)
#   --g2o-commit SHA       g2o commit to checkout (default: 9b41a4ea5ade8e1250b9c1b279f3a9c098811b5a)
#   --openvslam-repo URL   OpenVSLAM Git repository (default: https://github.com/laxnpander/openvslam.git)
#   --openvslam-commit X   OpenVSLAM ref (branch/tag/commit). Default: repo default branch.
#   --jobs N               Parallel build jobs (default: number of CPUs)
#   --build-examples[=ON|OFF]  Build OpenVSLAM examples (default: ON)
#   --build-tests[=ON|OFF]     Build OpenVSLAM tests (default: ON)
#   --use-pangolin[=ON|OFF]    Enable Pangolin viewer (default: OFF)
#   --skip-apt             Do not run apt update/install (assume deps present)
#   --quiet                Suppress diagnostics (stderr). Exit codes still indicate result.
#   --no-color             Disable colored diagnostics.
#   --help                 Print this help and exit 0.
#
# FILES
#   /etc/lsb-release                 Distro detection (if present).
#   /usr/include/suitesparse/cs.h    Preferred CSparse header location (from libsuitesparse-dev).
#   $SRC_DIR/g2o                     g2o checkout.
#   $SRC_DIR/openvslam               OpenVSLAM checkout.
#
# EXIT STATUS
#   0  Success.
#   1  Expected thing not found / not supported (e.g., unsupported distro).
#   >1 Unexpected error; a diagnostic is printed to stderr.
#
# EXAMPLES
#   ./install-deps.sh --src-dir "$HOME/workspace" --jobs 8
#   ./install-deps.sh --build-examples=OFF --build-tests=OFF --skip-apt
#
# REPORTING BUGS
#   Open an issue under https://github.com/EOLab-HSRW/drones/issues and
#   please include the full log output (use --quiet only when scripting).
#
# NOTES
#   • We prefer SuiteSparse’s cs.h if available and fall back to g2o’s internal csparse.
#   • We avoid hard-coded usernames and honor --prefix and --src-dir everywhere.
#   • We pin g2o to a known-good commit for compatibility with this OpenVSLAM fork.

set -euo pipefail

# ------------------------------ Defaults ---------------------------------------

PREFIX="/usr/local"
SRC_DIR="${HOME}/real_deps"
G2O_REPO="https://github.com/RainerKuemmerle/g2o.git"
G2O_COMMIT="9b41a4ea5ade8e1250b9c1b279f3a9c098811b5a"
OPENVSLAM_REPO="https://github.com/laxnpander/openvslam.git"
OPENVSLAM_COMMIT=""  # empty = default branch
JOBS="$(nproc || echo 4)"
BUILD_EXAMPLES="ON"
BUILD_TESTS="ON"
USE_PANGOLIN="OFF"
SKIP_APT=false
QUIET=false
USE_COLOR=true

# ------------------------------ Helpers ----------------------------------------

print_help() {
  sed -n '1,/^set -euo pipefail/p' "$0" | sed '$d'
}

# Color + logging
if [[ -t 2 ]]; then :; else USE_COLOR=false; fi
RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
enable_colors() {
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
}
if $USE_COLOR; then enable_colors; fi

log_ok()   { $QUIET || echo -e "${GREEN}[+]${NC} $*" >&2; }
log_info() { $QUIET || echo -e "${BLUE}[*]${NC} $*"  >&2; }
log_warn() { $QUIET || echo -e "${YELLOW}[!]${NC} $*" >&2; }
log_fail() { $QUIET || echo -e "${RED}[x]${NC} $*"   >&2; }

# Trap the last command for better error context
current_command=""
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'code=$?; log_fail "\"$last_command\" failed with exit code $code in $0"; exit $code' ERR

# Parse ON/OFF style args (allow flag, flag=, or flag=value)
parse_on_off() {
  # $1 = value or empty; echo ON|OFF
  local v="${1:-}"
  case "${v^^}" in
    ""|"ON"|"TRUE"|"YES"|"1") echo "ON" ;;
    "OFF"|"FALSE"|"NO"|"0")   echo "OFF" ;;
    *) echo "$v" ;;
  esac
}

# ------------------------------ Args -------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)            PREFIX="$2"; shift 2 ;;
    --src-dir)           SRC_DIR="$2"; shift 2 ;;
    --g2o-repo)          G2O_REPO="$2"; shift 2 ;;
    --g2o-commit)        G2O_COMMIT="$2"; shift 2 ;;
    --openvslam-repo)    OPENVSLAM_REPO="$2"; shift 2 ;;
    --openvslam-commit)  OPENVSLAM_COMMIT="$2"; shift 2 ;;
    --jobs|-j)           JOBS="$2"; shift 2 ;;
    --build-examples|--build-examples=*)
      arg="${1#*=}"; [[ "$arg" == "$1" ]] && arg="" ; BUILD_EXAMPLES="$(parse_on_off "$arg")"; shift 1 ;;
    --build-tests|--build-tests=*)
      arg="${1#*=}"; [[ "$arg" == "$1" ]] && arg="" ; BUILD_TESTS="$(parse_on_off "$arg")"; shift 1 ;;
    --use-pangolin|--use-pangolin=*)
      arg="${1#*=}"; [[ "$arg" == "$1" ]] && arg="" ; USE_PANGOLIN="$(parse_on_off "$arg")"; shift 1 ;;
    --skip-apt)          SKIP_APT=true; shift ;;
    --quiet)             QUIET=true; shift ;;
    --no-color)          USE_COLOR=false; shift ;;
    --help)              print_help; exit 0 ;;
    --) shift; break ;;
    -*)
      echo "install-deps.sh: unknown option: $1" >&2
      echo "Try 'install-deps.sh --help' for more information." >&2
      exit 2
      ;;
    *) break ;;
  esac
done
$USE_COLOR || { RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''; }

# ------------------------------ Pre-flight -------------------------------------

# Sudo helper
SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    log_fail "This script requires root privileges for apt and install steps. Please install sudo or run as root."
    exit 2
  fi
fi

log_info "Starting OpenREALM dependencies installation…"
log_info "Prefix: ${PREFIX}"
log_info "Source dir: ${SRC_DIR}"
log_info "CPU jobs: ${JOBS}"
log_info "Examples: ${BUILD_EXAMPLES}, Tests: ${BUILD_TESTS}, Pangolin: ${USE_PANGOLIN}"

# Distro sanity (best-effort)
if [[ -f /etc/debian_version ]]; then
  log_ok "Debian-based distribution detected."
else
  log_fail "Non-Debian distro detected. apt-specific steps may fail."
  exit 2
fi

mkdir -p "$SRC_DIR"

# Network quick check (best-effort)
check_host() {
  local host="$1"
  (getent hosts "$host" >/dev/null 2>&1) || (timeout 5 bash -lc "echo > /dev/tcp/${host}/443" >/dev/null 2>&1) || return 1
}
if ! check_host "github.com"; then
  log_warn "Cannot verify network access to github.com. Clone steps may fail if offline."
fi

# ------------------------------ APT setup --------------------------------------

retry() {
  # retry N cmd...
  local attempts="$1"; shift
  local n=1
  until "$@"; do
    if (( n >= attempts )); then return 1; fi
    sleep $(( n * 2 ))
    ((n++))
  done
}

apt_install() {
  $SKIP_APT && { log_info "Skipping apt install for: $*"; return 0; }
  current_command="apt-get install $*"
  # shellcheck disable=SC2086
  retry 3 $SUDO DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install $*
}

if ! $SKIP_APT; then
  log_info "Updating apt package lists…"
  retry 3 $SUDO apt-get update -y --quiet
fi

log_info "Installing build tools and utilities…"
apt_install \
  build-essential \
  pkg-config \
  cmake \
  ninja-build \
  git \
  ca-certificates \
  wget \
  curl \
  unzip \
  apt-utils

log_info "Installing libraries (Eigen, SuiteSparse/CSparse, OpenCV, etc.)…"
apt_install \
  libeigen3-dev \
  libsuitesparse-dev \
  libgoogle-glog-dev \
  libgflags-dev \
  libopencv-dev \
  libyaml-cpp-dev \
  gdal-bin \
  libgdal-dev \
  libcgal-dev \
  libpcl-dev \
  exiv2 \
  libexiv2-dev

# ------------------------------ Build: g2o -------------------------------------

G2O_DIR="${SRC_DIR}/g2o"
if [[ -d "${G2O_DIR}/.git" ]]; then
  log_info "Updating existing g2o repo at ${G2O_DIR}…"
  git -C "${G2O_DIR}" fetch --all --tags --prune
else
  log_info "Cloning g2o from ${G2O_REPO} into ${G2O_DIR}…"
  git clone --recursive "${G2O_REPO}" "${G2O_DIR}"
fi

log_info "Checking out g2o commit ${G2O_COMMIT}…"
git -C "${G2O_DIR}" checkout --detach "${G2O_COMMIT}"

# Configure + build g2o
G2O_BUILD="${G2O_DIR}/build"
mkdir -p "${G2O_BUILD}"

CMAKE_GENERATOR="Unix Makefiles"
if command -v ninja >/dev/null 2>&1; then
  CMAKE_GENERATOR="Ninja"
fi

log_info "Configuring g2o…"
cmake -S "${G2O_DIR}" -B "${G2O_BUILD}" \
  -G "${CMAKE_GENERATOR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_CXX_STANDARD=17 \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_UNITTESTS=OFF \
  -DG2O_USE_CHOLMOD=OFF \
  -DG2O_USE_CSPARSE=ON \
  -DG2O_USE_OPENGL=OFF \
  -DG2O_USE_OPENMP=ON

log_info "Building g2o…"
cmake --build "${G2O_BUILD}" --parallel "${JOBS}"

log_info "Installing g2o to ${PREFIX}…"
$SUDO cmake --install "${G2O_BUILD}"

# ------------------------------ CSparse header handling ------------------------

CSPARSE_INCLUDE=""
if [[ -f /usr/include/suitesparse/cs.h ]]; then
  CSPARSE_INCLUDE="/usr/include/suitesparse"
  log_ok "Found SuiteSparse cs.h at ${CSPARSE_INCLUDE}"
elif [[ -f "${G2O_DIR}/EXTERNAL/csparse/cs.h" ]]; then
  CSPARSE_INCLUDE="${G2O_DIR}/EXTERNAL/csparse"
  log_warn "Using g2o internal csparse header at ${CSPARSE_INCLUDE}"
else
  log_fail "Could not locate cs.h (CSparse). OpenVSLAM may fail to compile. Consider installing libsuitesparse-dev."
  exit 2
fi

# ------------------------------ Build: OpenVSLAM -------------------------------

OVS_DIR="${SRC_DIR}/openvslam"
if [[ -d "${OVS_DIR}/.git" ]]; then
  log_info "Updating existing OpenVSLAM repo at ${OVS_DIR}…"
  git -C "${OVS_DIR}" fetch --all --tags --prune
else
  log_info "Cloning OpenVSLAM from ${OPENVSLAM_REPO} into ${OVS_DIR}…"
  git clone --recursive "${OPENVSLAM_REPO}" "${OVS_DIR}"
fi

if [[ -n "${OPENVSLAM_COMMIT}" ]]; then
  log_info "Checking out OpenVSLAM ref ${OPENVSLAM_COMMIT}…"
  git -C "${OVS_DIR}" checkout --detach "${OPENVSLAM_COMMIT}"
fi

# Ensure submodules are up-to-date
git -C "${OVS_DIR}" submodule sync --recursive
git -C "${OVS_DIR}" submodule update --init --recursive

OVS_BUILD="${OVS_DIR}/build"
mkdir -p "${OVS_BUILD}"

# Compose extra CXX flags
EXTRA_CXX_FLAGS=""
if [[ -n "${CSPARSE_INCLUDE}" ]]; then
  EXTRA_CXX_FLAGS="-I${CSPARSE_INCLUDE}"
fi

# Pangolin toggles (optional viewer)
PANGO_FLAGS=(
  "-DUSE_PANGOLIN_VIEWER=${USE_PANGOLIN}"
  "-DINSTALL_PANGOLIN_VIEWER=${USE_PANGOLIN}"
)

log_info "Configuring OpenVSLAM…"
cmake -S "${OVS_DIR}" -B "${OVS_BUILD}" \
  -G "${CMAKE_GENERATOR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_CXX_STANDARD=17 \
  -DUSE_SOCKET_PUBLISHER=OFF \
  -DUSE_STACK_TRACE_LOGGER=ON \
  -DBUILD_TESTS="${BUILD_TESTS}" \
  -DBUILD_EXAMPLES="${BUILD_EXAMPLES}" \
  -DCMAKE_CXX_FLAGS="${EXTRA_CXX_FLAGS}" \
  "${PANGO_FLAGS[@]}"

log_info "Building OpenVSLAM…"
cmake --build "${OVS_BUILD}" --parallel "${JOBS}"

log_info "Installing OpenVSLAM to ${PREFIX}…"
$SUDO cmake --install "${OVS_BUILD}"

# ------------------------------ Summary ----------------------------------------

log_ok "Installation complete."
echo
echo "  g2o repo:        ${G2O_DIR}"
echo "  OpenVSLAM repo:  ${OVS_DIR}"
echo "  Install prefix:  ${PREFIX}"
echo "  Build generator: ${CMAKE_GENERATOR}"
echo
log_ok "You can run OpenVSLAM examples from ${OVS_BUILD}/run_* if built with --build-examples=ON."


