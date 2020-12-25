Lang-install
==========

Install and easily manage your prefered languages (Ruby, Golang...) and versions using Docker.  
You can also install programs like Postgres as long as they have a docker image.


## Requirements
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Docker](https://docs.docker.com/get-docker/)


## Installation

```bash
  # You can install it wherever you want, just cd the dir where you want to install it
  # In this case we'll install it in $HOME
  cd
  git clone git@bitbucket.org:vinz3872/lang-install.git
  cd lang-install && ./install.sh
```

## Configuration
You can add custom env variables in **config/.config** with the format [snake case env name]  [path]  
e.g. *gem_path $HOME/.gems*

If a language / program doesn't work with the generic install (or need specific build configuration), you can overwrite it in the **languages** folder  
e.g. *node alpine who create a default 'node' user*

## Usage

```console
$ lang_install help
USAGE:

lang_install help
    Show usage
lang_install list
    List installed languages
lang_install add [OPTIONS] LANGUAGE [VERSION]
    Install a new language / version 
lang_install remove [OPTIONS] LANGUAGE [VERSION]
    Remove an installed language

OPTIONS
  -a, --alpine
        Use alpine images
  -b <BINARY_NAME>, --binary <BINARY_NAME>
        Specify the main binary name. Default is equal to the language's name, can be configured in config/.config_aliases
  -d, --debug
      Debug mode. Show what binaries whould be installed
  -v, --verbose
      Show more logs
```

### Examples
```bash
# Install Ruby 2.5.1 and use it by default
lang_install add ruby 2.5.1
# Install Ruby latest and use it by default
lang_install add ruby

# List installed languages
lang_install list

# Remove Ruby 2.5.1
lang_install remove ruby 2.5.1
```

## Tested languages / programs
- Golang *(normal / alpine)*
- Node *(normal / alpine)*
- Postgres *(normal / alpine)*
- Python *(normal / alpine)*
- Ruby *(normal / alpine)*
