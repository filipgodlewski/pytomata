========
Pytomata
========

Automated pyenv-virtualenv management made dead-simple.
-------------------------------------------------------

Pytomata is the automation for pyenv-virtualenv you always wanted.
Written as simple zsh functions, Pytomata's goal is to provide the user
with the simplest solution for the Python venv headache.

If you love Pyenv_ and pyenv-virtualenv_ but don't like the manual work;
If you ever forgot to activate virtualenv and installed pip packages globally;
If you have heard about direnv but think that it is too much for you needs;
If you don't like to bloat your git repository with unnecessary files;
.. _Pyenv: https://github.com/pyenv/pyenv
.. _pyenv-virtualenv: https://github.com/pyenv/pyenv-virtualenv

**Then Pytomata is for you!**

Written in zsh and ready to work on MacOS.

Though Pytomata currently supports only zsh, the goal is to extend
its functionality into other languages as well.
Author is not against Bash or Fish, and plans to implement support
for them as soon as possible.

Installation
^^^^^^^^^^^^

Currently the only tested way of installing Pytomata is through git submodules,
though a simple git clone should work as well without a doubt.

In order to install Pytomata, type in your zsh-powered terminal::

    git clone https://github.com/filipgodlewski/pytomata.git

    # alternatively, if you are using git submodules in your files
    git submodule add https://github.com/filipgodlewski/pytomata.git

Secondly, you will have to source Pytomata into your .zshrc file by,
for example::

    source ~/.local/share/zsh/plugins/pytomata/pytomata.zsh

    chpwd() {
        automata
    }
    # which effectively will run `automata` on every `cd` command

Please note that Pytomata currently requires fzf_. It won't work without it!
.. _fzf: https://github.com/junegunn/fzf

Usage
^^^^^

Pytomata provides user with couple of commands that
can be used straight from the shell.

addenv
    Add or append ``HAS_PYENV_VIRTUALENV='true'`` into .env file
    inside your repository.

aenv
    Activate an existing pyenv-virtualenv from the fuzzy list.
    Provide name, e.g. ``aenv sample_project`` in order to
    skip the fuzzy finding.
    Additionally adds $VIRTUAL_ENV into your $PATH
    which is very useful when working with vim.

automata
    The brain of Pytomata. Remember to add it into your .zshrc's
    chpwd() function!

delenv
    Delete any unwanted pyenv-virtualenvs with the fuzzy finding engine
    which supports multi-choice.

denv
    Deactivate the current pyenv-virtualenv.
    Restore original $PATH (before pyenv-virtualenv was activated).

mkenv
    Create pyenv-virtualenv for your project.
    If ``-y`` option was used, it does not prompt for a confirmation
    whether to proceed.
    Automatically upgrades pip to the newest version and installs wheel.
    Finally, runs ``addenv`` function to setup the automatic workflow.
    Now, whenever you cd into the root of your project, Pytomata will
    automatically activate the virtualenv for you.
    Whenever you step out of the project root, it will be deactivated.

uppip
    Upgrade all your outdated pip packages.

upenv
    Upgrade (or downgrade) your active pyenv-virtualenv.
    This function will actually pip freeze your current pip state into
    a temporary file called ``TMP_pip_list``, delete your old virtualenv
    and setup a new one.
    Finally, if it finds out that some of the packages are outdated,
    it will ask for an update.

Development
^^^^^^^^^^^

The Pytomata source code is `hosted on GitHub`_.
It is meant to be clean, simple and easily hackable.
.. _`hosted on GitHub`: https://github.com/filipgodlewski/pytomata

Contributing
^^^^^^^^^^^^

If you wish to contribute, don't hesitate to do that! I am open for proposals.
If you have a great idea that you'd like to merge into Pytomata,
either fork and create a pull request pointing to that repository, or
write an issue.

Version History
"""""""""""""""

`CHANGELOG.md <CHANGELOG.md>`_

License
"""""""

`The MIT License <LICENSE>`_
