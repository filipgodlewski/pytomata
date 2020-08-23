#!/bin/zsh

addenv() {
    cat .env 2>/dev/null | grep -qw "HAS_PYENV_VIRTUALENV=\'true\'" || echo "HAS_PYENV_VIRTUALENV='true'" >> .env
}

aenv() {
    original_path="$PATH"
    if [ -z "$1" ]; then
        VENV=$(pyenv virtualenvs --bare --skip-aliases | cut -d"/" -f3 | fzf)
        [ ! -z $VENV ] && pyenv activate $VENV || return 1
    else
        pyenv activate $1
    fi
    export PATH="$VIRTUAL_ENV:$PATH"
}

delenv() {
    on_venv="A virtual env is active, please deactivate it first. Aborting."

    [ ! -z $(echo -n $VIRTUAL_ENV) ] && echo $on_venv && return 1
    venv=( $(pyenv virtualenvs --skip-aliases | cut -d" " -f3 | fzf -m) )
    for item in $venv; do
        if [ ! -z $item ]; then
            pyenv virtualenv-delete -f $item
            echo "Deleted venv: $item"
        fi
    done
    return 0
}

denv() {
    pyenv deactivate 2> /dev/null && export PATH="$original_path"
}

mkenv() {
    confirm="$1"
    has_venv="A virtual env for this project already exists. Aborting."
    on_venv="A virtual env is active, please deactivate it first. Aborting."

    virtualenvs=($(pyenv virtualenvs --bare --skip-aliases | cut -d"/" -f3))
    [ ${virtualenvs[(Ie)${PWD##*/}]} -ne 0 ] && echo $has_venv && return 1
    [ ! -z $(echo -n $VIRTUAL_ENV) ] && echo $on_venv && return 1
    echo "Creating new virtual environment.\n"
    case $confirm in
        -y) ;;
        *)
            echo "You are currently in the directory:"
            echo $PWD
            echo -n "Proceed [Y/n]? "
            read answer; echo
            case $answer in
                [yY]|"") ;;
                *) echo "Aborting."; return 1;;
            esac
            ;;
    esac
    available_versions=($(pyenv versions --bare --skip-aliases | grep -v "/"))
    if [ $#available_versions -lt 1 ]; then
        echo "No Python versions? Aborting."
        return 1
    elif [ $#available_versions -eq 1 ]; then
        answer=1
    else
        echo "The list of available Python versions:"
        for version in ${available_versions}; do
            printf "%s\t" "[${COLOR_MAGENTA}${available_versions[(i)$version]}${COLOR_NORMAL}]"
            echo $version
        done
        echo -n "Which version would you like to choose [index]? "
        read answer; echo
    fi
    if [ -z $answer ] || [ $answer -lt 1 ] || [ $answer -gt $#available_versions ]; then
        echo "Wrong index provided. Aborting."
        return 1
    fi
    echo "Creating and activating venv called: ${PWD##*/}"
    pyenv virtualenv ${available_versions[$answer]} ${PWD##*/} &> /dev/null
    aenv ${PWD##*/}
    echo "Upgrading pip and installing wheel"
    pip -q install --upgrade pip setuptools; pip -q install wheel
    addenv
}

uppip() {
    not_venv="You must first activate the target venv. Aborting."

    [ -z $(echo -n $VIRTUAL_ENV) ] && echo $not_venv && return 1
    pip list --outdated --format freeze | sed 's/==.*//' | xargs -n1 pip -q install --use-feature=2020-resolver -U
}

upenv() {
    not_venv="You must first activate the target venv. Aborting."
    cannot_upgrade="Cannot upgrade. $current_version is the only Python version installed. Aborting."

    [ -z $(echo -n $VIRTUAL_ENV) ] && echo $not_venv && return 1
    current_venv=$(pyenv version-name)
    current_version=$(pyenv virtualenv-prefix | rev | cut -d"/" -f1 | rev)
    available_versions=($(pyenv versions --bare --skip-aliases | grep -v "/"))
    available_versions[(r)$current_version]=()
    echo -n "Current venv version: "; echo $current_version
    if [ $#available_versions -eq 0 ]; then
        echo $cannot_upgrade
        return 1
    elif [ $#available_versions -eq 1 ]; then
        answer=1
        echo -n "Will upgrade to Python $available_versions[$answer]. Proceed [Y/n]? "
        read response; echo
        case $response in
            [yY]|"") ;;
            *) echo "Aborting."; return 1;;
        esac
    else
        echo "The list of available python versions:"
        for version in ${available_versions}; do
            printf "%s\t" "[${COLOR_MAGENTA}${available_versions[(i)$version]}${COLOR_NORMAL}]"
            echo $version
        done
        echo -n "Which version would you like to choose [index]? "
        read answer; echo
    fi
    if [ -z $answer ] || [ $answer -lt 1 ] || [ $answer -gt $#available_versions ]; then
        echo "Wrong index provided. Aborting."
        return 1
    fi
    pip list --format freeze > TMP_pip_list
    denv
    pyenv virtualenv-delete -f $current_venv
    echo "Upgrading venv to Python $available_versions[$answer]. Might take a while."
    pyenv virtualenv ${available_versions[$answer]} $current_venv $> /dev/null
    aenv $current_venv
    pip -q install -r TMP_pip_list
    rm TMP_pip_list
    if [ ! -z "$(pip list --outdated)" ]; then
        echo "Some of the packages are outdated."
        echo -n "Would you like to update all of them [Y/n]? "
        read answer; echo
        case $answer in
            [yY]|"") ;;
            *) echo "Finished."; return 0;;
        esac
        uppip
    fi
}

automata() {
    denv
    cat .env 2>/dev/null | grep -qw "HAS_PYENV_VIRTUALENV=\'true\'" || return 0
    find ~/.pyenv/versions -maxdepth 1 -type l | rev | cut -d"/" -f1 | rev | grep -qw "${PWD##*/}" && aenv ${PWD##*/}
    return 0
}
