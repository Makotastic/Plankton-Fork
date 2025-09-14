# Gazebo Spawn Issue Resolution

## Problem Summary

The main issues preventing successful model spawning in Gazebo were:

1. **Gazebo ROS Plugin Loading Failure**: The Gazebo ROS factory plugin (`libgazebo_ros_factory.so`) was not loading properly, preventing the `/gazebo/spawn_entity` service from being available.

2. **Environment Configuration**: The `GAZEBO_PLUGIN_PATH` environment variable was not correctly set to include both standard ROS plugins and custom UUV plugins.

3. **Material Path Resolution**: Gazebo was unable to find material files due to incorrect path resolution. The SDF files use relative paths like `file://media/materials/scripts/water.material` but Gazebo couldn't resolve these paths.

4. **Timing Issues**: The robot state publisher and parameter server needed time to initialize before the robot description was available for spawning.

## Solutions Implemented

### 1. Environment Variable Fixes
- **GAZEBO_PLUGIN_PATH**: Set to include:
  - `/opt/ros/humble/lib` (standard ROS plugins)
  - `/uuv_ws/install/uuv_gazebo_ros_plugins/lib` (UUV custom plugins)
  - `/usr/lib/x86_64-linux-gnu/gazebo-11/plugins` (system Gazebo plugins)

- **GAZEBO_RESOURCE_PATH**: Set to include `/tmp` where a symbolic link points to the actual media files

### 2. Material Path Resolution
Created a symbolic link to make materials accessible:
```bash
ln -sf /uuv_ws/src/Plankton-Fork/uuv_gazebo_worlds/media /tmp/media
```

This allows Gazebo to find materials at the expected `file://media/...` paths.

### 3. Alternative Spawning Method
Instead of relying on the broken ROS spawn service, used Gazebo's native command:
```bash
gz model -m rexrov -f /tmp/rexrov.urdf
```

### 4. Timing Management
Added proper delays to ensure:
- Gazebo is fully started before attempting to spawn
- Robot state publisher has populated the parameter server
- Robot description is available before spawning

## Current Launch Methods

### Method 1: Python Launch File
```bash
ros2 launch rexrov_simulation.launch.py
```

### Method 2: Simple Bash Script
```bash
./start_rexrov_simple.sh
```

### Method 3: Manual Steps
```bash
# Terminal 1 - Start Gazebo
export GAZEBO_PLUGIN_PATH=/opt/ros/humble/lib:/uuv_ws/install/uuv_gazebo_ros_plugins/lib:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins
export GAZEBO_MODEL_PATH=/uuv_ws/install/uuv_gazebo_worlds/share/uuv_gazebo_worlds/models
export GAZEBO_RESOURCE_PATH=/usr/share/gazebo-11:/tmp
gazebo --verbose /uuv_ws/install/uuv_gazebo_worlds/share/uuv_gazebo_worlds/worlds/empty_underwater.world

# Terminal 2 - Spawn RexROV
ros2 launch uuv_descriptions upload_rexrov_default.launch.py
sleep 3
ros2 param get /rexrov/robot_state_publisher robot_description | sed 's/^String value is: //' > /tmp/rexrov.urdf
gz model -m rexrov -f /tmp/rexrov.urdf
```

## Current Status

- ✅ RexROV model successfully spawns in Gazebo
- ✅ All ROS topics created properly (sensors, thrusters, navigation)
- ✅ Material warnings resolved through symbolic link approach
- ✅ Simulation is fully functional for control system development

The solution bypasses the problematic ROS spawn service while maintaining full functionality for the UUV control system development.
