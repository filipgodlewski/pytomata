import click


@click.group()
def cli():
    """Manage multiple virtual environments with ease."""
    pass


@cli.command()
@click.argument("name")
@click.argument("paths", nargs=-1, required=True,
                type=click.Path(exists=True, file_okay=False))
@click.option(
    "--no-warn",
    "-n",
    is_flag=True,
    help="""
    Do not warn if the chosen virtual environment is already attached to an
    existing project.
    """,
)
def attach(name, paths, no_warn):
    """Attach virtual environment to an existing project.

    Note:
        PATHS is a space separated list to the project roots. This typically
        means the paths to the directories containing `.git` folder.

    Usage:
        pytomata attach "my_project" ~/personal/my_project ~/builds/another

    """
    click.echo(paths)


@cli.command()
@click.argument("name")
@click.confirmation_option(
    prompt=("Are you sure you want to detach from this virtual environment?"),
    default=True,
)
def detach(name):
    """Detach virtual environment from an existing project."""
    pass


@cli.command()
@click.argument("venv")
@click.option("--module", "-m")
def find(venv):
    """Get path to the executables inside the virtual environment."""
    pass


@cli.command()
@click.option(
    "--attached/--not-attached",
    is_flag=True,
    help=("List only virtual environments that are attached to at least "
          "one project or those that are not attached to any project."),
)
def list():
    """List available virtual environments along with associated projects."""
    pass


@cli.command()
@click.option("--upgrade", help="Required if you want to reinitiate venv.")
@click.argument("name")
def make(name, readd):
    """Create new virtual environment or upgrade Python in an existing one."""
    pass


@cli.command()
@click.argument("name")
def remove(name):
    """Remove chosen virtual environment."""
    pass


@cli.command()
@click.argument("name", required=False)
def workon(name=None):
    """Activate chosen virtual environment or let Pytomata choose for you."""
    pass
