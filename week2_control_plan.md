# Week 2 Plan: Coding Control Systems for UUVs

Week 2 of the swarm pipeline UUV project focuses on achieving stable depth and heading PID control for a single UUV, as outlined in the project specification. This builds on the `uuv_control` packages, particularly cascaded PIDs and thruster management. The goal is to implement and tune PID controllers for depth (heave) and heading (yaw), ensuring stability with error ≤0.2m over 60s simulations.

## Prerequisites
- ROS 2 Humble and Gazebo Classic installed (use Docker for consistency as per project plan).
- Workspace built: From root (`/uuv_ws/src/Plankton-Fork`), run `colcon build --symlink-install`.
- Familiarity with ROS launch files, YAML configs, and basic Gazebo simulation.

## Step-by-Step Implementation
1. **Create a Custom Control Package**:
   - Use the script `uuv_assistants/scripts/create_control_package` to generate a new package (e.g., `uuv_swarm_control`).
   - This scaffolds nodes, configs, and launch files based on templates in `uuv_assistants/templates/control/`.
   - Customize for your UUV model (e.g., RexROV).

2. **Configure Thrusters**:
   - Run `uuv_assistants/scripts/create_thruster_manager_configuration` to generate YAML configs in a new dir (e.g., `uuv_swarm_control/config/thrusters.yaml`).
   - Integrate with `uuv_thruster_manager` for allocation. Reference examples in `uuv_thruster_manager/config/`.

3. **Load Robot Model in Gazebo**:
   - Use launch files from `uuv_descriptions/launch/` (e.g., `ros2 launch uuv_descriptions upload_rexrov_default.launch.py`).
   - Ensure sensors (IMU, pressure) and actuators are included via XACRO files (e.g., `rexrov_default.xacro`).

4. **Implement PID Controllers**:
   - Extend the basic PID from `uuv_control/uuv_control_cascaded_pids/src/PID/PIDRegulator.py`.
     - For **depth control**: Regulate z-position using pressure feedback. Set P, I, D gains; handle saturation.
     - For **heading control**: Regulate yaw using IMU data. Decouple surge/heave as needed.
   - Create ROS nodes: One for depth PID, one for heading, publishing to thruster commands.
   - Cascaded setup: Outer loop for position, inner for velocity (reference `uuv_control_cascaded_pids` launches).

5. **Tune Gains**:
   - Start with default configs from `uuv_control/uuv_control_cascaded_pids/config/`.
   - Use `rqt_reconfigure` for dynamic tuning.
   - Simulate holds: Command fixed depth/heading, measure error with ROS topics (e.g., `/odom`).

6. **Test and Validate**:
   - Launch a simple world (e.g., from `uuv_gazebo_worlds/launch/` with waves via `SimpleWaves.vert` for realism).
   - Add disturbances (e.g., currents from `uuv_gazebo/config/disturbances/`).
   - Visualize in RViz (e.g., `uuv_gazebo/rviz/controller_demo.rviz`).
   - Log metrics: Use Python scripts to compute RMSE over 60s runs. Aim for ≤0.2m error.
   - Iterate: Adjust gains, test in loops until stable.

## Risks and Tips
- **Instability**: Cap vehicle speed; use verified models to avoid SLAM drift.
- **Debugging**: Monitor topics like `/cmd_vel`, `/odom`; use `ros2 bag` for recordings.
- **References**: Tutorials in `uuv_tutorials/uuv_tutorial_dp_controller/`; docs in `uuv_control` packages.
- **Next Steps**: Integrate with nav2 for week 3+ autonomy.

This plan sets the foundation for swarm coordination in later weeks.
