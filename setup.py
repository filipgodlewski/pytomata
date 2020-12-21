import os
from setuptools import setup, find_packages


def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()


setup(
    name="pytomata",
    version="0.2.0",
    author="Filip Godlewski",
    author_email="filip.godlewski@outlook.com",
    description="Automated virtual environment management made dead-simple.",
    long_description=read("README.md"),
    license="MIT",
    keywords="virtualenv venv",
    url="",
    packages=find_packages(),
    include_package_data=True,
    install_requires=["Click"],
    entry_points={"console_scripts": ["pytomata=src.pytomata:cli"]},
    classifiers=["Topic :: Software Development :: Build Tools"],
)
