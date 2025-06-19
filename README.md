# Emby N150 Fixed Auto Builder

This project automatically builds and publishes a custom Emby image (`rajiska/emby-n150-fixed`) with updated Intel libraries whenever a new Emby release is published. Current Emby images use outdated drivers that do not have support for hardware acceleration on some CPUs such as the N150.  
  
[Reference thread on `emby.media`](https://emby.media/community/index.php?/topic/134698-intel-n150-transcoding-not-working/)

## Using the image

You can build your own docker image or use one that's automatically pushed on my Dockerhub.

### Using a pre-built image

Replace the `emby/embyserver` Docker image you use with `rajiska/emby-n150-fixed`. List of versions available on [DockerHub](https://hub.docker.com/r/rajiska/emby-n150-fixed/tags).

### Building your own image

```bash
git clone https://github.com/RaJiska/emby-n150-fixed
cd emby-n150-fixed
docker build -t emby-n150-fixed --build-arg EMBY_TAG=4.9.1.1 . # Replace with the Emby version you want
# Run this one on your device, it worked if you see a list of supported profiles and entrypoints
docker run --rm -it --device /dev/dri:/dev/dri --entrypoint vainfo emby-n150-fixed
```