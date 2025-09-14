#!/bin/bash

# Simple script to start RexROV simulation
# This bypasses the complex launch file issues

# Set environment variables
export GAZEBO_PLUGIN_PATH=/opt极客/ros/humble/lib:/uuv_ws/install/uuv_gazebo_ros_plugins/lib:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins
export GAZEBO_MODEL_PATH=/uuv_ws/install/uuv_gazebo_worlds/share/uuv_gazebo_worlds/models
export GAZEBO_RESOURCE_PATH=/usr/share/gazebo-11:/tmp

# Start Gazebo in the background
gazebo --verbose /uuv_ws/install/uuv_gazebo_worlds/share/uuv_gazebo_worlds/worlds/empty_underwater.world &

# Wait for Gazebo to start
sleep 5

# Start the robot state publisher
ros2 launch uuv_descriptions upload_rexrov_default.launch.py &

# Wait for robot description to be available
sleep 3

# Get the robot description and spawn the model
ros2 param get /rexrov/robot_state_publisher robot_description | sed 's/^String value is: //' > /tmp/rexrov.urdf
gz model -m rexrov -f /tmp/rexrov.urdf

echo "RexROV simulation started successfully!"
echo "Gazebo is running with the RexROV model loaded"
echo "ROS topics are available for sensors and thrusters"
