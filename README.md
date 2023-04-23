# kube-things-installer
Install kubectl, helm, kubens, kubectx, kubecolor with a simple script

## What will be installed?
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)
- [kubens](https://github.com/ahmetb/kubectx)
- [kubectx](https://github.com/ahmetb/kubectx)
- [kubecolor](https://github.com/kubecolor/kubecolor)


## Usage
### Help parameter
```bash
./install.sh -h
```
#### Output
```less
Usage: install.sh [OPTION] [COMPONENT]
Install kubectl, helm, kubens, kubectx and kubecolor

Options:
  -i, --install   install component
  -r, --remove    remove component
  -h, --help      display this help and exit
  -v, --version   display version information and exit

Components:
  -a, --all       install all components
  kubectl         install kubectl
  helm            install helm
  kubens          install kubens
  kubectx         install kubectx
  kubecolor       install kubecolor

Examples:
Install kubectl:              install.sh -i kubectl
Install all the components:   install.sh -i --all
Remove kubectl:               install.sh -r kubectl
Help message:                 install.sh -h
Version:                      install.sh -v
```

### Install parameter
#### Install everything
```bash
./install.sh -i -a
```
#### Install kubectl
```bash
./install.sh -i kubectl
```

### Remove parameter
#### Remove kubectl
```bash
./install.sh -r kubectl
```
#### Remove everything
```bash
./install.sh -r -a
```

### Version parameter
#### Show installer version
```bash
./install.sh -v
```

