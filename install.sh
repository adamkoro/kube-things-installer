#!/bin/bash
# Created by adamkoro
#


# Check variables if empty
function check_variables() {
    if [[ -z "${HELM_VERSION}" ]]; then
        HELM_VERSION="3.16.4"
    fi
    if [[ -z "${KUBENS_VERSION}" ]]; then
        KUBENS_VERSION="0.9.5"
    fi
    if [[ -z "${KUBECTX_VERSION}" ]]; then
        KUBECTX_VERSION=${KUBENS_VERSION}
    fi
    if [[ -z "${KUBECOLOR_VERSION}" ]]; then
        KUBECOLOR_VERSION="0.4.0"
    fi
    if [[ -z "${TMP_DIR}" ]]; then
        TMP_DIR="$(mktemp -d)"
    fi
}

# Simple message
function message() {
    echo -e "\n--------------"
    echo "|${1}"
    echo "--------------"
}

# Info message
function info() {
    echo "INFO: ${1}"
}

# Error message
function error() {
    echo "ERROR: ${1}"
    exit 1
}

# Check system architecture
function check_arch() {
    if [[ $(uname -m) != "x86_64" ]]; then
        error "This script only supports x86_64 architecture"
    fi
}

# Check if the system is Linux
function check_os() {
    if [[ $(uname -s) != "Linux" ]]; then
        error "This script only supports Linux"
    fi
}

# Check curl
function check_curl() {
    if (! command -v curl &> /dev/null); then
        error "curl could not be found"
    fi
}

# Check tar
function check_tar() {
    if (! command -v tar &> /dev/null); then
        error "tar could not be found"
    fi
}

# Check install
function check_install() {
    if (! command -v install &> /dev/null); then
        error "install could not be found"
    fi
}

# Check sha256sum
function check_sha256sum() {
    if (! command -v sha256sum &> /dev/null); then
        error "sha256sum could not be found"
    fi
}

# Check if the user is root
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Download component
function download_component() {
    info "Downloading ${1}"
    CR_DIR=$(pwd)
    cd "${TMP_DIR}" || exit
    if (curl -LO "${2}"); then
        info "${1} downloaded successfully"
    else
        error "Could not download ${1}"
    fi
    cd "${CR_DIR}" || exit
}

# Check sha256sum
function check_sum() {
    info "Downloading sha256sum"
    if (curl -L "${2}" -o "${TMP_DIR}/${1}_checksum"); then
        info "sha256sum downloaded successfully"
    else
        error "Could not download sha256sum"
    fi
    info "Checking sha256sum"
    CR_DIR=$(pwd)
    cd "${TMP_DIR}" || exit
    # If checksum file contains the component name
    if (grep -q "${1}" "${TMP_DIR}/${1}_checksum"); then
        info "sha256sum file contains ${1}"
        if (sha256sum --quiet --ignore-missing -c "${TMP_DIR}/${1}_checksum"); then
            info "sha256sum checked successfully on ${1}"
        else
            error "Could not check sha256sum, probably the file is corrupted"
        fi
    else
        info "sha256sum file does not contain ${1}"
        if (echo "$(cat "${TMP_DIR}/${1}_checksum") ${1} | sha256sum --heck" &> /dev/null); then
            info "sha256sum checked successfully on ${1}"
        else
            error "Could not check sha256sum, probably the file is corrupted"
        fi
    fi
    cd "${CR_DIR}" || exit
}

# Install binary
function install_files() {
    info "Installing ${1}"
    if (install -o root -g root -m 0755 "${TMP_DIR}/${1}" /usr/local/bin/"${1##*/}"); then
        info "${1} installed successfully"
    else
        error "Could not install ${1}"
    fi
}

# Unpack tar.gz
function uncompress_file() {
    info "Unpacking ${1}"
    if (tar -xzf "${TMP_DIR}/${1}" -C "${TMP_DIR}"); then
        info "${1} uncompressed successfully"
    else
        error "Could not uncompress ${1}"
    fi
}

# Clean up
function clean_up() {
    info "Cleaning up"
    if (rm -rf "${TMP_DIR}"); then
        info "Cleaned up successfully"
    else
        error "Could not clean up"
    fi
}

