# Pytomata

## Automated pyenv-virtualenv management made dead-simple.

Pytomata is the automation for pyenv-virtualenv you always wanted.
Written as simple zsh functions, Pytomata's goal is to provide the user
with the simplest solution for the Python venv headache.

* If you love [Pyenv](https://github.com/pyenv/pyenv) and [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) but don't like the manual work;
* If you ever forgot to activate virtualenv and installed pip packages globally;
* If you have heard about direnv but think that it is too much for your needs;
* If you don't like to bloat your git repository with unnecessary files;

**Then Pytomata is for you!**

Written in zsh and ready to work on MacOS.

Though Pytomata currently supports only zsh, the goal is to extend
its functionality into other shells as well.
The author is not against Bash or Fish, and plans to implement support
for them as soon as possible.

### Requirements

* [pyenv](https://github.com/pyenv/pyenv) -- probably the best way to manage python versions
* [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) -- important extension for pyenv which manages virtualenvs
* [git](https://git-scm.com) -- version control system for your project

### Optional

* [fzf](https://github.com/junegunn/fzf) -- best in class interactive fuzzy finder

### Installation

Currently the only tested way of installing Pytomata is through git submodules,
though a simple git clone should work as well without a doubt.

In order to install Pytomata, type in your zsh-powered terminal:

```zsh
git clone https://github.com/filipgodlewski/pytomata.git

# alternatively, if you are using git submodules in your files
git submodule add https://github.com/filipgodlewski/pytomata.git
```

Secondly, you will have to source Pytomata into your .zshrc file by,
for example, adding:

```zsh
source ~/.local/share/zsh/plugins/pytomata/pytomata.zsh

chpwd() {
    automata
}
# which effectively will run `automata` on every `cd` command
```

### Usage

Pytomata provides the user with couple of commands that can be used straight from the shell:

`aenv` -- Activate pyenv virtual environment of the current project.

`automata` -- Automate virtual environments. Remember to add it into your .zshrc's chpwd() function!

`delenv` -- Delete pyenv virtual environment of the current project.

`denv` -- Deactivate pyenv virtual environment of the current project.

`listenv` -- List all existing pyenv virtual environments that work with pytomata.

`mkenv` -- Create pyenv virtual environment for the current project.

`upenv` -- Reinstall Python version for the current project.

`uppip` -- Upgrade all your outdated pip packages for the current project.

### Development

The Pytomata source code is [hosted on GitHub](https://github.com/filipgodlewski/pytomata).
It is meant to be clean, simple and easily hackable.

#### Contributing

If you wish to contribute, don't hesitate to do that! I am open for proposals.
If you have a great idea that you'd like to merge into Pytomata,
either fork and create a pull request pointing to that repository,
or write an issue.

#### Version History

See [CHANGELOG.md](CHANGELOG.md)

#### License

[The MIT License](LICENSE)
