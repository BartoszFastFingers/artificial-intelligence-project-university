import numpy as np
import matplotlib.pyplot as plt
from collections import deque
class SimpleKalmanFilter:
    def __init__(self, A, B, C, Q, R, P_init, x_init):
        self.A = A
        self.B = B
        self.C = C
        self.Q = Q
        self.R = R
        self.P = P_init
        self.x = x_init

    def predict(self, u):

        self.x = self.A * self.x + self.B * u

        self.P = self.A * self.P * self.A + self.Q

    def update(self, z):

        K = (self.P * self.C) / (self.C * self.P * self.C + self.R)

        self.x = self.x + K * (z - self.C * self.x)

        self.P = (1 - K * self.C) * self.P
        return self.x


K_gain = 0.0485
T_const = 0.0101
T_delay_sec = 0.0109

dt = 0.001
sim_time = 0.3
steps = int(sim_time / dt)

A_d = np.exp(-dt / T_const)
B_d = K_gain * (1 - A_d)
C_d = 1.0


sigma_process_real = 0.8

encoder_res = 1.0


Q_kf = 0.5
R_kf = 5.0

kf = SimpleKalmanFilter(A=A_d, B=B_d, C=C_d, Q=Q_kf, R=R_kf, P_init=1.0, x_init=0.0)

sma_window = 20
sma_buffer = deque(maxlen=sma_window)

delay_steps = int(np.round(T_delay_sec / dt))
u_buffer = deque([0.0] * delay_steps, maxlen=delay_steps)

t_vec = np.linspace(0, sim_time, steps)
u_vec = np.zeros(steps)
y_true_vec = np.zeros(steps)
y_meas_vec = np.zeros(steps)
y_kf_vec = np.zeros(steps)
y_sma_vec = np.zeros(steps)

u_vec[int(0.02 / dt):] = 100.0
x_true = 0.0

print(f"Symulacja start: {steps} kroków.")
print(f"Opóźnienie: {delay_steps} próbek ({T_delay_sec * 1000} ms).")

for k in range(steps):
    current_u = u_vec[k]
    u_delayed = u_buffer[0]

    process_noise = np.random.normal(0, sigma_process_real)
    x_true = A_d * x_true + B_d * u_delayed + process_noise
    y_true_vec[k] = x_true

    z = np.round(x_true / encoder_res) * encoder_res
    y_meas_vec[k] = z

    kf.predict(u=u_delayed)
    y_kf_vec[k] = kf.update(z=z)

    sma_buffer.append(z)
    y_sma_vec[k] = sum(sma_buffer) / len(sma_buffer) if sma_buffer else 0.0

    u_buffer.append(current_u)

def calculate_rmse(true, est):
    return np.sqrt(np.mean((true - est) ** 2))


error_sma = y_true_vec - y_sma_vec
error_kf = y_true_vec - y_kf_vec

rmse_kf = np.sqrt(np.mean(error_kf**2))
rmse_sma = np.sqrt(np.mean(error_sma**2))
std_kf = np.std(error_kf)
std_sma = np.std(error_sma)

print(f"{'Metoda':<15} | {'RMSE':<10} | {'StdDev':<10}")
print("-" * 40)
print(f"{'Kalman':<15} | {rmse_kf:.4f}     | {std_kf:.4f}")
print(f"{'SMA':<15} | {rmse_sma:.4f}     | {std_sma:.4f}")

plt.figure(figsize=(10, 6))
plt.title('Filtr Kalmana')
plt.step(t_vec, y_meas_vec, 'g-', where='mid', alpha=0.3, label='Enkoder')
plt.plot(t_vec, y_true_vec, 'k-', alpha=0.4, linewidth=1, label='Rzeczywisty wał')
plt.plot(t_vec, y_kf_vec, 'b-', linewidth=2, label='Kalman')
plt.ylabel('Prędkość [RPM]')
plt.xlabel('Czas [s]')
plt.legend()
plt.grid(True)
plt.show()


plt.figure(figsize=(10, 6))
plt.title('Porównanie przebiegów czasowych')
plt.step(t_vec, y_meas_vec, 'g-', where='mid', alpha=0.3, label='Enkoder')
plt.plot(t_vec, y_true_vec, 'k-', alpha=0.4, linewidth=1, label='Rzeczywisty wał')
plt.plot(t_vec, y_sma_vec, 'm-', linewidth=2, label=f'SMA')
plt.plot(t_vec, y_kf_vec, 'b-', linewidth=2, label='Kalman')
plt.ylabel('Prędkość [RPM]')
plt.xlabel('Czas [s]')
plt.legend()
plt.grid(True)
plt.show()

plt.figure(figsize=(10, 6))
plt.title('Charakterystyka błędu estymacji (Prawda - Wynik)')
plt.plot(t_vec, error_sma, 'm-', linewidth=1.5, alpha=0.8, label='Błąd SMA')
plt.plot(t_vec, error_kf, 'b-', linewidth=1.5, alpha=0.9, label='Błąd Kalmana')
plt.axhline(0, color='k', linestyle='--', linewidth=1)
plt.ylabel('Wielkość błędu')
plt.xlabel('Czas [s]')
plt.legend()
plt.grid(True)
plt.show()