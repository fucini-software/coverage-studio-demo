# syntax=docker/dockerfile:1.7
#
# (The line above is a parser directive and must stay first.)
#
# @file Dockerfile
# @brief The coverage lab: one stage per language.
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
# The coverage lab: one stage per language, each a small image of its own with
# exactly the toolchain that sample needs. A change to the Ruby stage rebuilds
# nothing of Java's. Build them with the bake file beside this one:
#
#   docker buildx bake            # every stage
#   docker buildx bake js         # one
#
# Every stage works the same way: the repository is mounted at /work, and the
# argument is the generator to run.
#
#   docker run --rm -v "$PWD:/work" coverage-studio-lab:js samples/js/generate.sh
#
# /work is fixed on purpose. Coverage reports record the paths they measured,
# and a fixed mount point makes those paths the same on every machine; each
# sample's .vscode/settings.json maps /work/samples/<name> back to the clone.
#
# Behind a proxy, pass it at build time; Docker forwards these predefined
# arguments without any ARG line here:
#
#   docker buildx bake --set '*.args.http_proxy=http://proxy:8080' \
#                      --set '*.args.https_proxy=http://proxy:8080'

# ---- C and C++: gcc/gcov/lcov/gcovr, and clang/llvm-cov with MC/DC ----------
# trixie rather than bookworm: MC/DC needs clang 18 or newer, and gcc 14 brings
# -fcondition-coverage. gcovr alone turns one gcov run into Cobertura,
# SonarQube generic, Coveralls, Clover, JaCoCo XML and its own JSON.
FROM debian:trixie-slim AS c
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates make cmake gcc g++ lcov gcovr clang llvm \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /work
ENTRYPOINT ["/bin/sh"]

# ---- JavaScript: Istanbul (nyc), later Stryker ------------------------------
FROM node:22-trixie-slim AS js
ENV npm_config_update_notifier=false \
    npm_config_fund=false
WORKDIR /work
ENTRYPOINT ["/bin/sh"]

# ---- Python: coverage.py -----------------------------------------------------
FROM python:3.13-slim-trixie AS python
RUN pip install --no-cache-dir "coverage>=7.6,<8" "pytest>=8,<9"
WORKDIR /work
ENTRYPOINT ["/bin/sh"]

# ---- Go: the cover profile, in set and count mode ---------------------------
FROM golang:1.25-trixie AS go
ENV GOFLAGS=-buildvcs=false \
    GOCACHE=/tmp/go-cache
WORKDIR /work
ENTRYPOINT ["/bin/sh"]
