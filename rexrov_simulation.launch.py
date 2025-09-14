#!/usr/bin/env python3

import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import (
    ExecuteProcess,
    SetEnvironmentVariable,
    IncludeLaunchDescription,
)
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    # Set the GAZEBO_PLUGIN_PATH to include ROS and UUV plugins
    gazebo_plugin_path = [
        "/opt/ros/humble/lib",
        "/uuv_ws/install/uuv_gazebo_ros_plugins/lib",
        "/usr/lib/x86_64-linux-gnu/gazebo-11/plugins",
    ]

    # Set environment variables
    # Create symbolic link and set resource path to include it
    env_vars = {
        "GAZEBO_PLUGIN_PATH": ":".join(gazebo_plugin_path),
        "GAZEBO_MODEL_PATH": get_package_share_directory("uuv_gazebo_worlds")
        + "/models",
        "GAZEBO_RESOURCE_PATH": "/usr/share/gazebo-11:/tmp",
    }

    # Start Gazebo with the empty underwater world - set environment directly
    gazebo_cmd = [
        "bash",
        "-c",
        f"export GAZEBO_PLUGIN_PATH={env_vars['GAZEBO_PLUGIN_PATH']} && "
        f"export GAZEBO_MODEL_PATH={env_vars['GAZEBO_MODEL_PATH']} && "
        f"export GAZEBO_RESOURCE_PATH={env_vars['GAZEBO_RESOURCE_PATH']} && "
        "gazebo --verbose "
        + get_package_share_directory("uuv_gazebo_worlds")
        + "/worlds/empty_underwater.world",
    ]

    gazebo_process = ExecuteProcess(
        cmd=gazebo_cmd,
        output="screen",
    )

    # Include the robot state publisher from uuv_descriptions
    robot_state_publisher = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            [
                get_package_share_directory("uuv_descriptions"),
                "/launch/upload_rexrov_default.launch.py",
            ]
        ),
        launch_arguments={
            "namespace": "rexrov",
            "x": "0",
            "y": "0",
            "z": "-20",
            "roll": "0",
            "pitch": "0",
            "yaw": "0",
        }.items(),
    )

    # Wait a bit for Gazebo and robot_state_publisher to start up before spawning
    import time

    time.sleep(2)

    # Use gz model command to spawn the model (bypasses ROS spawn service issues)
    # This approach uses the parameter server instead of the topic
    spawn_entity_cmd = [
        "bash",
        "-c",
        "sleep 15 && ros2 param get /rexrov/robot_state_publisher robot_description | "
        + "sed 's/^String value is: //' > /tmp/rexrov_final.urdf && "
        + "gz model -m rexrov -f /tmp/rexrov_final.urdf",
    ]

    spawn_entity = ExecuteProcess(
        cmd=spawn_entity_cmd,
        output="screen",
    )

    return LaunchDescription(
        [
            SetEnvironmentVariable(
                "GAZEBO_PLUGIN_PATH", env_vars["GAZEBO_PLUGIN_PATH"]
            ),
            SetEnvironmentVariable("GAZEBO_MODEL_PATH", env_vars["GAZEBO_MODEL_PATH"]),
            gazebo_process,
            robot_state_publisher,
            spawn_entity,
        ]
    )
