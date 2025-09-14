# Codebase Summary: Plankton-Fork (UUV Simulator Fork)

The codebase is a fork of the UUV Simulator (Plankton-Fork), which is a ROS-based framework for simulating underwater vehicles in Gazebo. It includes various ROS packages organized into directories, each focusing on specific aspects of simulation, control, sensing, and utilities. Below is a high-level overview of the layout based on the file structure and key components.

## Top-Level Structure
- The root directory contains general files like `README.md`, `LICENSE`, `.gitignore`, and project-specific files such as `swarm_pipeline_uuvs_project.md` (your project plan) and `uuv_mapping.png`.
- It also includes scripts like `convert_all.bash` and directories for packages.
- Additional top-level elements include `tools/` for code checking (e.g., `code_check.sh`, `cpplint.py`) and `user_needs/` with research papers on robotics simulators.

## Core Packages
The codebase follows ROS conventions: each package has `CMakeLists.txt`, `package.xml`, `src/` for code, `launch/` for launch files, `config/` for YAML configs, and `test/` for unit tests. It's designed for modularity, with heavy emphasis on Gazebo plugins for physics (e.g., hydrodynamics) and ROS nodes for control and perception. Your swarm UUV project extends this simulator.

- **plankton** and **plankton_utils**: Core utilities, including time simulation (`globalSimTime.cpp`) and parameter handling (e.g., `test_param_helper.py`, `test_time.py`).

- **uuv_assistants**: Tools for setup and publishing.
  - Launch files: e.g., `message_to_tf.launch`, `publish_footprints.launch`.
  - Scripts: e.g., `create_control_package`, `create_new_robot_model`, `create_thruster_manager_configuration` for generating configurations.
  - Templates: For control, robot models, and thruster managers.

- **uuv_control**: Central for control systems, divided into subpackages.
  - **uuv_auv_control_allocator**: Handles actuator allocation (e.g., thrusters) with messages and scripts.
  - **uuv_control_cascaded_pids**: Implements cascaded PID controllers in Python (e.g., `PIDRegulator.py` provides a basic 1D PID with P, I, D terms, saturation, and integral windup prevention).
  - **uuv_control_msgs**: Message and service definitions for control (e.g., trajectory points).
  - **uuv_control_utils**: Utilities for control tuning and disturbances (configs and scripts).
  - **uuv_thruster_manager**: Manages thruster dynamics, allocation, and testing (configs, services, tests).
  - **uuv_trajectory_control**: Trajectory following with control algorithms (likely integrates PIDs; includes configs and tests).

- **uuv_descriptions**: Robot models and URDF/XACRO files.
  - Launch files: e.g., `upload_rexrov_default.launch` for spawning models.
  - Meshes and robots: e.g., RexROV models with actuators, sensors, and Gazebo integrations.
  - Scripts and tests: For spawning and validating URDFs.

- **uuv_gazebo** and **uuv_gazebo_plugins**: Gazebo integration.
  - Configs: Disturbances and launches for demos (e.g., controller_demos, rexrov_demos).
  - RViz files: For visualization (e.g., `rexrov_default.rviz`).
  - Plugins: Hydrodynamics, buoyancy, thrusters (C++ sources in `src/`, ROS integrations).

- **uuv_gazebo_worlds**: World models and media for underwater environments.
  - Includes shaders like `SimpleWaves.vert` (a GLSL vertex shader for Gerstner wave simulation, combining multiple waves for realistic water surfaces with displacement, normals, and bump mapping).
  - Configs, launches, models, and worlds for simulations.

- **uuv_sensor_plugins**: Sensor simulations (e.g., ROS plugins for IMU, DVL, sonar).

- **uuv_simulator** and **uuv_world_plugins**: Overall simulator integration and world ROS plugins.

- **uuv_teleop**: Teleoperation tools (e.g., joystick control with launches and scripts).

- **uuv_tutorials**: Example tutorials for disturbances, controllers, models, and worlds.

This structure supports extensible underwater simulation, with your project leveraging control and Gazebo components for swarm pipeline inspection.
