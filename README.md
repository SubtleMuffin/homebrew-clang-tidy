# homebrew formulas

## clang-tidy
You can choose from one of the follow three ways of installing `clang-tidy` via `brew`:

### To install from source (recommended, most trustworthy):
```shell
brew install subtlemuffin/formulas/clang-tidy --verbose --build-from-source
```

### To kindly contribute to this repo with building a bottle (please submit a PR)
```shell
brew install subtlemuffin/formulas/clang-tidy --verbose --build-bottle
```

### To install with built bottles (binaries), if you trust me
```shell
brew install subtlemuffin/formulas/clang-tidy
```

# Bumping a version
0. Untap `brew untap subtlemuffin/
1. Get the necessary files from [llvm releases](https://github.com/llvm/llvm-project/releases).
2. Find out its `sha256` by ```shasum -a 256 <filename>```.
3. Build the bottle via ```brew install clang-tidy.rb --verbose --build-bottle```
4. Create bottle via ```brew bottle clang-tidy```

# Contributing
As of now I do not have a working `Github Actions - Release - Pull Request` chain to automate this repo. If you

1. find such template, please let me know
2. would like to contribute to the bottles, please create a PR with the outputs of `brew bottle subtlemuffin/formulas/clang-tidy` and upload the generated bottles.
