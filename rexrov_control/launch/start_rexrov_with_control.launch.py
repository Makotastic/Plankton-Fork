import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import (
    PythonLaunchDescriptionSource,
    AnyLaunchDescriptionSource,
)


def generate_launch_description():
    # Get the launch directory for the rexrov_control package
    rexrov_control_launch_dir = os.path.join(
        get_package_share_directory("rexrov_control"), "launch"
    )

    # Get the launch directory for the uuv_descriptions package
    uuv_descriptions_launch_dir = os.path.join(
        get_package_share_directory("uuv_descriptions"), "launch"
    )

    # 1. Launch the simulation and spawn the RexROV
    # We use the existing launch file from uuv_descriptions
    spawn_rexrov_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(uuv_descriptions_launch_dir, "upload_rexrov_default.launch.py")
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

    # 2. Launch the position controller and thruster manager
    # position_hold_launch.xml already includes the thruster manager,
    # so we only need to include this one file.
    # We use AnyLaunchDescriptionSource because it's an XML file.
    position_control_launch = IncludeLaunchDescription(
        AnyLaunchDescriptionSource(
            os.path.join(rexrov_control_launch_dir, "position_hold_launch.xml")
        ),
        # The XML launch files use the 'uuv_name' argument for the namespace.
        # The default is 'rexrov', which matches the robot model, so we don't
        # need to override it unless you want a different namespace.
        # launch_arguments={'uuv_name': 'my_rexrov'}.items()
    )

    return LaunchDescription([spawn_rexrov_launch, position_control_launch])
