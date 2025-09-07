#!/bin/bash
# setup_uuv_project.sh - Quick setup script for UUV Swarm Pipeline Inspection

set -e

echo "🤖 Setting up UUV Swarm Pipeline Inspection Project"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create project structure
echo -e "${BLUE}📁 Creating project structure...${NC}"
mkdir -p src/{swarm_core,perception,control,coordination}
mkdir -p config/{robots,gazebo,nav2}
mkdir -p launch
mkdir -p data/{models,datasets,logs}
mkdir -p docs
mkdir -p scripts

# Create basic package structure for swarm_core
echo -e "${BLUE}📦 Creating ROS 2 package templates...${NC}"
cat > src/swarm_core/package.xml << 'EOF'
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>swarm_core</name>
  <version>0.1.0</version>
  <description>Core swarm coordination package for UUV pipeline inspection</description>
  <maintainer email="developer@example.com">Developer</maintainer>
  <license>Apache-2.0</license>

  <depend>rclpy</depend>
  <depend>std_msgs</depend>
  <depend>geometry_msgs</depend>
  <depend>nav_msgs</depend>
  <depend>sensor_msgs</depend>
  <depend>tf2_ros</depend>
  
  <test_depend>ament_copyright</test_depend>
  <test_depend>ament_flake8</test_depend>
  <test_depend>ament_pep257</test_depend>
  <test_depend>python3-pytest</test_depend>

  <export>
    <build_type>ament_python</build_type>
  </export>
</package>
EOF

cat > src/swarm_core/setup.py << 'EOF'
from setuptools import setup

package_name = 'swarm_core'

setup(
    name=package_name,
    version='0.1.0',
    packages=[package_name],
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='Developer',
    maintainer_email='developer@example.com',
    description='Core swarm coordination package for UUV pipeline inspection',
    license='Apache-2.0',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'frontier_explorer = swarm_core.frontier_explorer:main',
            'consensus_agent = swarm_core.consensus_agent:main',
        ],
    },
)
EOF

mkdir -p src/swarm_core/{swarm_core,resource,test}
touch src/swarm_core/resource/swarm_core
touch src/swarm_core/swarm_core/__init__.py

# Create basic frontier explorer node
cat > src/swarm_core/swarm_core/frontier_explorer.py << 'EOF'
#!/usr/bin/env python3
"""
Frontier Explorer Agent for UUV Swarm Pipeline Inspection
Implements frontier-based exploration for autonomous mapping
"""

import rclpy
from rclpy.node import Node
from nav_msgs.msg import OccupancyGrid
from geometry_msgs.msg import PoseStamped
import numpy as np

class FrontierExplorer(Node):
    def __init__(self):
        super().__init__('frontier_explorer')
        
        # Publishers
        self.goal_pub = self.create_publisher(PoseStamped, 'move_base_simple/goal', 10)
        
        # Subscribers
        self.map_sub = self.create_subscription(
            OccupancyGrid, 'map', self.map_callback, 10)
        
        self.get_logger().info('Frontier Explorer initialized')
    
    def map_callback(self, msg):
        """Process occupancy grid and find frontiers"""
        # TODO: Implement frontier detection algorithm
        self.get_logger().info('Received map update')

def main(args=None):
    rclpy.init(args=args)
    explorer = FrontierExplorer()
    rclpy.spin(explorer)
    explorer.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
EOF

# Create launch file template
cat > launch/swarm_demo.launch.py << 'EOF'
#!/usr/bin/env python3
"""
Launch file for UUV Swarm Pipeline Inspection Demo
"""

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        DeclareLaunchArgument(
            'num_robots',
            default_value='3',
            description='Number of UUVs in the swarm'
        ),
        
        # Include Gazebo with underwater world
        IncludeLaunchDescription(
            # TODO: Add proper launch file path
        ),
        
        # Spawn frontier explorer nodes
        Node(
            package='swarm_core',
            executable='frontier_explorer',
            name='frontier_explorer_1',
            namespace='uuv1',
            parameters=[{'robot_id': 1}]
        ),
    ])
EOF

# Create configuration files
echo -e "${BLUE}⚙️  Creating configuration files...${NC}"

cat > config/robots/uuv_params.yaml << 'EOF'
# UUV Parameters for Swarm Pipeline Inspection
robot_params:
  max_speed: 2.0  # m/s
  max_depth: 50.0  # meters
  sensor_range: 20.0  # meters
  
control_params:
  depth_pid:
    kp: 1.0
    ki: 0.1
    kd: 0.05
  heading_pid:
    kp: 2.0
    ki: 0.0
    kd: 0.1

exploration_params:
  frontier_threshold: 0.3
  min_frontier_size: 10
  exploration_radius: 15.0
EOF

# Create README
cat > README.md << 'EOF'
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
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# ROS 2
build/
install/
log/
.colcon_ws

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/
*.egg-info/

# IDE
.vscode/settings.json
.idea/

# Data
data/logs/
data/datasets/*.bag
*.bag

# Docker
.docker/

# OS
.DS_Store
Thumbs.db
EOF

# Make scripts executable
chmod +x scripts/*.sh 2>/dev/null || true

echo -e "${GREEN}✅ Project structure created successfully!${NC}"
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Review the generated files and customize as needed"
echo "2. Start the development container:"
echo "   ${BLUE}docker-compose up -d uuv-dev${NC}"
echo "   ${BLUE}docker-compose exec uuv-dev bash${NC}"
echo "3. Test basic UUV simulation:"
echo "   ${BLUE}ros2 launch uuv_gazebo start_pid_demo_with_teleop.launch${NC}"
echo "4. Begin implementation following the 12-week plan"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"
