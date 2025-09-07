###############################################################################
# ROS 2 Humble + Plankton UUV Simulator (Optimized Build)
###############################################################################
FROM osrf/ros:humble-desktop-full

# Build arguments for optimization
ARG COLCON_JOBS=4
ARG DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /root

# ── 1. Install system packages in layers for better caching ──────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        # Core build tools
        build-essential \
        cmake \
        git \
        wget \
        curl \
        vim \
        # Basic ROS 2 packages (verify these exist first)
        ros-humble-gazebo-ros-pkgs \
        ros-humble-gazebo-dev \
        ros-humble-nav2-bringup \
        ros-humble-robot-localization \
        ros-humble-slam-toolbox \
        # Python packages
        python3-rosdep \
        python3-colcon-common-extensions \
        python3-vcstool \
        python3-pip \
        python3-opencv \
        # Libraries for UUV simulation
        libbullet-dev \
        libeigen3-dev \
        && rm -rf /var/lib/apt/lists/*

# ── 2. Install additional ROS 2 packages that might not be available initially ─
RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-humble-cartographer || true \
        ros-humble-cartographer-ros || true \
        ros-humble-navigation2 || true \
        ros-humble-nav2-core || true \
        libnlopt-cxx-dev || true \
        && rm -rf /var/lib/apt/lists/*

# ── 3. Install Python packages for ML pipeline ───────────────────────────────
RUN pip3 install --no-cache-dir \
        torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/cpu \
        --extra-index-url https://pypi.org/simple \
        opencv-python numpy matplotlib pandas jupyter albumentations onnx onnxruntime

# ── 4. Initialize rosdep ──────────────────────────────────────────────────────
RUN rosdep init || true && rosdep update

# ── 5. Create workspace structure ─────────────────────────────────────────────
RUN mkdir -p /uuv_ws/src

# ── 6. Clone Plankton repository ──────────────────────────────────────────────
WORKDIR /uuv_ws/src
RUN git clone --branch humble-development --depth 1 \
        https://github.com/Makotastic/Plankton-Fork.git

# ── 7. Install workspace dependencies ────────────────────────────────────────
WORKDIR /uuv_ws
RUN apt-get update && \
        rosdep install --from-paths src --ignore-src -r -y --skip-keys="gazebo gazebo_dev gazebo_msgs gazebo_plugins gazebo_ros" && \
        rm -rf /var/lib/apt/lists/*

# ── 8. Build workspace with error handling ───────────────────────────────────
RUN bash -c 'set -e; \
        source /opt/ros/humble/setup.bash && \
        echo "Starting colcon build..." && \
        colcon build' 
#         --symlink-install \
#         --cmake-args -DCMAKE_BUILD_TYPE=Release \
#         --packages-skip uuv_assistants \
#         --parallel-workers ${COLCON_JOBS} \
#         --event-handlers console_cohesion+ \
#         2>&1 | tee /tmp/colcon_build.log && \
#     echo "Build completed successfully!"'

# ── 9. Setup environment ──────────────────────────────────────────────────────
RUN echo 'source /opt/ros/humble/setup.bash' >> /root/.bashrc && \
        echo 'source /uuv_ws/install/setup.bash' >> /root/.bashrc && \
        echo 'source /usr/share/gazebo/setup.sh' >> /root/.bashrc && \
        echo 'export ROS_DOMAIN_ID=42' >> /root/.bashrc

# ── 10. Create project workspace structure ────────────────────────────────────
RUN mkdir -p /workspace/src && \
        mkdir -p /workspace/config && \
        mkdir -p /workspace/launch && \
        mkdir -p /workspace/data && \
        mkdir -p /workspace/models

# Set final working directory
WORKDIR /workspace

# Default command
CMD ["bash"]

# # Health check to verify ROS 2 is working
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#     CMD bash -c 'source /opt/ros/humble/setup.bash && ros2 node list' || exit 1