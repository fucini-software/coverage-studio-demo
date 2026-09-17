#!/usr/bin/env sh
# @file generate-all.sh
# @brief Regenerate every sample's reports, each in the lab image built for it.
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
#   scripts/generate-all.sh            # every sample that has a generator
#   scripts/generate-all.sh js go      # only these
#
# Build the images first: docker buildx bake -f docker/docker-bake.hcl
set -eu
cd "$(dirname "$0")/.."
root="$(pwd)"

samples="$*"
if [ -z "$samples" ]; then
  samples="$(for f in samples/*/generate.sh; do basename "$(dirname "$f")"; done)"
fi

: > samples/VERSIONS.md
echo "# Tool versions of the last regeneration" >> samples/VERSIONS.md

for name in $samples; do
  echo "== $name"
  # Files written through the mount should belong to whoever runs this, not to
  # root; HOME points somewhere writable for tools that insist on a cache.
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$root:/work" "coverage-studio-lab:$name" "samples/$name/generate.sh"
  if [ -f "samples/$name/coverage/VERSIONS.txt" ]; then
    { echo; echo "## $name"; echo; cat "samples/$name/coverage/VERSIONS.txt"; } >> samples/VERSIONS.md
  fi
done
