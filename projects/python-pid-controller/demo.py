"""Run a one-axis attitude simulation and save CSV, metrics, and an optional plot."""

import argparse
import csv
import json
import math
from pathlib import Path

from pid import PIDController


def simulate(kp=2.4, ki=0.8, kd=2.0, dt=0.01, duration=20.0):
    if not math.isfinite(dt) or dt <= 0 or not math.isfinite(duration) or duration <= 0:
        raise ValueError("dt and duration must be finite and positive")
    controller = PIDController(kp, ki, kd, (-0.2, 0.2), 0.05)
    inertia, damping = 1.0, 0.15
    theta, omega = 0.0, 0.0
    rows = []
    for step in range(math.ceil(duration / dt)):
        time = step * dt
        target = math.radians(10) if time >= 1.0 else 0.0
        disturbance = -0.04 if 10.0 <= time < 12.0 else 0.0
        torque = controller.update(target, theta, dt)
        # Values on each row describe the state before advancing this interval.
        rows.append((time, math.degrees(target), math.degrees(theta),
                     math.degrees(omega), torque, disturbance))
        # RK4 plant integration; commanded and disturbance torques held over dt.
        def rhs(angle, rate):
            return rate, (torque + disturbance - damping * rate) / inertia
        a1, w1 = rhs(theta, omega)
        a2, w2 = rhs(theta + dt*a1/2, omega + dt*w1/2)
        a3, w3 = rhs(theta + dt*a2/2, omega + dt*w2/2)
        a4, w4 = rhs(theta + dt*a3, omega + dt*w3)
        theta += dt * (a1 + 2*a2 + 2*a3 + a4) / 6
        omega += dt * (w1 + 2*w2 + 2*w3 + w4) / 6
    return rows


def metrics(rows):
    step_response = [r for r in rows if 1.0 <= r[0] < 10.0]
    recovery = [r for r in rows if r[0] >= 12.0]
    def settling(segment, origin):
        # First sampled time after which all remaining samples stay within 2%.
        outside = [i for i, r in enumerate(segment) if abs(r[2] - 10.0) > 0.2]
        index = outside[-1] + 1 if outside else 0
        return segment[index][0] - origin if index < len(segment) else None
    return {
        "step_overshoot_percent": max(0.0, (max(r[2] for r in step_response)-10)/10*100),
        "step_settling_time_2pct_s": settling(step_response, 1.0),
        "post_disturbance_settling_time_2pct_s": settling(recovery, 12.0),
        "final_error_deg": rows[-1][1] - rows[-1][2],
        "peak_command_torque_Nm": max(abs(r[4]) for r in rows),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kp", type=float, default=2.4)
    parser.add_argument("--ki", type=float, default=0.8)
    parser.add_argument("--kd", type=float, default=2.0)
    parser.add_argument("--output", type=Path, default=Path(__file__).parent / "results")
    parser.add_argument("--plot", action="store_true", help="Requires matplotlib")
    args = parser.parse_args()
    rows = simulate(args.kp, args.ki, args.kd)
    args.output.mkdir(parents=True, exist_ok=True)
    with (args.output / "response.csv").open("w", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(("time_s", "target_deg", "angle_deg", "rate_deg_s",
                         "command_torque_Nm", "disturbance_torque_Nm"))
        writer.writerows(rows)
    summary = metrics(rows)
    (args.output / "metrics.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))
    if args.plot:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        t, target, angle, rate, command, disturbance = zip(*rows)
        fig, axes = plt.subplots(2, 1, figsize=(10, 6), sharex=True)
        axes[0].plot(t, target, "--", label="Target")
        axes[0].plot(t, angle, label="Attitude")
        axes[0].set_ylabel("Angle (deg)")
        axes[0].set_title("Python PID | one-axis spacecraft attitude simulation")
        axes[1].plot(t, command, label="Command torque")
        axes[1].plot(t, disturbance, "--", label="Disturbance")
        axes[1].set_ylabel("Torque (N m)")
        axes[1].set_xlabel("Time (s)")
        for axis in axes:
            axis.axvspan(10, 12, alpha=0.12, color="orange")
            axis.grid(alpha=0.25)
            axis.legend()
        fig.tight_layout()
        fig.savefig(args.output / "response.svg")
        plt.close(fig)


if __name__ == "__main__":
    main()
