import unittest

from demo import simulate
from pid import PIDController


class PIDTests(unittest.TestCase):
    def test_proportional_and_limits(self):
        pid = PIDController(2, 0, 0, (-1, 1))
        self.assertAlmostEqual(pid.update(0.2, 0, 0.1), 0.4)
        self.assertEqual(pid.update(10, 0, 0.1), 1)
        self.assertEqual(pid.update(-10, 0, 0.1), -1)

    def test_integral_accumulates_with_time(self):
        pid = PIDController(0, 2, 0)
        self.assertAlmostEqual(pid.update(1, 0, 0.25), 0.5)
        self.assertAlmostEqual(pid.update(1, 0, 0.25), 1)

    def test_saturation_does_not_wind_up(self):
        pid = PIDController(1, 1, 0, (-1, 1))
        for _ in range(1000):
            pid.update(100, 0, 0.1)
        self.assertEqual(pid.integral, 0)
        self.assertLess(pid.update(-0.5, 0, 0.1), 0)

    def test_integral_can_unwind_while_saturated(self):
        pid = PIDController(0, 1, 0, (-1, 1))
        pid.integral = 2
        pid.update(-1, 0, 0.1)
        self.assertAlmostEqual(pid.integral, 1.9)

    def test_no_setpoint_derivative_kick(self):
        pid = PIDController(0, 0, 1)
        pid.update(0, 0, 0.1)
        self.assertEqual(pid.update(100, 0, 0.1), 0)

    def test_derivative_filter_and_reset(self):
        pid = PIDController(0, 0, 1, derivative_tau=0.1)
        pid.update(0, 0, 0.1)
        self.assertAlmostEqual(pid.update(0, 1, 0.1), -5)
        pid.reset()
        self.assertEqual(pid.update(0, 1, 0.1), 0)

    def test_invalid_inputs(self):
        for dt in (0, -1, float("nan"), float("inf")):
            with self.assertRaises(ValueError):
                PIDController(1, 1, 1).update(0, 0, dt)
        for gains in ((-1, 1, 1), (1, float("nan"), 1)):
            with self.assertRaises(ValueError):
                PIDController(*gains)
        with self.assertRaises(ValueError):
            PIDController(1, 1, 1, (1, -1))

    def test_attitude_tracking_and_disturbance_recovery(self):
        rows = simulate()
        self.assertLess(abs(rows[899][2] - 10), 0.2)
        self.assertLess(abs(rows[-1][2] - 10), 0.2)
        self.assertTrue(all(abs(r[4]) <= 0.2 for r in rows))
        fine = simulate(dt=0.005)
        self.assertLess(abs(fine[-1][2] - rows[-1][2]), 0.05)


if __name__ == "__main__":
    unittest.main()
