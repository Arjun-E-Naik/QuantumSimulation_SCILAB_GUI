# Scilab Quantum Computing Visualizer (SQCV)

An interactive, modular quantum circuit simulator and visualization suite implemented natively in **Scilab**. SQCV provides a graphical environment to design, simulate, step-through, and analyze quantum circuits up to 8 qubits, complete with state vector inspection, multi-shot measurement histograms, and 3D Bloch sphere projections.

---

## Table of Contents
- [Project Title](#scilab-quantum-computing-visualizer-sqcv)
- [Project Description](#project-description)
  - [Key Features](#key-features)
  - [Mathematical & Simulation Engine](#mathematical--simulation-engine)
  - [Repository Structure](#repository-structure)
- [Software Requirements](#software-requirements)
- [Toolboxes Used](#toolboxes-used)
- [Steps to Run the Application](#steps-to-run-the-application)
  - [Quick Start](#quick-start)
  - [Running Unit Tests](#running-unit-tests)
  - [Step-by-Step Launch Guide](#step-by-step-launch-guide)
- [Brief Explanation of the GUI and its Features](#brief-explanation-of-the-gui-and-its-features)
  - [1. GUI Layout Overview](#1-gui-layout-overview)
  - [2. Top Toolbar Controls](#2-top-toolbar-controls)
  - [3. Quantum Gate Palette](#3-quantum-gate-palette)
  - [4. Interactive Panels & Visualizations](#4-interactive-panels--visualizations)
  - [5. Built-in Quantum Algorithm Demonstrations](#5-built-in-quantum-algorithm-demonstrations)
  - [6. Step-by-Step Circuit Building Example](#6-step-by-step-circuit-building-example)
- [References](#references)

---

## Project Description

The **Scilab Quantum Computing Visualizer (SQCV)** is an educational and research-oriented quantum computing simulation environment. Designed to run natively inside Scilab without external dependencies, SQCV bridges the gap between quantum computational mathematics and visual intuition.

Users can interactively construct arbitrary quantum circuits across 1 to 8 qubits, apply single-qubit gates, parametric rotations, and multi-qubit controlled gates, and observe quantum phenomena such as **superposition**, **entanglement**, **phase kickback**, and **wavefunction collapse** in real-time.

### Key Features
- **Interactive Circuit Designer**: Add standard and custom parameterized gates onto qubit wires with auto-column layout positioning.
- **State Vector Inspector**: Real-time table rendering complex amplitudes $(\text{Re} + i\,\text{Im})$, probabilities $(|\alpha|^2)$, and relative phase angles in degrees for all $2^N$ basis states.
- **Dynamic Circuit Stepper**: Step through the circuit gate-by-gate with active gate highlighting and console equation logging.
- **Dual Measurement Engine**:
  - **Single-Shot Projective Measurement**: Collapses the quantum state according to Born's rule and displays the measured outcome.
  - **1000-Shot Monte Carlo Sampling**: Simulates repeated measurements and visualizes empirical frequency distributions.
- **2D Bloch Sphere Visualization**: Real-time 2D projection of the reduced density matrix $\rho$ for single-qubit states and subsystems via partial trace.
- **Pre-Built Algorithm Demos**: One-click demonstrations for Bell States, Grover's Search Algorithm, Deutsch-Jozsa Algorithm, and Quantum Teleportation.

### Mathematical & Simulation Engine
- **State Representation**: $N$-qubit state vectors $|\psi\rangle \in \mathbb{C}^{2^N}$ initialized to ground state $|0\dots0\rangle$.
- **Unitary Gate Transformations**: Arbitrary gate expansion using Kronecker tensor products ($\otimes$ / `kron`):
  $$U = I \otimes \dots \otimes U_{\text{gate}} \otimes \dots \otimes I$$
- **Controlled Gates**: Projector expansion using $P_0 = |0\rangle\langle0|$ and $P_1 = |1\rangle\langle1|$:
  $$U_{\text{ctrl}} = P_0 \otimes I + P_1 \otimes U_{\text{target}}$$
- **Subsystem Analysis**: Density matrix formulation $\rho = |\psi\rangle\langle\psi|$ with partial tracing $\rho_A = \text{Tr}_B(\rho)$ and purity calculation $\gamma = \text{Tr}(\rho^2)$ to quantify entanglement.

### Repository Structure

```
Scilab-GUI/
├── README.md                      # Comprehensive project documentation
├── main.sce                       # GUI entry point, layout setup, and callback definitions
├── sqcv_full.sce                  # Consolidated single-file bundle for one-line execution
├── algorithms/                    # Classical quantum algorithm implementations
│   ├── bell_state.sci             # Bell state generator and entanglement purity test
│   ├── deutsch_jozsa.sci          # Deutsch-Jozsa oracle and algorithm demo
│   ├── grover.sci                 # 2-qubit Grover search and diffusion operator
│   └── teleportation.sci          # 3-qubit quantum teleportation protocol
├── gates/                         # Quantum gate definitions
│   └── gate_matrices.sci          # Pauli (X,Y,Z), Hadamard (H), Phase (S,T), Rotations (RX,RY,RZ,P)
├── gui/                           # GUI helpers and circuit data structures
│   └── circuit_gui.sci            # Circuit tlist management and execution dispatcher
├── quantum/                       # Quantum core linear algebra functions
│   ├── apply_controlled_gate.sci  # Single/multi-controlled and permutation gate operators
│   ├── bloch_coordinates.sci      # Bloch vector (x,y,z) coordinate transformation
│   ├── density_matrix.sci         # Full state density matrix, partial trace, and purity
│   ├── measurement.sci            # Born rule sampling and projective collapse
│   ├── state_init.sci             # State vector initialization and binary indexing
│   └── tensor_product.sci         # Kronecker expansion across N-qubit Hilbert space
├── tests/                         # Unit validation test suite
│   └── test_all.sce               # Comprehensive test assertions for gates, norm, algorithms
└── visualization/                 # 2D and 3D graphics rendering modules
    ├── draw_bloch_shpere.sci      # 3D Bloch sphere surface, axes, and state vector arrow
    ├── draw_circuit.sci           # 2D circuit schematic renderer with custom gate symbols
    └── draw_state_vector.sci      # State vector listbox table and probability bar charts
```

---

## Software Requirements

| Component | Requirement | Notes |
|---|---|---|
| **Software Platform** | **Scilab 6.0.0 or higher** (Recommended: Scilab 6.1.x, 2024.x, 2025.x) | Fully cross-platform |
| **Operating System** | Windows 10/11, Linux (Ubuntu/Debian/Fedora), or macOS | Verified on Windows |
| **Graphics Engine** | OpenGL compatible graphics driver | Required for 3D Bloch sphere rendering |
| **Memory (RAM)** | Minimum 2 GB  | Simulation scales as $\mathcal{O}(2^N)$ |
| **Disk Space** | $< 10 \text{ MB}$ for project files | Lightweight pure-script implementation |

---

## Toolboxes Used

**No external or paid ATOMS toolboxes are required.** 

SQCV is built 100% on Scilab's standard built-in modules:
1. **Scilab GUI & UICONTROL Module**:
   - `figure`, `uicontrol` (pushbuttons, listboxes, popup dropdown menus).
   - `x_dialog` for interactive user prompts (qubit selection, rotation angles).
   - `messagebox` for user notifications, measurement results, and error handling.
2. **Scilab 2D/3D Graphics Engine**:
   - `newaxes`, `sca` (sub-window axes targeting and coordinate mapping).
   - `plot2d`, `xfarc`, `xarc`, `xrect`, `xstring` (vectorized circuit drawing).
   - `plot3d1`, `param3d`, `param3d1` (3D Bloch sphere wireframe and state vector arrows).
   - `bar` (discrete probability distribution and measurement histogram plotting).
3. **Scilab Linear Algebra & Math Library**:
   - `kron` (Kronecker tensor product for gate expansion).
   - `trace`, `norm`, `conj`, `real`, `imag`, `eye`, `zeros` (quantum operators).

---

## Steps to Run the Application


### Running Unit Tests

Before launching the GUI, you can verify that all gate transformations, algorithms, partial traces, and measurement functions pass validation:

```scilab
run_all_tests();
```

*Expected output:*
```text
[PASS] X|0>=|1>
[PASS] X|1>=|0>
[PASS] H|0>=(|0>+|1>)/sqrt2
[PASS] H^2|0>=|0>
[PASS] Z|0>=|0>
[PASS] Z|1>=-|1>
[PASS] CNOT|00>=|00>
[PASS] CNOT|10>=|11>
[PASS] Bell circuit = (|00>+|11>)/sqrt2
[PASS] Bell probs only 00/11
[PASS] Probabilities sum to 1
[PASS] Norm preserved under H
[PASS] SWAP|01>=|10>
[PASS] Toffoli|110>=|111>
[PASS] Bloch |0> = (0,0,1)
[PASS] Bloch |+> = (1,0,0)
...
all tests passed.
```

---

### Step-by-Step Launch Guide

#### Method A: Using Scilab Console (Interactive GUI Mode)
1. Launch Scilab from your desktop or start menu.
2. In the **File Browser** panel or using the console command line, set the current working directory:
   ```scilab
   cd 'C:\Users\arjun\OneDrive\Desktop\SCILAB\Scilab-GUI';
   ```
3. Execute the full bundle script:
   ```scilab
   exec('sqcv_full.sce', -1);
   ```
4. Start the visualizer:
   ```scilab
   SQCV_start();
   ```



---

## Brief Explanation of the GUI and its Features

### 1. GUI Layout Overview

The SQCV window is organized into dedicated functional zones:

```
+---------------------------------------------------------------------------------------+
|  [New] [Reset] [Run] [Step] [Clear] [Measure 1] [Measure 1000]  Qubits: [ 2 v ]       |
+-----------+---------------------------------------+-----------------------------------+
|  GATES    |                                       |                                   |
|  [ H ]    |       QUANTUM CIRCUIT CANVAS          |    MEASUREMENT PROBABILITIES      |
|  [ X ]    |    (Visual wires, gates & steps)      |     (Theoretical bar chart /      |
|  [ Y ]    |                                       |       1000-shot histogram)        |
|  [ Z ]    |                                       |                                   |
|  [ S ]    +---------------------------------------+-----------------------------------+
|  [ Sdg]   |                                       |                                   |
|  [ T ]    |           3D BLOCH SPHERE             |        STATE VECTOR TABLE         |
|  [ Tdg]   |         (Qubit 0 State Vector)        |   (Basis | Amplitude | Prob | Ph) |
|  [ RX]    |                                       |                                   |
|  [ RY]    |                                       |                                   |
|  [ RZ]    |                                       |                                   |
|  [CNOT]   |                                       |                                   |
|  [ CZ ]   |                                       |                                   |
|  [SWAP]   |                                       |                                   |
|  [TOFF]   |                                       |                                   |
|  [FRED]   |                                       |                                   |
|  -------  |                                       |                                   |
|  [BELL]   |                                       |                                   |
|  [GROV]   |                                       |                                   |
|  [D-J ]   |                                       |                                   |
|  [TELE]   |                                       |                                   |
+-----------+---------------------------------------+-----------------------------------+
```

---

### 2. Top Toolbar Controls

- **`New Circuit` / `Clear`**: Clears the circuit canvas and resets the state to $|0\dots0\rangle$.
- **`Reset`**: Resets the state vector back to $|0\dots0\rangle$ while keeping the existing circuit layout intact.
- **`Run`**: Evaluates all gates sequentially from left to right and displays the final quantum state across all visualization windows.
- **`Step`**: Executes the circuit step-by-step (gate-by-gate). Highlights the currently executed gate in red and prints the exact gate transition in the Scilab console.
- **`Measure 1`**: Performs an instantaneous projective measurement, collapses the state vector onto one random basis state according to its probability, and displays a popup notification with the outcome (e.g., `|01>`).
- **`Measure 1000`**: Simulates 1000 independent measurement shots from the current probability distribution and plots the resulting statistical histogram in the probability panel.
- **`Qubits` Dropdown**: Configures the total number of qubits ($N = 1$ to $8$).

---

### 3. Quantum Gate Palette

Clicking any button on the left panel prompts for the target qubit index (0-based) and adds the gate to the circuit:

| Gate Category | Gate | Symbol / Operation | Description |
|---|---|---|---|
| **Single-Qubit Standard** | `H` | Hadamard | Creates equal superposition: $|0\rangle \to \frac{|0\rangle+|1\rangle}{\sqrt{2}}$, $|1\rangle \to \frac{|0\rangle-|1\rangle}{\sqrt{2}}$ |
| | `X` | Pauli-$X$ | Bit-flip gate ($NOT$): $|0\rangle \leftrightarrow |1\rangle$ |
| | `Y` | Pauli-$Y$ | Bit- and phase-flip: $|0\rangle \to i|1\rangle$, $|1\rangle \to -i|0\rangle$ |
| | `Z` | Pauli-$Z$ | Phase-flip gate: $|1\rangle \to -|1\rangle$ |
| | `S`, `Sdg` | Phase / $S^\dagger$ | $\pi/2$ phase shift ($Z^{1/2}$) and adjoint ($-\pi/2$) |
| | `T`, `Tdg` | $\pi/8$ / $T^\dagger$ | $\pi/4$ phase shift ($Z^{1/4}$) and adjoint ($-\pi/4$) |
| **Parametric Rotations** | `RX` | $R_X(\theta) = \exp(-i\theta X/2)$ | Rotation around the X-axis by angle $\theta$ (in radians) |
| | `RY` | $R_Y(\theta) = \exp(-i\theta Y/2)$ | Rotation around the Y-axis by angle $\theta$ (in radians) |
| | `RZ` | $R_Z(\theta) = \exp(-i\theta Z/2)$ | Rotation around the Z-axis by angle $\theta$ (in radians) |
| **Multi-Qubit Gates** | `CNOT` | Controlled-NOT | Flips target qubit when control qubit is $|1\rangle$ |
| | `CZ` | Controlled-Phase | Applies phase flip ($-1$) to $|11\rangle$ |
| | `SWAP` | SWAP | Swaps the quantum states of two selected qubits |
| | `TOFFOLI` | CCX (3-Qubit) | Flips target qubit only if both control qubits are $|1\rangle$ |
| | `FREDKIN` | CSWAP (3-Qubit) | Swaps two target qubits only if control qubit is $|1\rangle$ |

---

### 4. Interactive Panels & Visualizations

1. **Center Circuit Board**:
   - Displays horizontal qubit wires labeled $q_0, q_1, \dots, q_{N-1}$.
   - Renders standard box notation for single-qubit gates, filled dots for controls, and circle-cross markers for target qubits.
   - Highlights the active step during stepped execution.

2. **State Vector Table (Bottom-Right)**:
   - Lists all $2^N$ computational basis states ($|00\rangle, |01\rangle, \dots$).
   - Columns: `BASIS`, `AMPLITUDE` $(\text{Real} + \text{Imag}\,i)$, `PROB` $(|\alpha|^2)$, and `PHASE(deg)`.

3. **Probability Bar Chart (Top-Right)**:
   - Visual bar chart displaying theoretical measurement probabilities for every basis state.
   - Automatically switches to an empirical histogram when `Measure 1000` is clicked.

4. **3D Bloch Sphere (Bottom-Left)**:
   - Renders a 3D spherical coordinate frame with Cartesian axes $(X, Y, Z)$ and $|0\rangle$ (North Pole) / $|1\rangle$ (South Pole).
   - Projects the reduced density matrix $\rho$ of qubit $q_0$ (via partial trace $\text{Tr}_{\text{rest}}$) as a 3D state vector arrow:
     $$x = \text{Tr}(\rho X), \quad y = \text{Tr}(\rho Y), \quad z = \text{Tr}(\rho Z)$$

---

### 5. Built-in Quantum Algorithm Demonstrations

Click the demo buttons in the lower sidebar to load and run predefined algorithms:

#### • Bell State Demo (`Bell Demo`)
- **Circuit**: $H(q_0) \to CNOT(q_0, q_1)$.
- **State**: $|\Phi^+\rangle = \frac{|00\rangle + |11\rangle}{\sqrt{2}}$.
- **Physics**: Demonstrates maximal quantum entanglement. Tracing out either qubit yields a maximally mixed state $\rho_0 = \frac{1}{2}I$ with purity $\text{Tr}(\rho^2) = 0.5$.

#### • Grover's Search Demo (`Grover Demo`)
- **Target**: Finds marked element $|11\rangle$ in an unsorted 2-qubit database.
- **Workflow**: Uniform superposition $\to$ Oracle reflection $\to$ Grover diffusion operator ($2|s\rangle\langle s| - I$).
- **Result**: Amplifies target probability $P(|11\rangle)$ from $25\%$ to $100\%$ in a single iteration.

#### • Deutsch-Jozsa Demo (`DJ Demo`)
- **Purpose**: Determines whether an oracle function $f(x)$ is constant or balanced in a single quantum query.
- **Result**: Evaluates both balanced and constant oracles; prints function classification in the Scilab console.

#### • Quantum Teleportation Demo (`Teleport Demo`)
- **Protocol**: Teleports an unknown input state $|\psi\rangle = \cos(\theta/2)|0\rangle + e^{i\phi}\sin(\theta/2)|1\rangle$ from Alice ($q_0$) to Bob ($q_2$) using an EPR pair ($q_1, q_2$).
- **Verification**: Bob's final Bloch vector $(x, y, z)$ is matched against Alice's input state.

---

### 6. Step-by-Step Circuit Building Example

To create a 2-qubit entangled Bell State manually:

1. Launch SQCV: `SQCV_start();`.
2. Select **Qubits**: `2`.
3. Click **`H`** on the gate palette $\to$ Enter `0` in the dialog (places Hadamard on $q_0$).
4. Click **`CNOT`** on the gate palette $\to$ Enter `0` for control, `1` for target.
5. Click **`Run`** to execute:
   - State vector table displays: `|00>: 0.707+0.000i (50%)` and `|11>: 0.707+0.000i (50%)`.
   - Probability bar chart shows equal peaks at $|00\rangle$ and $|11\rangle$.
6. Click **`Measure 1`** to observe state collapse to either $|00\rangle$ or $|11\rangle$.

---

## References

1. **Deutsch, D., & Jozsa, R.** (1992). *Rapid solution of problems by quantum computation*. Proceedings of the Royal Society of London. Series A, 439(1907), 553-558.
2. **Grover, L. K.** (1996). *A fast quantum mechanical algorithm for database search*. Proceedings of the 28th Annual ACM Symposium on the Theory of Computing (STOC), 212-219.
3. **Scilab Documentation**. *GUI and Graphics Objects*. Scilab Enterprises / Dassault Systèmes. Available at: [https://help.scilab.org/](https://help.scilab.org/)