# Check installed component
function check_installed_component() {
    if (command -v "${1}" &> /dev/null); then
        error "${1} is already installed"
    fi
}

# Install kubectl component
function install_kubectl() {
    check_installed_component "kubectl"
    download_component "kubectl" https://storage.googleapis.com/kubernetes-release/release/"$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"/bin/linux/amd64/kubectl
    check_sum "kubectl" https://storage.googleapis.com/kubernetes-release/release/"$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"/bin/linux/amd64/kubectl.sha256
    install_files "kubectl"
}

# Install helm component
function install_helm() {
    check_installed_component "helm"
    download_component "helm" "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
    check_sum "helm" "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz.sha256"
    uncompress_file "helm-v${HELM_VERSION}-linux-amd64.tar.gz"
    install_files linux-amd64/helm
}

# Install kubens component
function install_kubens() {
    check_installed_component "kubens"
    download_component "kubens" "https://github.com/ahmetb/kubectx/releases/download/v${KUBENS_VERSION}/kubens_v${KUBENS_VERSION}_linux_x86_64.tar.gz"
    check_sum "kubens" "https://github.com/ahmetb/kubectx/releases/download/v${KUBENS_VERSION}/checksums.txt"
    uncompress_file "kubens_v${KUBENS_VERSION}_linux_x86_64.tar.gz"
    install_files "kubens"
}

# Install kubectx component
function install_kubectx() {
    check_installed_component "kubectx"
    download_component "kubectx" "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubectx_v${KUBECTX_VERSION}_linux_x86_64.tar.gz"
    check_sum "kubectx" "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/checksums.txt"
    uncompress_file "kubectx_v${KUBECTX_VERSION}_linux_x86_64.tar.gz"
    install_files "kubectx"
}

# Install kubecolor component
function install_kubecolor() {
    check_installed_component "kubecolor"
    download_component "kubecolor" "https://github.com/kubecolor/kubecolor/releases/download/v${KUBECOLOR_VERSION}/kubecolor_${KUBECOLOR_VERSION}_linux_amd64.tar.gz"
    check_sum "kubecolor" "https://github.com/kubecolor/kubecolor/releases/download/v${KUBECOLOR_VERSION}/checksums.txt"
    uncompress_file "kubecolor_${KUBECOLOR_VERSION}_linux_amd64.tar.gz"
    install_files "kubecolor"
}

# Remove component
function remove_component() {
    info "Removing ${1}"
    if (rm -f /usr/local/bin/"${1}"); then
        info "${1} removed successfully"
    else
        error "Could not remove ${1}"
    fi
}

# Install kubectl completion
function install_kubectl_completion() {
    info "Installing kubectl completion"
    if (kubectl completion bash > /etc/bash_completion.d/kubectl); then
        info "kubectl completion installed successfully"
    else
        error "Could not install kubectl completion"
    fi
}

# Install helm completion
function install_helm_completion() {
    info "Installing helm completion"
    if (helm completion bash > /etc/bash_completion.d/helm); then
        info "helm completion installed successfully"
    else
        error "Could not install helm completion"
    fi
}

# Auto complete for kubecolor
function install_kubecolor_completion() {
    info "Auto complete for kubecolor"
    if (echo "complete -F __start_kubectl k" >> ~/.bashrc); then
        info "Auto complete for kubecolor successfully"
    else
        error "Could not auto complete for kubecolor"
    fi
}

# TODO: kubens and kubectx completion
function install_kubens_completion() {
    info "Auto complete for kubens"
    sudo curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubens.bash -o /etc/bash_completion.d/kubens.bash
}

function install_kubectx_completion() {
    info "Auto complete for kubectx"
    curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubectx.bash -o /etc/bash_completion.d/kubectx.bash
}


# Alias k as kubecolor
function alias_kubecolor() {
    info "Alias k as kubecolor"
    if (echo "alias k='kubecolor'" >> ~/.bashrc); then
        info "Alias k as kubecolor successfully"
    else
        error "Could not alias k as kubecolor"
    fi
}




