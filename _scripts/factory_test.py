import os
import subprocess
import json
import torch
import soundfile as sf
from kokoro import K6

def log_vram():
    try:
        res = subprocess.check_output(["nvidia-smi", "--query-gpu=memory.used", "--format=csv,noheader,nounits"], encoding="utf-8")
        print(f"Current VRAM Usage: {res.strip()} MiB")
    except Exception as e:
        print(f"Failed to log VRAM: {e}")

def main():
    print("--- Factory Integration Test ---")
    log_vram()

    # Step 1: Gemma3:12b writes a racing teaser
    print("Step 1: Gemma3:12b writing teaser...")
    prompt = "Write a 1-sentence racing teaser for Evolution Stables. Short and punchy."
    try:
        teaser = subprocess.check_output(["ollama", "run", "gemma3:12b", prompt], encoding="utf-8").strip()
        print(f"Teaser: {teaser}")
    except Exception as e:
        teaser = "Evolution Stables: Where champions are born and legends race."
        print(f"Ollama call failed (using fallback): {e}")

    # Step 2: Kokoro speaks it
    print("Step 2: Kokoro generating audio...")
    try:
        # Load Kokoro model
        from kokoro import KPipeline
        pipeline = KPipeline(lang_code='a')
        generator = pipeline(teaser, voice='af_heart', speed=1)
        for i, (gs, ps, audio) in enumerate(generator):
            output_path = "/home/evo/_output/factory_test.wav"
            sf.write(output_path, audio, 24000)
            print(f"Audio saved to {output_path} (Size: {os.path.getsize(output_path)} bytes)")
    except Exception as e:
        print(f"Kokoro generation failed: {e}")

    log_vram()
    print("--- Test Complete ---")

if __name__ == "__main__":
    main()
