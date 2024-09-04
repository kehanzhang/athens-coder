#!/usr/bin/env bash

# This script generates the version string used by Coder, including for dev
# versions. Note: the version returned by this script will NOT include the "v"
# prefix that is included in the Git tag.
#
# If $CODER_RELEASE is set to "true", the returned version will equal the
# current git tag. If the current commit is not tagged, this will fail.
#
# If $CODER_RELEASE is not set, the returned version will always be a dev
# version.

set -euo pipefail
# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cdroot

# Set the default version to 2.14.2
DEFAULT_VERSION="2.14.2"

# If in Sapling, just print the commit since we don't have tags.
if [[ -d ".sl" ]]; then
	sl log -l 1 | awk '/changeset/ { printf "0.0.0+sl-%s\n", substr($2, 0, 16) }'
	exit 0
fi

if [[ -n "${CODER_FORCE_VERSION:-}" ]]; then
	echo "${CODER_FORCE_VERSION}"
	exit 0
fi

# Always use the default version
version="v${DEFAULT_VERSION}"

# If the HEAD has extra commits since the last tag then we are in a dev version.
#
# Dev versions are denoted by the "-devel+" suffix with a trailing commit short
# SHA.
if [[ "${CODER_RELEASE:-}" != *t* ]]; then
	version+="-devel+$(git rev-parse --short HEAD)"
fi

# Remove the "v" prefix.
echo "${version#v}"
