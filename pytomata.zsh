#!/bin/zsh

PYTOMATA_FILE="$(pyenv root)/pytomata"

__activate_pytomata_venv() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    ORIGINAL_PATH="${PATH}"
    pyenv activate ${dir_path##*/} 2> /dev/null
    unset dir_path
    PYTOMATA_ON="true"
    export PATH="${VIRTUAL_ENV}:${PATH}"
    return 0
}

__add_dir_path() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    echo "${dir_path}" >> ${PYTOMATA_FILE}
    unset dir_path
    return 0
}

__create_pytomata_venv() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    chosen_python=$(pyenv versions --bare --skip-aliases | grep -v "/" | fzf --header="Select python version that the virtual environment will be based on.")
    pyenv virtualenv ${chosen_python} ${dir_path##*/} &> /dev/null || return 1
    unset chosen_python
    unset dir_path
    return 0
}

__deactivate_pytomata_venv() {
    pyenv deactivate
    export PATH="${ORIGINAL_PATH}"
    unset PYTOMATA_ON
    unset ORIGINAL_PATH
    return 0
}

__delete_pyenv_venv() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    pyenv virtualenv-delete -f ${dir_path##*/} || return 1
    unset dir_path
    return 0
}

__is_git_repo() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    [[ ${dir_path} ]] && {unset dir_path; return 0} || {unset dir_path; return 1}
}

__list_pytomata_venvs() {
    [[ -f ${PYTOMATA_FILE} ]] || return 1
    while read line; do
        stripped=$(echo "${line}" | rev | cut -d"/" -f1 | rev)
        echo "${stripped} (created within ${line})"
    done < ${PYTOMATA_FILE}
    unset stripped
    unset line
    return 0
}

__on_venv() {
    [[ ${VIRTUAL_ENV} ]] && return 0 || return 1
}

__on_pytomata_venv() {
    ([[ ${VIRTUAL_ENV} ]] && [[ ${PYTOMATA_ON} ]]) && return 0 || return 1
}

__pyenv_venv_exists() {
    virtualenvs=($(pyenv virtualenvs --bare --skip-aliases | cut -d"/" -f3))
    [[ ${virtualenvs[(Ie)${PWD##*/}]} -ne 0 ]] && {unset virtualenvs; return 0} || {unset virtualenvs; return 1}
}

__pytomata_venv_exists() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    pytomata_found="$(grep -x "${dir_path}" ${PYTOMATA_FILE} 2> /dev/null)"
    unset dir_path
    [[ ${pytomata_found} ]] && {unset pytomata_found; return 0} || {unset pytomata_found; return 1}
}

__delete_pytomata_venv() {
    dir_path="$(git rev-parse --show-toplevel 2> /dev/null)"
    result=$(sed "/${dir_path##*/}$/d" ${PYTOMATA_FILE})
    echo ${result} > ${PYTOMATA_FILE}
    unset result
    unset dir_path
    return 0
}

__update_pip_packages() {
    pip list --outdated --format freeze | sed 's/==.*//' | xargs -n1 pip -q install --use-feature=2020-resolver -U
    return 0
}

_activate_pytomata_venv() {
    __is_git_repo || return 1
    __pytomata_venv_exists || return 1
    __on_pytomata_venv && return 0
    __on_venv && return 1
    __activate_pytomata_venv && return 0
}

_add_pytomata_venv() {
    __is_git_repo || return 1
    __pytomata_venv_exists && return 1 || {__add_dir_path; return 0}
}

_check_pytomata_setup() {
    __is_git_repo || return 1
    __on_venv && return 1
    __pyenv_venv_exists && return 1
    __pytomata_venv_exists && return 1
    __on_pytomata_venv && return 1 || return 0
}

_create_pytomata_venv() {
    __create_pytomata_venv
    __activate_pytomata_venv && return 0
}

_deactivate_pytomata_venv() {
    __on_pytomata_venv && {__deactivate_pytomata_venv; return 0} || return 1
}

_delete_pytomata_venv() {
    __is_git_repo || return 1
    __pytomata_venv_exists || return 1
    __delete_pytomata_venv || return 1
    __delete_pyenv_venv && return 0 || return 1
}

_list_pytomata_venvs() {
    __list_pytomata_venvs 2> /dev/null && return 0 || return 1
}

_update_pip_packages() {
    [[ "$(pip list --outdated)" ]] && {__update_pip_packages; return 0} || return 1
}

aenv() {
    # Activate pyenv virtual environment from the pytomata list.
    _activate_pytomata_venv && return 0 || {echo "ERROR: Cannot activate virtual environment."; return 1}
}

automata() {
    # Make pyenv virtual environments magical.
    _deactivate_pytomata_venv
    _activate_pytomata_venv
    return 0
}

delenv() {
    # Delete a pyenv virtual environments from the pytomata list.
    _deactivate_pytomata_venv || {echo "ERROR: Cannot deactivate virtual environment."; return 1}
    _delete_pytomata_venv && return 0 || {echo "ERROR: Cannot delete virtual environment."; return 1}
}

denv() {
    # Deactivate pyenv virtual environment from the pytomata list.
    _deactivate_pytomata_venv && return 0 || {echo "ERROR: Cannot deactivate virtual environment."; return 1}
}

listenv() {
    # List all available virtual environments from the pytomata list along with their git root path.
    _list_pytomata_venvs && return 0 || {echo "ERROR: Pytomata list does not exist."; return 1}
}

mkenv() {
    # Create new pyenv virtual environment and place it on the pytomata list.
    _check_pytomata_setup || {echo "ERROR: Requirements not fulfilled."; return 1}
    echo "INFO: Creating new pytomata virtual environment."
    echo -n "INPUT: Proceed [Y/n]? "
    read answer
    case ${answer} in
        [yY]|"") unset answer;;
        *) echo "INFO: Aborting."; unset answer; return 1;;
    esac
    _create_pytomata_venv || {echo "ERROR: Operation aborted."; return 1}
    _add_pytomata_venv || {echo "ERROR: Adding pytomata venv failed."; return 1}
    echo "INFO: Installed new pytomata virtual environment."
    echo "INFO: Upgrading pip and installing wheel."
    pip -q install --upgrade pip setuptools
    pip -q install wheel
    return 0
}

upenv() {
    # Change Python version of the target pytomata virtual environment from the pytomata list.
    _activate_pytomata_venv || {echo "ERROR: Cannot activate virtual environment."; return 1}
    echo "INFO: Upgrading Python version of the current pyenv virtual environment."
    pip list --format freeze > TMP_pip_list
    _deactivate_pytomata_venv || {echo "ERROR: Cannot deactivate virtual environment."; return 1}
    _delete_pytomata_venv || {echo "ERROR: Cannot delete virtual environment."; return 1}
    _create_pytomata_venv || {echo "ERROR: Operation aborted."; return 1}
    _add_pytomata_venv || {echo "ERROR: Adding pytomata venv failed."; return 1}
    pip -q install -r TMP_pip_list
    rm TMP_pip_list
    return 0
}

uppip() {
    # Update all outdated pip packages from the target pyenv virtual environment from the pytomata list.
    _activate_pytomata_venv || {echo "ERROR: Cannot activate virtual environment."; return 1}
    _update_pip_packages || {echo "INFO: Every pip package is up to date."; return 0}
    return 0
}