# Help
function help() {
    echo "Usage: install.sh [OPTION] [COMPONENT]"
    echo "Install kubectl, helm, kubens, kubectx and kubecolor"
    echo ""
    echo "Options:"
    echo "  -i, --install   install component"
    echo "  -r, --remove    remove component"
    echo "  -h, --help      display this help and exit"
    echo "  -v, --version   display version information and exit"
    echo ""
    echo "Components:"
    echo "  -a, --all       install all components"
    echo "  kubectl         install kubectl"
    echo "  helm            install helm"
    echo "  kubens          install kubens"
    echo "  kubectx         install kubectx"
    echo "  kubecolor       install kubecolor"
    echo ""
    echo "Examples:"
    echo "Install kubectl:              install.sh -i kubectl"
    echo "Install all the components:   install.sh -i --all"
    echo "Remove kubectl:               install.sh -r kubectl"
    echo "Help message:                 install.sh -h"
    echo "Version:                      install.sh -v"
    echo ""
    exit 0
}

# Version
function version() {
    echo "Version: 1.0.0"
    exit 0
}

# Check dependencies
function check_dependencies() {
    check_arch
    check_os
    check_curl
    check_tar
    check_install
    check_sha256sum
    check_root
}

if [[ "$#" -eq 0 ]]; then
    help
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            help
            ;;
        -v|--version)
            version
            ;;
        -i | --install)
            check_dependencies
            check_variables
            COMPONENT_NAME="$2"
            case $2 in
                -a|--all)
                    message "Installing kubectl"
                    install_kubectl
                    install_kubectl_completion
                    message "Installing helm"
                    install_helm
                    install_helm_completion
                    message "Installing kubens"
                    install_kubens
                    install_kubens_completion
                    message "Installing kubectx"
                    install_kubectx
                    install_kubectx_completion
                    message "Installing kubecolor"
                    install_kubecolor
                    message "Setting up aliases and bash compleations"
                    install_kubectl_completion
                    install_kubecolor_completion
                    alias_kubecolor
                    clean_up
                    exit 0
                    ;;
                kubectl)
                    message "Installing kubectl"
                    install_kubectl
                    install_kubectl_completion
                    clean_up
                    exit 0
                    ;;
                helm)
                    message "Installing helm"
                    install_helm
                    install_helm_completion
                    clean_up
                    exit 0
                    ;;
                kubens)
                    message "Installing kubens"
                    install_kubens
                    install_kubens_completion
                    clean_up
                    exit 0
                    ;;
                kubectx)
                    message "Installing kubectx"
                    install_kubectx
                    install_kubectx_completion
                    clean_up
                    exit 0
                    ;;
                kubecolor)
                    message "Installing kubecolor"
                    install_kubecolor
                    install_kubecolor_completion
                    clean_up
                    exit 0
                    ;;
                *)
                    echo "ERROR: Invalid component option: ${2}"
                    echo "Use -h or --help to see the available options"
                    exit 1
                    ;;
            esac
            ;;
        -r | --remove)
            check_dependencies
            COMPONENT_NAME="$2"
            case $2 in
                -a|--all)
                    message "Removing kubectl"
                    remove_component kubectl
                    message "Removing helm"
                    remove_component helm
                    message "Removing kubens"
                    remove_component kubens
                    message "Removing kubectx"
                    remove_component kubectx
                    message "Removing kubecolor"
                    remove_component kubecolor
                    exit 0
                    ;;
                kubectl)
                    message "Removing kubectl"
                    remove_component "${COMPONENT_NAME}"
                    exit 0
                    ;;
                helm)
                    message "Removing helm"
                    remove_component "${COMPONENT_NAME}"
                    exit 0
                    ;;
                kubens)
                    message "Removing kubens"
                    remove_component "${COMPONENT_NAME}"
                    exit 0
                    ;;
                kubectx)
                    message "Removing kubectx"
                    remove_component "${COMPONENT_NAME}"
                    exit 0
                    ;;
                kubecolor)
                    message "Removing kubecolor"
                    remove_component "${COMPONENT_NAME}"
                    exit 0
                    ;;
                *)
                    echo "ERROR: Invalid component option: ${2}"
                    echo "Use -h or --help to see the available options"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "ERROR: Invalid option: ${1}"
            echo "Use -h or --help to see the available options"
            exit 1
            ;;
    esac
done
