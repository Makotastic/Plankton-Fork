# RexROV Sensor Suite Documentation

## Overview
The RexROV (Remotely Operated Vehicle) in the UUV Simulator is equipped with a comprehensive sensor suite that enables autonomous navigation, localization, and environmental perception. This document details the sensors available, how they work, and how they contribute to the robot's state estimation.

## Core Sensor Suite

### 1. Inertial Measurement Unit (IMU)
- **Position**: Located at the vehicle's origin (0, 0, 0)
- **Function**: Provides orientation, angular velocity, and linear acceleration data
- **ROS Topic**: `/imu/data` (sensor_msgs/Imu)
- **Key Data**: Orientation (quaternion), angular velocity, linear acceleration
- **Usage**: Primary source for attitude estimation and orientation tracking

### 2. Pressure Sensor (Depth Sensor)
- **Position**: Located at (-1.32, 0.5, 0.85)
- **Function**: Measures water pressure to calculate depth
- **ROS Topic**: Typically `/pressure` (sensor_msgs/FluidPressure)
- **Depth Calculation**: 
  ```python
  pressure = standardPressure + depth * kPaPerM
  depth = (pressure - standardPressure) / kPaPerM
  ```
  Where:
  - `standardPressure` = 101.325 kPa (atmospheric pressure at sea level)
  - `kPaPerM` = 9.80638 kPa/m (ρ*g where ρ is water density, g is gravity)
- **Usage**: Primary depth measurement for depth control and station keeping

### 3. Doppler Velocity Log (DVL)
- **Position**: Located at (-1.4, 0, -0.312) with 90° pitch rotation
- **Function**: Measures velocity relative to seafloor or water column
- **ROS Topic**: Typically `/dvl` (uuv_sensor_ros_plugins_msgs/DVL)
- **Key Data**: Velocity measurements, bottom tracking, water velocity
- **Usage**: Velocity estimation for dead reckoning and navigation

### 4. Magnetometer
- **Position**: Default position on base link
- **Function**: Measures Earth's magnetic field for heading estimation
- **ROS Topic**: Typically `/magnetic` (sensor_msgs/MagneticField)
- **Usage**: Compass heading when GPS is unavailable underwater

### 5. GPS Receiver
- **Position**: Mounted on base link
- **Function**: Provides global positioning when surfaced
- **ROS Topic**: Typically `/gps` (sensor_msgs/NavSatFix)
- **Usage**: Surface positioning and global reference

### 6. Pose 3D Sensor
- **Function**: Provides comprehensive 6-DOF pose estimation
- **Usage**: Ground truth or processed pose data

### 7. Cameras (Visual Perception)
- **Positions**:
  - Center camera: (1.15, 0, 0.4) with 34.4° pitch
  - Right camera: (1.15, -0.63, 0.4) with 34.4° pitch + 22.9° yaw
  - Left camera: (1.15, 0.63, 0.4) with 34.4° pitch - 22.9° yaw
- **Function**: Visual perception and inspection
- **ROS Topics**: Various image topics
- **Usage**: Pipeline inspection, obstacle avoidance, visual navigation

### 8. Forward Multibeam Sonar (Optional)
- **Available in**: RexROV Sonar variant (`rexrov_sonar.xacro`)
- **Position**: Located at (1.4, 0, 0.65) at the front
- **Model**: M450-130 multibeam sonar
- **Function**: Forward-looking sonar for obstacle detection and mapping
- **Capabilities**:
  - Depth imaging
  - Surface normal computation
  - Multibeam sonar imaging
  - Raw and processed sonar data
  - Signal processing with SNR calculation, transmission loss modeling
- **ROS Topics**:
  - `/points` - Point cloud data
  - `/depth/image_raw` - Depth images
  - Various sonar image topics for different processing stages

## How the Robot Knows Its Position and Orientation

### State Estimation Approach
The RexROV simulation uses a **ground truth-based approach** for state estimation:

1. **Primary Source**: Gazebo simulation provides ground truth odometry data
2. **ROS Topic**: `/odom` (nav_msgs/Odometry) contains:
   - Position and orientation in world frame
   - Linear and angular velocity in world frame
3. **Controller Usage**: All controllers subscribe to `/odom` and use this as their state input

### No Built-in EKF
**Important**: The basic UUV simulator does **not** include an Extended Kalman Filter (EKF) or sensor fusion algorithm. The system relies on:

- Simulation ground truth data from Gazebo
- Individual sensor readings for specific applications
- The assumption that sensor data is perfect (in simulation)

### Planned EKF Integration
According to the project documentation, the swarm pipeline project plans to integrate:
- `robot_localization` package for EKF-based sensor fusion
- IMU-DVL-pressure sensor fusion for improved state estimation
- Cartographer for SLAM capabilities

## Depth Sensing and Seafloor Detection

### Depth Sensing Mechanism
The robot knows its depth through the pressure sensor using hydrostatic principles:

