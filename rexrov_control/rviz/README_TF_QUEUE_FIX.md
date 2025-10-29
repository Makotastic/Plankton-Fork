# RVIZ TF Message Queue Fix

## Problem
RVIZ was dropping TF messages with the error: "Message Filter dropping message: frame 'rexrov/sonar_mbes_link' at time X for reason 'discarding message because the queue is full'"

## Solution
The issue was caused by RVIZ's TF display having a limited message filter queue that was being overwhelmed by high-frequency TF transforms from the underwater vehicle's sensors.

### Changes Made

1. **Increased Frame Timeout**: Changed from 15 seconds to 30 seconds in both RVIZ configuration files:
   - `custom_sonar_ros2.rviz` (ROS 2)
   - `custom_sonar.rviz` (ROS 1)

2. **Frame Timeout Explanation**:
   - The Frame Timeout parameter controls how long RVIZ will wait for a transform before considering it outdated
   - Increasing this value gives RVIZ more time to process incoming TF messages before they expire
   - This helps prevent the message filter queue from filling up too quickly

## Additional Recommendations

If the issue persists, consider these additional optimizations:

1. **Reduce TF Publishing Rate**: If possible, reduce the update rate of TF publishers in the sensor configurations
2. **Use Static Transforms**: For frames that don't change frequently, use static transform publishers instead of dynamic ones
3. **Optimize Sensor Update Rates**: Review and potentially reduce the update rates of high-frequency sensors like sonar and DVL

## Files Modified
- `rexrov_control/rviz/custom_sonar_ros2.rviz` - Frame Timeout increased to 30 seconds
- `rexrov_control/rviz/custom_sonar.rviz` - Frame Timeout increased to 30 seconds

## Testing
After applying these changes, restart RVIZ and monitor the console output. The "queue is full" error messages should be significantly reduced or eliminated.
