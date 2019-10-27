# mirrortask

## object image


* blue channel: boundaries
* green channel: inside object
* alpha channel: blue|green
* height=width
* high resolution (will be downscaled within the app)


## Getting Started

todo:
- save JSON + image locally
- upload to nettskjema
- test max upload size / big trajectories
- recalc line from trajectory

- save autocomplete info in results?
- calc boundary crossings
- project settings
  - use db instead of shared_preferences
  - db entry: [project, key, value] text only
  - store values for read access in Map<String,String>
  - save settings async
