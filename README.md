<div align="center">

# asdf-micro [![Build](https://github.com/localdee/asdf-micro/actions/workflows/build.yml/badge.svg)](https://github.com/localdee/asdf-micro/actions/workflows/build.yml) [![Lint](https://github.com/localdee/asdf-micro/actions/workflows/lint.yml/badge.svg)](https://github.com/localdee/asdf-micro/actions/workflows/lint.yml)

[micro](https://micro-editor.github.io) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Install

Plugin:

```shell
asdf plugin add locald-micro https://github.com/localdee/asdf-micro.git
```

locald-micro:

```shell
# Show all installable versions
asdf list-all locald-micro

# Install specific version
asdf install locald-micro latest

# Set a version globally (on your ~/.tool-versions file)
asdf global locald-micro latest

# Now micro commands are available
micro --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/localdee/asdf-micro/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [locald.sh](https://github.com/localdee/)
