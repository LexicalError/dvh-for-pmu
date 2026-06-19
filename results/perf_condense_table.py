import pandas as pd

# 1. Define your files mapping
# Ensure these match the filenames you used in your bash script
files = {
    'L2 (No perf)': 'perf_baseline.csv',
    'L2': 'perf_no_dvh.csv',
    'L2-DVH': 'perf_dvh.csv'
}

# 2. Read the CSVs and calculate the average time for each configuration
means = {}
for config_name, file_path in files.items():
    try:
        df = pd.read_csv(file_path)
        # Calculate the mean of the 10 iterations
        means[config_name] = df['Time_sec'].mean()
    except FileNotFoundError:
        print(f"Warning: {file_path} not found. Ensure the script has been run.")
        exit(1)

# 3. Extract the means for overhead calculation
base_time = means['L2 (No perf)']
emu_time = means['L2']
dvh_time = means['L2-DVH']

# 4. Calculate Overhead Percentages
# Formula: ((Instrumented - Baseline) / Baseline) * 100
emu_overhead = ((emu_time - base_time) / base_time) * 100
dvh_overhead = ((dvh_time - base_time) / base_time) * 100

# 5. Create a Summary DataFrame
summary_data = {
    'Configuration': ['L2', 'L2-DVH'],
    'Avg. Time (s)': [emu_time, dvh_time],
    'Overhead (%)': [emu_overhead, dvh_overhead]
}
df_summary = pd.DataFrame(summary_data)

# 6. Generate the LaTeX Table
print(f"--- Baseline Average Time: {base_time:.3f} seconds ---\n")

# FIXED: Using % formatting so Python ignores the LaTeX curly braces
table_caption = "Performance overhead of PMU virtualization during highly-concurrent scheduler stress testing (\\texttt{perf bench sched messaging}). Baseline uninstrumented execution time was %.2fs." % base_time

latex_table = df_summary.to_latex(
    index=False,           
    float_format="%.2f",   
    column_format="lcc",   
    caption=table_caption,
    label="tab:perf_bench_overhead"
)

print(latex_table)