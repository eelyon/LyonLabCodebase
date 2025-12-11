from setuptools import setup, find_packages

setup(
    name='pyFreeFem',
    packages=find_packages(exclude=("figures","sandbox","version")),
)