# ForSyDe Shell

The current project provides a set of scripts to set up the ForSyDe ecosystem for the demonstrator applications and create a shell environment with the necessary commands.

### Dependencies

For the ForSyDe-SystemC projects you need to install [SystemC](http://www.accellera.org/downloads/standards/systemc) manually on your workstation. 

### Installation

Currently the installation script works only on Debian distributions of Linux. On other OS, for the time being you can study `setup.sh` to install manually all dependencies.

To install all dependencies and create the shell simply run from the current folder:

    ./setup.sh

and follow the instructions.

In case you need to update your installation options you can run `setup.sh` again and it will just update the shell, without modifying the existing options.

If you want to perform the installation in non-interactive mode, you can run `setup.sh` with the following parameters:

If you need to reset the shell (without reinstalling the tools) type

    ./setup.sh --no-dialog             # non-interactive. Updates shell if one exists already
    ./setup.sh --no-dialog --reset     # non-interactive. Resets shell if one exists already
    ./setup.sh --no-dialog --uninstall # non-interactive. Uninstalls everything.

In non-interactive mode the installation configuration must be set in `setup.conf`

### Running the shell

Open the newly created shell by running

    ./forsyde-shell
    
which starts in the working directory `models`. The welcome screen contains enough information for getting started. All in-built commands come with usage manuals which can be printed by calling `help-<command>` inside the shell.

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

A project may be anywhere accessible on the file system, although it is recommended to be somewhere under `workspace`. In order to minimize the overhead of setting or passing parameters around or dealing with complex scripts, ForSyDe-Shell operates on the following conventional structure:
 * `application-name/` : important since it will appear in several places
     - `.project` : dummy file that tells the shell that this is a project
     - `Makefile` : created with `generate-makefile` and then modified accordingly 
     - `src/` : here are the source files. All `.c` and `.cpp` files need to be here (no subfolders allowed)-
     - `files/` : miscellaneous files, such as inputs or configurations.
     - `ir/` : is where the ForSyDe-IR model is expected to be found by default by most of the tools. This means that you must make sure that ForSyDe introspection dumps XML files there.
     - other generated folders, depending on the tools ran. 

#### Environment variables:

In order to know what environment variables are available and their values, one can check the generated shell source script in `shell/forsyde-shell.sh`
