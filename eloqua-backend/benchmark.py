"""
benchmark.py  —  Eloqua PDC Speedup Demonstration
===================================================
Run this script during your presentation to prove that parallel and
distributed computing genuinely reduces processing time.

Usage:
    python benchmark.py

It will run the SEQUENTIAL version first, then the PARALLEL version,
on the same pre-transcribed text, and print a clear speedup comparison.
"""

import time
import sys
from concurrent.futures import ThreadPoolExecutor

# ── Separator helper ──────────────────────────────────────────────────────────
def section(title):
    print(f"\n{'='*55}")
    print(f"  {title}")
    print(f"{'='*55}")

def result_line(label, value):
    print(f"  {label:<30} {value}")

# ── Load models (one-time, serial — not part of benchmark) ───────────────────
section("Loading models (one-time startup, not benchmarked)...")
from analyzer import transcribe, detect_fillers, analyze_pacing, check_grammar
print("  Warming up LanguageTool server...")
check_grammar("Warm up text.")
print("  ✓ Whisper + LanguageTool loaded and warmed up.")

# ── Use a real or synthetic transcript for fair comparison ───────────────────
# We benchmark AFTER transcription so both runs use identical input.
# Transcription is serial in both cases (it MUST finish before anything else).
SAMPLE_TRANSCRIPT = """
Good morning everyone. Today I would like to talk about the importance of 
parallel and distributed computing in modern software development. 
As we can see in many real-world applications, processing large amounts of 
data sequentially can be extremely slow and inefficient. By distributing 
tasks across multiple threads or processes, we can significantly reduce 
the total processing time. For example, in our application called Eloqua, 
we process speech recordings by checking grammar, detecting filler words, 
and analyzing speaking pace. These three tasks are completely independent 
of each other once we have the transcript. So there is absolutely no reason 
they need to run one after another. By running them in parallel using Python 
thread pools, we reduce the time for this phase by up to three times. 
Similarly, our body language analysis processes video frames which are 
also completely independent of each other. We split the frames across 
CPU cores using multiprocessing and aggregate the results at the end.
This is a classic example of data parallelism in action. Thank you.
""".strip()

SAMPLE_DURATION = 90.0  # simulate a ~90 second speech

print(f"\n  Using transcript: {len(SAMPLE_TRANSCRIPT.split())} words, "
      f"{SAMPLE_DURATION:.0f}s duration")

# ═══════════════════════════════════════════════════════════════════════════════
# BENCHMARK 1: SEQUENTIAL (old approach)
# ═══════════════════════════════════════════════════════════════════════════════
section("BENCHMARK 1 — SEQUENTIAL (old code, tasks run one after another)")
print()

t_seq_start = time.perf_counter()

print("  [1/3] Running detect_fillers()...", end=" ", flush=True)
t1 = time.perf_counter()
fillers_result = detect_fillers(SAMPLE_TRANSCRIPT)
t_fillers = time.perf_counter() - t1
print(f"done in {t_fillers:.3f}s")

print("  [2/3] Running analyze_pacing()...", end=" ", flush=True)
t2 = time.perf_counter()
pacing_result = analyze_pacing(SAMPLE_TRANSCRIPT, SAMPLE_DURATION)
t_pacing = time.perf_counter() - t2
print(f"done in {t_pacing:.3f}s")

print("  [3/3] Running check_grammar()...", end=" ", flush=True)
t3 = time.perf_counter()
grammar_result = check_grammar(SAMPLE_TRANSCRIPT)
t_grammar = time.perf_counter() - t3
print(f"done in {t_grammar:.3f}s")

t_sequential = time.perf_counter() - t_seq_start

print()
result_line("Filler detection time:", f"{t_fillers:.3f}s")
result_line("Pacing analysis time:", f"{t_pacing:.3f}s")
result_line("Grammar check time:", f"{t_grammar:.3f}s")
result_line("─" * 35, "")
result_line("TOTAL SEQUENTIAL TIME:", f"{t_sequential:.3f}s  ⬅ baseline")

# ═══════════════════════════════════════════════════════════════════════════════
# BENCHMARK 2: PARALLEL with ThreadPoolExecutor (new approach)
# ═══════════════════════════════════════════════════════════════════════════════
section("BENCHMARK 2 — PARALLEL (new code, ThreadPoolExecutor, 3 workers)")
print()

t_par_start = time.perf_counter()

print("  Submitting all 3 tasks simultaneously...")
with ThreadPoolExecutor(max_workers=3) as executor:
    t_submit = time.perf_counter()
    future_fillers = executor.submit(detect_fillers, SAMPLE_TRANSCRIPT)
    future_pacing  = executor.submit(analyze_pacing, SAMPLE_TRANSCRIPT, SAMPLE_DURATION)
    future_grammar = executor.submit(check_grammar, SAMPLE_TRANSCRIPT)

    print("  Waiting for all threads to complete...")
    fillers_r = future_fillers.result()
    pacing_r  = future_pacing.result()
    grammar_r = future_grammar.result()

t_parallel = time.perf_counter() - t_par_start

print()
result_line("Wall-clock time (all 3 in parallel):", f"{t_parallel:.3f}s  ⬅ parallel")

# ═══════════════════════════════════════════════════════════════════════════════
# RESULTS SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════
section("RESULTS — PDC Speedup Summary")
print()

speedup      = t_sequential / t_parallel if t_parallel > 0 else 1
time_saved   = t_sequential - t_parallel
pct_faster   = (1 - t_parallel / t_sequential) * 100 if t_sequential > 0 else 0

result_line("Sequential total time:", f"{t_sequential:.3f}s")
result_line("Parallel total time:", f"{t_parallel:.3f}s")
result_line("Time saved:", f"{time_saved:.3f}s")
result_line("Speedup ratio:", f"{speedup:.2f}x  🚀")
result_line("Percentage faster:", f"{pct_faster:.1f}%")

print()
print("  ── Amdahl's Law Check ──────────────────────────────────")
# The serial fraction S is approx 0 for this phase (all 3 tasks are parallel)
# Theoretical max speedup with 3 workers = 3x (if perfectly parallel)
# Actual speedup < 3x due to GIL, thread overhead, LanguageTool bottleneck
theoretical_max = 3.0
efficiency = (speedup / theoretical_max) * 100
result_line("Theoretical max speedup (3 workers):", f"{theoretical_max:.1f}x")
result_line("Actual speedup achieved:", f"{speedup:.2f}x")
result_line("Parallel efficiency:", f"{efficiency:.1f}%")

print()
if speedup >= 1.5:
    print("  ✅ RESULT: Parallelism significantly reduced processing time.")
elif speedup >= 1.1:
    print("  ✅ RESULT: Parallelism reduced processing time (GIL limits further gains).")
else:
    print("  ⚠ RESULT: Minimal speedup — LanguageTool may be the bottleneck.")

print()
print("  Note: The remaining bottleneck is Whisper transcription (~70% of total")
print("  request time), which MUST be serial because everything else depends on")
print("  the transcript. This is the 'serial fraction' in Amdahl's Law.")
print()
print("="*55)
print("  Benchmark complete.")
print("="*55)
