#!/bin/zsh

PYTOMATA_FILE="$(pyenv root)/pytomata"

__activate_pytomata_venv() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    ORIGINAL_PATH="$PATH"
    pyenv activate ${dir_path##*/} 2> /dev/null
    PYTOMATA_ON="true"
    export PATH="$VIRTUAL_ENV:$PATH"
    unset dir_path
}

__deactivate_pytomata_venv() {
    pyenv deactivate
    export PATH="$ORIGINAL_PATH"
    unset PYTOMATA_ON
    unset ORIGINAL_PATH
}

__add_dir_path() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    echo "${dir_path##*/}" >> ${PYTOMATA_FILE}
    echo "${dir_path}" >> ${PYTOMATA_FILE}
    unset dir_path
}

__is_git_repo() {
    git_root="$(git rev-parse --show-toplevel 2> /dev/null)"
    [[ ${git_root} ]] && {unset git_root; return 0} || {unset git_root; return 1}
}

__on_venv() {
    [[ $VIRTUAL_ENV ]] && return 0 || return 1
}

__on_pytomata_venv() {
    if [[ ${VIRTUAL_ENV} ]] && [[ ${PYTOMATA_ON} ]]; then
        return 0
    else
        return 1
    fi
}

__pyenv_venv_exists() {
    virtualenvs=($(pyenv virtualenvs --bare --skip-aliases | cut -d"/" -f3))
    if [[ ${virtualenvs[(Ie)${PWD##*/}]} -ne 0 ]]; then
        unset virtualenvs
        return 0
    else
        unset virtualenvs
        return 1
    fi
}

__remove_pytomata_venv() {
    sed "/$1$/d" $PYTOMATA_FILE > $PYTOMATA_FILE
}

__sort_pytomata_file() {
    if [[ $(cat $PYTOMATA_FILE | wc -l) > 1 ]]; then
        sort -r "$(cat $PYTOMATA_FILE)" > $PYTOMATA_FILE
    fi
}

__update_pip_packages() {
    pip list --outdated --format freeze | sed 's/==.*//' | xargs -n1 pip -q install --use-feature=2020-resolver -U
}

__pytomata_venv_exists() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    full_grep="$(grep -x "${dir_path}" ${PYTOMATA_FILE} 2> /dev/null)"
    unset dir_path
    if [[ ${full_grep} ]]; then
        unset full_grep
        return 0
    else
        unset full_grep
        return 1
    fi
}

_check_pytomata_setup() {
    __is_git_repo || return 1
    __on_venv && return 1
    __pyenv_venv_exists && return 1
    __pytomata_venv_exists && return 1
    __on_pytomata_venv && return 1
    return 0
}

_activate_pytomata_venv() {
    __is_git_repo || return 1
    __pytomata_venv_exists || return 1
    __on_pytomata_venv && return 0
    __on_venv && return 1
    __activate_pytomata_venv
}

_deactivate_pytomata_venv() {
    __on_pytomata_venv && __deactivate_pytomata_venv
}

_delete_pytomata_venv() {
    __is_git_repo || return 1
    __pytomata_venv_exists || return 1
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    pyenv virtualenv-delete -f ${dir_path##*/} || return 1
    __remove_pytomata_venv ${dir_path##*/}
    unset dir_path
}

_add_pytomata_venv() {
    # Add pytomata project directory into the pytomata list.
    __is_git_repo || return 1
    __pytomata_venv_exists
    if [[ $? -eq 1 ]]; then
        __add_dir_path
        __sort_pytomata_file
        unset dir_path
        return 0
    else
        unset dir_path
        return 1
    fi
}

_delete_pyenv_venv() {
    __deactivate_pytomata_venv
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    pyenv virtualenv-delete -f ${dir_path##*/}
    unset dir_path
}

_create_pyenv_venv() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    pyenv virtualenv \
        $(pyenv versions --bare --skip-aliases | grep -v "/" | fzf --header="Select python version of your interest.") \
        ${dir_path##*/} $> /dev/null || return 1
    unset dir_path
    __activate_pytomata_venv
}

_update_pip_packages() {
    [[ "$(pip list --outdated)" ]] && __update_pip_packages
}

automata() {
    # Make pyenv virtual environments magical.
    _activate_pytomata_venv || _deactivate_pytomata_venv
}

aenv() {
    # Activate pyenv virtual environment.
    _activate_pytomata_venv || {echo "ERROR: Cannot activate virtual environment"; return 1}
}

denv() {
    # Deactivate pyenv virtual environment.
    #
    # Does not work with non-pyenv virtual environments.
    _deactivate_pytomata_venv || {echo "ERROR: Cannot deactivate virtual environment."; return 1}
}

delenv() {
    # Delete a pyenv virtual environments from the pytomata list.
    _deactivate_pytomata_venv || {echo "ERROR: Cannot deactivate virtual environment."; return 1}
    _delete_pytomata_venv || {echo "ERROR: Cannot delete virtual environment."; return 1}
    echo "INFO: Virtual environment(s) deleted."
}

mkenv() {
    # Create new pyenv virtual environment that will work automatically under pytomata.
    #
    # Takes the current git project's root directory as name.
    _check_pytomata_setup || {echo "ERROR: Requirements not fulfilled."; return 1}
    echo "INFO: Creating new pytomata virtual environment."
    echo -n "INPUT: Proceed [Y/n]? "
    read answer; echo
    case $answer in
        [yY]|"") unset answer;;
        *) echo "INFO: Aborting."; unset answer; return 1;;
    esac
    _create_pyenv_venv || return 1
    _add_pytomata_venv
    echo "INFO: Installed new pytomata virtual environment."
    echo "INFO: Upgrading pip and installing wheel."
    pip -q install --upgrade pip setuptools
    pip -q install wheel
    echo "INFO: Finished pytomata virtual environment setup."
}

uppip() {
    # Update all outdated pip packages from the target pyenv virtual environment.
    #
    # Applies only to the pyenv virtual environments from the pytomata list.
    _activate_pytomata_venv || {echo "ERROR: Cannot activate virtual environment."; return 1}
    _update_pip_packages || {echo "INFO: Every pip package is up to date."; return 0}
}

upenv() {
    # Upgrade Python version of the target pytomata virtual environment from the pytomata list.
    #
    # Upgrade is a brachylogy. User can actually downgrade as well.
    # After the upgrade/downgrade it check if any packages are outdated, and
    # updates them if the user wants to.
    _activate_pytomata_venv || {echo "ERROR: Cannot activate virtual environment."; return 1}
    echo "INFO: Upgrading Python version of the current pyenv virtual environment."
    pip list --format freeze > TMP_pip_list
    _delete_pyenv_venv
    _create_pyenv_venv || {echo "ERROR: Operation aborted."; return 1}
    pip -q install -r TMP_pip_list
    rm TMP_pip_list
    echo "INFO: Finished upgrading the Python version."
}
