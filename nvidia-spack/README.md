## Enable BuildKit builds
In order to use the `--mount=ssh` functionality, BuildKit needs to be enabled. Follow the instructions given [here](https://docs.docker.com/develop/develop-images/build_enhancements/#to-enable-buildkit-builds).

## Build
```bash
 docker build -t $(cat TAG) --ssh default ."
 ```
