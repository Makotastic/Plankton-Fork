# Swarm Pipeline-Inspection UUVs

## Quick Start

1. **Start the development environment:**
   ```bash
   # Using Docker Compose (recommended)
   docker-compose up -d uuv-dev
   docker-compose exec uuv-dev bash
   
   # Or using VS Code Dev Container
   # Open folder in VS Code and select "Reopen in Container"
   ```

2. **Test UUV simulation:**
   ```bash
   # Inside container
   ros2 launch uuv_gazebo start_pid_demo_with_teleop.launch
   ```

3. **Run swarm demo (when implemented):**
   ```bash
   ros2 launch launch/swarm_demo.launch.py num_robots:=3
   ```

## Project Structure

- `src/` - ROS 2 packages
  - `swarm_core/` - Core swarm coordination
  - `perception/` - Sonar processing and anomaly detection
  - `control/` - UUV control systems
  - `coordination/` - Multi-agent coordination
- `config/` - Configuration files
- `launch/` - Launch files
- `data/` - Models, datasets, logs
- `docs/` - Documentation

## Development Workflow

1. Build workspace: `colcon build --symlink-install`
2. Source setup: `source install/setup.bash`
3. Run tests: `colcon test`
4. Launch simulation: See launch files in `launch/`

## Key Features

- ✅ Dockerized development environment
- ✅ ROS 2 Humble + Plankton UUV simulator
- 🚧 Frontier-based exploration (Week 4-5)
- 🚧 Consensus-based workload balancing (Week 8)
- 🚧 CNN-based anomaly detection (Week 11)
- 🚧 Multi-UUV SLAM and mapping (Week 9)

For more details, see the project specification document.
