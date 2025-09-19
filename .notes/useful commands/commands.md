ros2 topic pub /rexrov/cmd_pose geometry_msgs/msg/PoseStamped '
{
  header: {
    stamp: {sec: 0, nanosec: 0},
    frame_id: "world"
  },
  pose: {
    position: {x: 100.0, y: 5.0, z: -20.0},
    orientation: {x: 0.0, y: 0.0, z: 0.0, w: 1.0}
  }
}' --once

ros2 topic pub /rexrov/thruster_manager/input_stamped geometry_msgs/msg/WrenchStamped '
{
  header: {
    stamp: {sec: 0, nanosec: 0},
    frame_id: "rexrov/base_link"
  },
  wrench: {
    force: {x: 100.0, y: 0.0, z: 0.0},
    torque: {x: 0.0, y: 0.0, z: 0.0}
  }
}' --once