#!/bin/bash -i
# This code was generated by the dcontainer cli 
# For more information: https://github.com/devcontainers-contrib/cli 

set -e


ensure_curl() {
    # Ensure curl available
    if ! type curl >/dev/null 2>&1; then
        apt-get update -y && apt-get -y install --no-install-recommends curl ca-certificates
    fi 
}


ensure_dcontainer() {
    # Ensure existance of the dcontainer cli program
    local variable_name=$1
    local dcontainer_location=""

    # If possible - try to use an already installed dcontainer
    if [[ -z "${DCONTAINER_FORCE_CLI_INSTALLATION}" ]]; then
        if [[ -z "${DCONTAINER_CLI_LOCATION}" ]]; then
            if type dcontainer >/dev/null 2>&1; then
                echo "Using a pre-existing dcontainer"
                dcontainer_location=dcontainer
            fi
        elif [ -f "${DCONTAINER_CLI_LOCATION}" ] && [ -x "${DCONTAINER_CLI_LOCATION}" ] ; then
            echo "Using a pre-existing dcontainer which were given in env varialbe"
            dcontainer_location=${DCONTAINER_CLI_LOCATION}
        fi
    fi

    # If not previuse installation found, download it temporarly and delete at the end of the script 
    if [[ -z "${dcontainer_location}" ]]; then

        if [ "$(uname -sm)" == "Linux x86_64" ] || [ "$(uname -sm)" == "Linux aarch64" ]; then
            tmp_dir=$(mktemp -d -t dcontainer-XXXXXXXXXX)

            clean_up () {
                ARG=$?
                rm -rf $tmp_dir
                exit $ARG
            }
            trap clean_up EXIT

            curl -sSL https://github.com/devcontainers-contrib/cli/releases/download/v0.3.5/dcontainer-"$(uname -m)"-unknown-linux-gnu.tgz | tar xfzv - -C "$tmp_dir"
            chmod a+x $tmp_dir/dcontainer
            dcontainer_location=$tmp_dir/dcontainer
        else
            echo "No binaries compiled for non-x86-linux architectures yet: $(uname -m)"
            exit 1
        fi
    fi

    # Expose outside the resolved location
    declare -g ${variable_name}=$dcontainer_location

}

ensure_curl

ensure_dcontainer dcontainer_location

$dcontainer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers/features/java:1.1.1" \
    --option jdkDistro="$JDKDISTRO" --option version="$JDKVERSION"


$dcontainer_location \
    install \
    devcontainer-feature \
    "ghcr.io/ebaskoro/devcontainer-features/sdkman:1.0.0" \
    --option candidate="tomcat" --option version="$VERSION"
