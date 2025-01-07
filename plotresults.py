import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV file
csv_file = "/users/atirumal/trytesting/try_timings.csv"  
data = pd.read_csv(csv_file)

# Calculate the average time for each step (ignoring  exec round column)
average_timings = data.iloc[:, 1:].mean()

# Create the plot
plt.figure(figsize=(12, 6))
average_timings.plot(kind='bar', color='skyblue', edgecolor='black')

plt.title("Average Timing for Each Step in the Try Script", fontsize=16)
plt.ylabel("Time from start (seconds)", fontsize=14)
plt.xlabel("Steps", fontsize=14)
plt.xticks(rotation=45, ha='right', fontsize=12)
plt.grid(axis='y', linestyle='--', alpha=0.7)

plt.gca().yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f"{x:.3f}"))

for index, value in enumerate(average_timings):
    plt.text(index, value + 0.01, f"{value:.3f}", ha='center', fontsize=10)

plt.tight_layout()
plt.savefig("average_timings_plot.png", dpi=300)
plt.show()