```python
# In SubseaPressureROSPlugin.cpp
depth = std::abs(pos.Z())  # Get Z coordinate from world pose
pressure = standardPressure + depth * kPaPerM
```

Where:
- `pos.Z()` is the Z-coordinate in Gazebo's ENU frame (negative underwater)
- `standardPressure` = 101.325 kPa (sea level atmospheric pressure)
- `kPaPerM` = 9.80638 kPa/m (approximately ρ*g)

The depth can be estimated from pressure measurements:
```python
inferredDepth = (pressure - standardPressure) / kPaPerM
```

### Pressure Sensor Limits
- **Measurement Range**: 30,000 kPa (configured in pressure sensor)
- **Maximum Depth**: Approximately 3,050 meters (calculated from pressure range)
- **Saturation**: Sensor output saturates at maximum range

### Seafloor Detection (DVL)
The robot knows where the seafloor is using its Doppler Velocity Log (DVL):

1. **Four Acoustic Beams**: The DVL uses 4 downward-facing acoustic beams
2. **Range Measurement**: Each beam measures distance to seafloor
3. **Altitude Calculation**: Average of all 4 beam ranges gives altitude above seafloor
   ```python
   altitude = 0.25 * (beam0_range + beam1_range + beam2_range + beam3_range)
   ```
4. **Range Limits**:
   - Minimum range: 0.55 meters (cannot detect seafloor closer than this)
   - Maximum range: Approximately 100-200 meters (typical sonar range)
   - Out-of-range detection when beams can't detect bottom

### Depth Safety Considerations
The current implementation does **not** include:
- Automatic depth limiting or crush depth protection
- Depth-based safety controllers
- Maximum operating depth enforcement

Depth safety must be implemented at the mission planning or controller level by:
- Setting waypoint depth limits
- Implementing depth saturation in control algorithms
- Adding safety checks in autonomous behaviors


## Front-Facing Perception

### Visual Perception
- **Three cameras** provide stereo vision capabilities
- Positioned at the front for forward-looking inspection
- Used for pipeline inspection and visual navigation

### Sonar Perception (Optional)
- **Forward multibeam sonar** provides active acoustic perception
- Capable of seeing in turbid water where cameras fail
- Signal processing includes:
  - Speckle noise application
  - Smoothing filters
  - Median filtering
  - SNR calculation with transmission loss modeling

## Sensor Data Processing

### ROS Topics Structure
All sensor topics are typically namespaced under the vehicle name:
- `/rexrov/odom` - Primary odometry data
- `/rexrov/imu/data` - IMU data
- `/rexrov/pressure` - Depth/pressure data
- `/rexrov/dvl` - Velocity data
- `/rexrov/camera/image_raw` - Camera images

### Controller Integration
Controllers like the PID controller:
1. Subscribe to `/odom` for state information
2. Use vehicle model to transform data to body frame
3. Calculate control signals based on error between reference and current state
4. Publish control commands to thruster manager

## Usage in Autonomous Operations

### Navigation Stack
1. **Depth Control**: Pressure sensor → PID controller → Thruster commands
2. **Heading Control**: IMU/magnetometer → PID controller → Thruster commands
3. **Position Control**: Odometry/GPS → Trajectory controller → Waypoint following
4. **Obstacle Avoidance**: Sonar/cameras → Perception algorithms → Path planning

### Swarm Project Integration
For the swarm pipeline inspection project, the sensor suite will be enhanced with:
- Decentralized sensor fusion across multiple vehicles
- Shared map data using acoustic communication simulation
- CNN-based anomaly detection on sonar imagery
- Consensus algorithms for coordinated exploration

## Configuration Files

### Sensor Configuration
- **Default sensors**: Defined in `uuv_descriptions/urdf/rexrov_sensors.xacro`
- **Sonar variant**: Defined in `uuv_descriptions/robots/rexrov_sonar.xacro`
- **Sensor plugins**: Implemented in `uuv_sensor_plugins/uuv_sensor_ros_plugins/src/`

### Controller Configuration
- PID parameters in various YAML files in `rexrov_control/config/`
- Thruster configuration in `rexrov_control/config/thruster_manager.yaml`

## Limitations and Considerations

1. **Simulation vs Reality**: The simulator provides perfect sensor data; real-world systems would need robust sensor fusion
2. **No Built-in EKF**: Must be added externally using `robot_localization` or similar packages
3. **Water Column Effects**: Current implementation doesn't simulate complex underwater acoustic propagation
4. **Sensor Noise**: Configurable but typically minimal in default simulations

## Future Enhancements

1. **Integrated EKF**: Add `robot_localization` for proper sensor fusion
2. **Acoustic Modeling**: Improve sonar simulation with realistic propagation models
3. **Sensor Fault Simulation**: Add capability to simulate sensor failures
4. **Multi-vehicle Fusion**: Implement decentralized sensor fusion for swarm operations

This sensor suite provides a comprehensive foundation for underwater autonomous operations, with particular strength in the simulation environment where ground truth data is readily available.
