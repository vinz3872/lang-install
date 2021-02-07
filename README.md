Lang-install
==========

Install and easily manage your prefered languages (Ruby, Golang...) and versions using Docker.  
You can also install programs like Postgres as long as they have a docker image.


## Requirements
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Docker](https://docs.docker.com/get-docker/)

### External command used (most shells include them by default)
`awk`, `cat`, `chmod`, `cp`, `find`, `grep`, `mkdir`, `realpath`, `rm`, `sed`, `xargs`

## Installation

```bash
  git clone https://github.com/vinz3872/lang-install.git
  cd lang-install && ./install.sh
```

## Configuration
You can add custom env variables, mount points or packages in **config/.config.yaml**

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
        Specify the main binary name. Default is equal to the language's name, can be configured in config/.config.yaml
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
- Golang *(default / alpine)*
- Node *(default / alpine)*
- Postgres *(default / alpine)*
- Python *(default / alpine)*
- Ruby *(default / alpine)*


## Contributing

1. Fork the Project
2. Create a new Branch (`git checkout -b new-branch`)
3. Commit your Changes (`git commit -m 'add feature'`)
4. Push to the Branch (`git push origin new-branch`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
