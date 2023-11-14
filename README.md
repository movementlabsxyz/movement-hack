# movemnt-hack
Guide material for Movement Hackathons and generally for beginners looking to start projects.

## Using this repository
This repository can be used as a guide for learning `movement` or as a template for creating a `movement` project.

### As a guide
To use this repository as a guide, visit [hack.movementlabs.xyz](hack.movement.xyz) or server the `mdBook` located in the `/book` directory.

### As a template
To use this repository as a template for setting up a `movement` project, run `cargo generate -a movemntdev/movement-hack`.

When using the containerization features, you may either simply attach to the `movement-dev` devcontainer from VS CODE or run the below to reproduce similar behavior:

```
docker image pull mvlbs/m1
docker run -it -v "$(pwd):/workspace" mvlbs/m1 /bin/bash
```

## Working on this repository
- The easiest way to work on this repository, whether for contributions or your own fork, is to leverage the `devcontainer` [extension](https://code.visualstudio.com/docs/devcontainers/containers) in VsCode and use the `maintainer` container. 
- Within the `maintainer` container, to serve the `mdBook` use call `mdbook serve` from the `book` directory. 
