# ForSyDe Shell

The current project provides a set of scripts to set up the ForSyDe ecosystem for the demonstrator applications and create a shell environment with the necessary commands.

### Installation

Currently the installation script works on :
 * modern Debian distributions of Linux (tested with Ubuntu 14.04, Ubuntu 16.04). Dependencies are installed with [APT](https://wiki.debian.org/Apt).
 * OS X ( tested with 10.11 El Capitan). Dependencies are installed with [MacPorts](https://www.macports.org).
 
On other OS, for the time being you can study `setup.sh` to install manually all dependencies.

To install all dependencies and create the shell simply run from the current folder:

    ./setup.sh

and follow the instructions.

If you want to perform the installation in non-interactive mode, you can run `setup.sh` with the following parameters:

    ./setup.sh --no-dialog             # non-interactive. Updates shell if one exists already
    ./setup.sh --no-dialog --reset     # non-interactive. Resets shell if one exists already
    ./setup.sh --no-dialog --uninstall # non-interactive. Uninstalls everything.

In non-interactive mode the installation configuration must be set in `setup.conf`

### Running the shell

Open the newly created shell by running

    ./forsyde-shell
    
which starts in the working directory `workspace` (if created). The welcome screen contains enough information to get started, as well as the two key commands:

    list-commands    # lists built-in or useful commands
    help-<command>   # prints the usage manual for <command>

**OBS**: we recommend studying the available commands by typing `list-commands` before starting to use the shell.


### Development inside the shell

After setting up the ForSyDe-Shell a lot of help information is displayed accordingly, either in the welcome screen or by calling the `list-commands` or `help-<command>` functions. But there are a few more tricks that a developer has to know in order to use or extend the shell.

#### Directory structure

A fully set up shell has the following structure:
  * `setup.sh` is the setup script. It takes care of acquiring and putting everything to its place.
  * `forsyde-shell` is the generated executable that opens a new shell window
  * `shell/` contains everything needed for this to run and comes with the repository. Here reside mainly bash scripts (e.g. defining shell functions), makefile definitions, file templates and configuration files.
  * `libs/` In case one has chosen to, libraries such as ForSyDe-SystemC, ForSyDe-Shallow or SDF3 will be installed here.
  * `tools/` As well, here are placed tools in form of binaries or source code. For non-binary distributions the setup should take care of installing dependent libraries, parsers, compilers or execution environments.
  * `workspace/` here is the workspace for ForSyDe projects. Usually forsyde-shell starts from here as `pwd`.

#### ForSyDe-SystemC project structure

A project may be anywhere accessible on the file system, although it is recommended to be somewhere under `workspace`. In order to minimize the overhead of setting or passing parameters around or dealing with complex scripts, ForSyDe-Shell operates on the following conventional project structure: 

    application-name/ # Important since it will appear in several places
    ├── .project      # Dummy file that tells the shell that this is a project
    ├── Makefile      # Created with `generate-makefile` and then modified accordingly 
    ├── src/          # Source files. All `.c` and `.cpp` files need to be here (no 
    │   ├── *.c *.cpp # subfolders allowed)
    │   └── *.h *.hpp #
    ├── files/        # Miscellaneous files, such as inputs or configurations.
    │   └── *         # 
    ├── xml/          # Here is where tools expect the ForSyDe-XML intermediate 
    │   ├── *.xml     # representation to be found. You must make sure that ForSyDe
    │   └── *.dtd     # introspection dumps XML files *HERE*.
    └── *             # Other generated folders, depending on the tools ran. 

A project structure can be created issuing the commands:

    mkdir <application-name>
    cd <application-name>
    init-sysc-project

#### Environment variables:

In order to know what environment variables are available and their values, one can check the generated shell source scripts:
 * `shell/forsyde-shell.sh` : main runner. Invokes a new shell that includes the proper environment variables and built-in commands, as chosen during setup.
 * `shell/shell.conf` : contains paths and other environment variables.

### Dependencies

The setup utility should take care of all dependencies for your OS according to the setup options. In case something fails to install, try to follow the terminal messages, install that particular dependency manually and retry the setup.

You can check OS-specific dependencies by studying the scripts in `shell/setup/` (e.g. `debian_setup_utils.sh`, `osx_setup_utils.sh`).
