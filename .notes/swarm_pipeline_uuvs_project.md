# Swarm Pipeline‑Inspection UUVs

## 1. Initial Project Overview (12‑Week Simulation)

**Project Overview**  
Simulate a fleet of small autonomous underwater vehicles (UUVs) that cooperatively inspect a subsea pipeline for structural anomalies. Each robot localises itself, shares map data, and collectively achieves high‑coverage inspection with minimal operator input.

**AI Agent Components**

| Agent | Role |
|-------|------|
| **Frontier‑Explorer Agents** | Select the next mapping waypoint using frontier‑based exploration. |
| **Consensus Agent** | Implements a decentralised workload‑balancing protocol (average consensus) so coverage is evenly divided. |
| **Anomaly‑Scoring Agent** | Runs a lightweight CNN on simulated sonar images to flag corrosion, cracks, or missing pipe anchors. |

**Robotics Application**  
Mirrors real‑world underwater infrastructure inspection (nuclear cooling lines, offshore pipelines) where GPS is unavailable and collaboration boosts speed and reliability.

**Technical Implementation**

* **Simulator** – ROS 2 + Gazebo Classic with BlueROV2 or custom UUV models from `uuv_simulator`.  
* **Perception** – OpenCV + NumPy to render synthetic multibeam sonar; PyTorch for CNN inference.  
* **Control** – Depth & heading PID controllers; `nav2` for waypoint following.  
* **Coordination** – Ring‑topology consensus (ZeroMQ or DDS) to share frontier cost tables.  
* **Mapping** – 2‑D occupancy grid with `gmapping`; sub‑map fusion through pose‑graph optimisation.

**Career Relevance**  
Highlights multi‑agent coordination, sensor fusion, and control in a defense‑relevant subsea domain—directly applicable to unmanned maritime systems.

**Complexity Level**

| Metric | Estimate |
|--------|----------|
| **Timeline** | ~12 weeks (≈3 months) |
| **Difficulty** | Medium–High |

---

## 2. Full Project Specification – 3‑Month Track

### 2.1 Mission Statement & End‑Goals

| Goal | “Good” looks like |
|------|-------------------|
| **Autonomous coverage** | ≥ 90 % of a 1 km virtual pipeline mapped in one mission without operator waypoints. |
| **Collaborative mapping** | Single fused occupancy/elevation grid with < 5 cm RMS mis‑registration error at 20 m sensor range. |
| **Defect discovery** | CNN flags defects with ≥ 85 % precision and ≥ 85 % recall. |
| **Decentralised workload balance** | Swarm idle time < 10 % of mission. |
| **Engineering artefacts** | Dockerised repo, demo video, technical report with metrics. |

### 2.2 System Architecture
```
┌────────────────────────────────────────────────────┐
│ Gazebo (hydrodynamics, pipeline world, sensors)    │
├────────────────────────────────────────────────────┤
│ ROS 2 middleware (DDS)                             │
├────────────────────────────────────────────────────┤
│ Per‑Robot Nodes:                                   │
│   · Thruster PID controllers (uuv_control_ros)     │
│   · Sensor drivers (IMU, depth, multibeam, DVL)    │
│   · EKF / SLAM (robot_localization + Cartographer) │
│   · Frontier‑Explorer agent                        │
│   · Local RRT* planner + nav2                     │
│                                                    │
│ Swarm‑Level Nodes:                                 │
│   · Map‑Server (submap store + pose‑graph merge)   │
│   · Consensus agent (gossip AVG on workload table) │
│   · Anomaly‑Scoring micro‑service (PyTorch CNN)    │
│   · Mission dashboard (RViz + rqt_reconfigure)     │
└────────────────────────────────────────────────────┘
```

### 2.3 Key Concepts & Algorithms

| Layer | Core ideas | References |
|-------|------------|------------|
| **Control** | 6‑DOF PID, surge‑heave decoupling, thruster modelling | `uuv_control_ros` |
| **State estimation** | IMU–DVL–pressure EKF; pose‑graph SLAM | `robot_localization`, Cartographer 2‑D |
| **Exploration** | Wavefront frontier detection, utility scoring | Yamauchi (1997), ROS `frontier_exploration` |
| **Consensus** | Asynchronous gossip averaging for workload sharing | Olfati‑Saber (2007) |
| **Map merging** | Occupancy‑grid union via probabilistic OR | `gmapping`, `octomap_server` |
| **Anomaly detection** | Lightweight UNet / DW‑Sep CNN on sonar | PyTorch, Albumentations |
| **Metrics** | Coverage %, mission time, bandwidth, F1, localisation RMSE | NumPy, Pandas |

### 2.4 Toolchain & Dependencies

| Domain | Tool | Purpose |
|--------|------|---------|
| **DevOps** | Ubuntu 22.04, Docker, VS Code | Consistent ROS 2 stack |
| **Simulation** | Gazebo Classic, `uuv_simulator` | Hydrodynamics & sensors |
| **Robotics MW** | ROS 2 Humble, `nav2` | Multi‑robot comms & navigation |
| **SLAM** | Cartographer, GMapping, OctoMap | Mapping & pose graphs |
| **Vision / Sonar** | OpenCV, NumPy | Synthetic sensor & CV |
| **ML** | PyTorch, ONNX Runtime | CNN training & inference |
| **Multi‑agent** | ZeroMQ / Redis | Consensus experiments |
| **Analysis** | JupyterLab, Pandas, Matplotlib | Plots & reports |
| **Hardware** | NVIDIA GPU (≥6 GB) | Accelerated training |

### 2.5 12‑Week Work‑Plan

| Week | Deliverable | Focus |
|------|-------------|-------|
| 1 | Repo scaffold, Docker env, single UUV in Gazebo | DevOps |
| 2 | Stable depth & heading PID | Control |
| 3 | EKF error ≤0.2 m over 60 s | State Estimation |
| 4–5 | Frontier detection + local planner | Autonomy v1 |
| 6 | Single‑UUV full pipeline map | Mapping |
| 7 | Multi‑UUV comms scaffold | Swarm setup |
| 8 | Consensus converges (<5 iters) | Workload balance |
| 9 | Map fusion error <5 cm | Map merge |
| 10 | Synthetic sonar + dataset | Data pipeline |
| 11 | CNN F1 ≥ 0.85, ONNX export | Defect detection |
| 12 | End‑to‑end demo, metrics notebook, report | Integration |

### 2.6 Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Unstable hydrodynamics | SLAM drift | Use verified `uuv_simulator` models, cap speed |
| DDS message flood | Latency | Compress & throttle, QoS tuning |
| CNN overfitting | Low recall | Heavy augmentation, noise, varied textures |
| SLAM tuning creep | Schedule slip | “Freeze” good‑enough EKF; iterate only if slack |

### 2.7 Stretch Goals

1. **Adaptive exploration** – multi‑objective frontier scoring.  
2. **Acoustic‑modem comms** – latency/dropout simulation.  
3. **RL frontier agent** – PPO via PettingZoo.  
4. **WebGL 3‑D viewer** – interactive OctoMap in browser.

---

### 3. Expected Outcomes
* **Dockerised multi‑agent autonomy stack** runnable with one command.  
* Evidence of **sensor fusion, decentralised consensus, SLAM, control, and lightweight deep learning** in a defense‑relevant subsea context.  
* Portfolio artefacts (video, metrics report, documentation) ready for recruiters and program managers.

---

*Prepared: {date}*