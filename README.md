# bb-superbuild

This is a meta repository (so-called "superbuild") that uses [CMake](https://cmake.org/) and [YCM](https://github.com/robotology/ycm) to automatically
download and compile software developed in the baesian balancer GitHub organization. This superbuild is based on the [robotology-superbuild](https://github.com/robotology/robotology-superbuild)

[CMake](https://cmake.org/) is an open-source, cross-platform family of tools designed to build, test and package software.
A [YCM Superbuild](http://robotology.github.io/ycm/gh-pages/git-master/index.html#superbuild) is a CMake project whose only goal is to download and build several other projects.
If you are familiar with ROS, it is something similar to [catkin](http://wiki.ros.org/catkin/workspaces) or [colcon workspace](https://colcon.readthedocs.io/en/released/user/quick-start.html), but using pure CMake for portability reasons and for customizing the build via CMake options.

<!-- Furthermore, the `robotology-superbuild` also contains some infrastructure to build **binaries** of the contained projects for some platforms.
You can read more about the superbuild concept in [YCM documentation](http://robotology.github.io/ycm/gh-pages/latest/index.html) or in the [related IRC paper](http://lornat75.github.io/papers/2018/domenichelli-irc.pdf). -->





# Dependencies

```
sudo apt-get install freeglut3-dev
sudo apt-get install libedit-dev
sudo apt-get install -y libxmu-dev
sudo apt-get install libncurses-dev
sudo apt install libcereal-dev

sudo apt-add-repository universe
sudo apt-get update
sudo apt-get install doxygen
sudo apt-get install python3-sphinx
```
```
pip3 install breathe
```

### iDyntree Depends. Needed for scenario build option

```
sudo apt-get install build-essential libeigen3-dev libxml2-dev coinor-libipopt-dev libassimp-dev libirrlicht-dev
```

# Installation

```
cd <repo location>
git clone git@github.com:Baesian-Balancer/bb-superbuild.git
cd bb-superbuild
cmake -S . -B build <CMAKE_ARGS>
cmake --build build
```

`<CMAKE_ARGS>` can define the options you want for the build. Available options
```
option(BAESIANBALANCER_ENABLE_CORE "Enable compilation of core software libraries." TRUE)
option(BAESIANBALANCER_ENABLE_MONOPODSDK "Enable compilation of monopod_sdk." FALSE)
option(BAESIANBALANCER_ENABLE_SCENARIO "Enable compilation of scenario." FALSE)
```
By default CORE is always installed. To set the other options to install as well replace `<CMAKE_ARGS>` with
```
cmake -S . -B build -DBAESIANBALANCER_ENABLE_MONOPODSDK:BOOL=TRUE -DBAESIANBALANCER_ENABLE_SCENARIO:BOOL=TRUE
```
Include which ever options you want.

## Required for gym-ignition. Allowing pip to link python packages installed in super build.

Navigate to the `<repo location>/bb-superbuild/src ` folder. Run the following commands in order. **Do not worry about red error text :) it is only linking cached packages**

```
pip install -e iDyntree --prefix=~/.local
pip install -e gym-ignition/scenario --prefix=~/.local

mv iDyntree ../build/install/lib/python3/dist-packages
mv gym-ignition/scenario ../build/install/lib/python3.8/site-packages
```
**Becareful you might want to double check the destination to make sure it is where the package is installed :) you could also instead just copy them to `~/.local/lib/python3.8/site-packages`**

Now that pip knows about the packages you can install the nightly version of `gym-ignition` with `pip install --pre gym-ignition`.
