"""Discrete PID with actuator limits and conditional-integration anti-windup."""

from math import isfinite


class PIDController:
    """Gains assume seconds; derivative acts on measurement to avoid setpoint kick."""

    def __init__(self, kp, ki, kd, output_limits=(-float("inf"), float("inf")),
                 derivative_tau=0.05):
        if not all(isfinite(x) and x >= 0 for x in (kp, ki, kd, derivative_tau)):
            raise ValueError("Gains and derivative_tau must be finite and nonnegative")
        low, high = output_limits
        if not low < high:
            raise ValueError("Output limits must be ordered")
        self.kp, self.ki, self.kd = kp, ki, kd
        self.low, self.high = low, high
        self.derivative_tau = derivative_tau
        self.reset()

    def reset(self):
        self.integral = 0.0
        self.derivative = 0.0
        self.previous_measurement = None

    def update(self, setpoint, measurement, dt):
        if not all(isfinite(x) for x in (setpoint, measurement, dt)) or dt <= 0:
            raise ValueError("Inputs must be finite and dt must be positive")
        error = setpoint - measurement
        if self.previous_measurement is not None:
            rate = (measurement - self.previous_measurement) / dt
            alpha = dt / (self.derivative_tau + dt)
            self.derivative += alpha * (rate - self.derivative)
        self.previous_measurement = measurement
        candidate = self.integral + self.ki * error * dt
        pd = self.kp * error - self.kd * self.derivative
        trial = pd + candidate
        # Freeze integration only when it would push farther into saturation.
        if not ((trial > self.high and error > 0) or
                (trial < self.low and error < 0)):
            self.integral = candidate
        return min(self.high, max(self.low, pd + self.integral))
