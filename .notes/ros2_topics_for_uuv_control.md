# ROS2 Topics and Services for UUV Control

This document provides an overview of the most important ROS2 topics and services used for controlling underwater vehicles (UUVs) in the Plankton-Fork simulator.

## Core Control Topics

### Odometry and State Estimation
- **`/odom`** - Standard ROS odometry message containing position, orientation, and velocity information
- **`/pose_gt`** - Ground truth pose (often remapped from odom for simulation)
- **`/reference`** - Reference trajectory point for controllers
- **`/error`** - Error information between reference and actual state

### Command Topics
- **`/cmd_pose`** - Desired pose command (PoseStamped message)
- **`/cmd_vel`** - Velocity command (Twist message)
- **`/cmd_accel`** - Acceleration command (Accel message)
- **`/thruster_manager/input`** - Wrench input to thruster allocation system

### Trajectory and Waypoint Topics
- **`/trajectory`** - Complete trajectory information
- **`/waypoints`** - Set of waypoints for navigation
- **`/trajectory_marker`** - Visualization markers for trajectories
- **`/waypoint_markers`** - Visualization markers for waypoints

## Sensor Topics

### Navigation Sensors
- **IMU Data** - Typically published on topics like `/imu/data` (sensor_msgs/Imu)
- **Pressure Sensor** - Depth information (sensor_msgs/FluidPressure)
- **DVL (Doppler Velocity Log)** - Velocity relative to seafloor (uuv_sensor_ros_plugins_msgs/DVL)
- **GPS** - Global positioning (sensor_msgs/NavSatFix)
- **Pose Ground Truth** - `/pose_gt` with optional NED frame (`_ned` suffix)

### Environmental Sensors
- **Camera/Sonar** - Various image and point cloud topics
- **Magnetometer** - Magnetic field measurements (sensor_msgs/MagneticField)
- **Chemical Sensors** - Water quality measurements

## Thruster Management

### Topics
- **`/thruster_manager/input`** - Wrench input for thruster allocation
- **`/thruster_manager/input_stamped`** - Timed wrench input
- Individual thruster control topics (e.g., `/vehicle/thrusters/id_X/input`)

### Services
- **`/thruster_manager/get_thrusters_info`** - Get information about all thrusters
- **`/thruster_manager/get_thruster_curve`** - Get thruster performance curve
- **`/thruster_manager/set_config`** - Configure thruster manager
- **`/thruster_manager/get_config`** - Get current configuration

## Controller Services

### PID Parameter Services
- **`/set_pid_params`** - Set PID controller parameters
- **`/get_pid_params`** - Get current PID parameters
- **`/set_sm_controller_params`** - Set sliding mode controller parameters
- **`/get_sm_controller_params`** - Get sliding mode controller parameters

### Trajectory Services
- **`/start_waypoint_list`** - Start following a list of waypoints
- **`/start_circular_trajectory`** - Start circular trajectory
- **`/start_helical_trajectory`** - Start helical trajectory
- **`/init_waypoints_from_file`** - Load waypoints from file
- **`/go_to`** - Go to specific position
- **`/go_to_incremental`** - Move incrementally
- **`/hold_vehicle`** - Hold current position
- **`/reset_controller`** - Reset controller state

## Mode Control Topics
- **`/automatic_on`** - Boolean topic for automatic control mode
- **`/trajectory_tracking_on`** - Boolean for trajectory tracking mode
- **`/station_keeping_on`** - Boolean for station keeping mode

## Visualization and Debugging
- **`/footprint`** - Vehicle footprint polygon
- **`/label`** - Vehicle label marker
- **`/wrench_perturbation`** - Disturbance wrench visualization
- **`/time_to_target`** - Estimated time to reach target

## Important Message Types
- `nav_msgs/Odometry` - Position, orientation, and velocity
- `geometry_msgs/PoseStamped` - Timed pose
- `geometry_msgs/Twist` - Linear and angular velocity
- `geometry_msgs/Accel` - Linear and angular acceleration
- `geometry_msgs/Wrench` - Force and torque
- `uuv_control_msgs/TrajectoryPoint` - Reference point with pose and velocity
- `uuv_control_msgs/WaypointSet` - Collection of waypoints

## Namespace Convention
Topics are typically namespaced by vehicle name, e.g.:
- `/rexrov/odom`
- `/rexrov/cmd_vel`
- `/rexrov/thruster_manager/input`

## Usage Examples

### Subscribing to Odometry
```python
self.sub_odometry = self.create_subscription(Odometry, 'odom', self.odometry_callback, 10)
```

### Publishing Velocity Commands
```python
self.pub_cmd_vel = self.create_publisher(geometry_msgs.Twist, 'cmd_vel', 10)
```

### Calling Thruster Services
```python
srv_name = '/thruster_manager/get_config'
cli = self.create_client(GetThrusterManagerConfig, srv_name)
```

## Best Practices
1. Always use appropriate QoS settings for real-time control
2. Use namespacing for multi-vehicle scenarios
3. Monitor controller performance through error topics
4. Use visualization topics for debugging
5. Leverage services for dynamic parameter tuning

This overview covers the most critical topics and services for UUV control in the ROS2 ecosystem. Understanding these will help in developing robust control systems for underwater vehicles.
