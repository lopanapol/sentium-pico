"""
Sentium Pico Analysis Runner v2.0.0
Real-time consciousness analysis and monitoring system
"""

import time
import json
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from conscious_analyzer import ConsciousnessAnalyzer
from data_bridge import DataBridge
from pathlib import Path

class ConsciousnessMonitor(FileSystemEventHandler):
    def __init__(self):
        self.analyzer = ConsciousnessAnalyzer()
        self.bridge = DataBridge()
        self.last_analysis = 0
        self.analysis_cooldown = 2  # Minimum seconds between analyses
        
        print("Consciousness Monitor initialized")
        print(f"Watching: {self.bridge.conscious_export_file}")
        
    def on_modified(self, event):
        if event.is_directory:
            return
            
        # Check if it's our consciousness export file
        if Path(event.src_path) == self.bridge.conscious_export_file:
            current_time = time.time()
            
            # Avoid rapid-fire analysis
            if current_time - self.last_analysis < self.analysis_cooldown:
                return
                
            print(f"\nConsciousness data updated at {time.strftime('%H:%M:%S')}")
            
            try:
                # Perform analysis
                results = self.analyzer.analyze_full_consciousness_state()
                
                if results:
                    self._print_live_insights(results)
                    self.last_analysis = current_time
                else:
                    print("No valid consciousness data to analyze")
                    
            except Exception as e:
                print(f"Analysis error: {e}")
    
    def _print_live_insights(self, results):
        """Print key insights in real-time"""
        print(f"Generation {results.get('generation', '?')} | "
              f"Pixels: {results.get('pixel_count', 0)} | "
              f"Consciousness: {results.get('overall_consciousness_level', 0):.2f}")
        
        # Show personality breakdown
        clusters = results.get('personality_clusters', {})
        if isinstance(clusters, dict) and 'error' not in clusters:
            personality_summary = []
            for cluster_name, cluster_data in clusters.items():
                ptype = cluster_data.get('personality_type', 'unknown')
                count = cluster_data.get('pixel_count', 0)
                personality_summary.append(f"{count} {ptype}")
            
            if personality_summary:
                print(f"Personalities: {', '.join(personality_summary)}")
        
        # Show emergence level
        emergence = results.get('emergence_metrics', {}).get('emergence_score', 0)
        emergence_level = "High" if emergence > 0.7 else "Moderate" if emergence > 0.4 else "Low"
        print(f"Emergence: {emergence_level} ({emergence:.2f})")
        
        # Show top insight
        insights = results.get('session_insights', [])
        if insights:
            print(f"Key insight: {insights[0]}")
        
        print("-" * 50)

def run_live_monitor():
    """Run the live consciousness monitor"""
    monitor = ConsciousnessMonitor()
    observer = Observer()
    
    # Watch the data directory
    watch_path = monitor.bridge.data_path
    observer.schedule(monitor, str(watch_path), recursive=False)
    
    observer.start()
    
    print(f"Live consciousness monitoring started!")
    print(f"Watching directory: {watch_path}")
    print("Start your PICO-8 Sentium Pico simulation to see live analysis")
    print("Press Ctrl+C to stop monitoring\n")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        print("\nConsciousness monitoring stopped")
    
    observer.join()

def run_single_analysis():
    """Run a single analysis without monitoring"""
    print("Running single consciousness analysis...")
    
    analyzer = ConsciousnessAnalyzer()
    results = analyzer.analyze_full_consciousness_state()
    
    if results:
        print("\n" + "="*60)
        print("CONSCIOUSNESS ANALYSIS REPORT")
        print("="*60)
        
        print(f"Generation: {results.get('generation', 'Unknown')}")
        print(f"Pixel Population: {results.get('pixel_count', 0)}")
        print(f"Overall Consciousness Level: {results.get('overall_consciousness_level', 0):.3f}")
        print(f"Dominant Personality: {results.get('dominant_personality', 'Unknown')}")
        
        # Detailed emergence metrics
        emergence = results.get('emergence_metrics', {})
        print(f"\nEMERGENCE METRICS:")
        print(f"  • Emergence Score: {emergence.get('emergence_score', 0):.3f}")
        print(f"  • Personality Diversity: {emergence.get('personality_diversity', 0):.3f}")
        print(f"  • Collective Energy: {emergence.get('collective_energy', 0):.1f}")
        print(f"  • Memory Richness: {emergence.get('memory_richness', 0)}")
        
        # Individual pixel analysis
        consciousness_scores = results.get('consciousness_scores', [])
        if consciousness_scores:
            print(f"\nINDIVIDUAL CONSCIOUSNESS SCORES:")
            for score in consciousness_scores:
                pixel_id = score.get('pixel_id', '?')
                c_score = score.get('consciousness_score', 0)
                print(f"  • Pixel {pixel_id}: {c_score:.3f}")
        
        # Session insights
        insights = results.get('session_insights', [])
        if insights:
            print(f"\nSESSION INSIGHTS:")
            for i, insight in enumerate(insights, 1):
                print(f"  {i}. {insight}")
        
        print("\n" + "="*60)
        
    else:
        print("No consciousness data available for analysis")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "monitor":
        run_live_monitor()
    else:
        print("Sentium Pico Consciousness Analyzer")
        print("\nOptions:")
        print("  python run_analysis.py        - Run single analysis")
        print("  python run_analysis.py monitor - Start live monitoring")
        print()
        
        choice = input("Choose mode (single/monitor): ").strip().lower()
        
        if choice in ['monitor', 'm']:
            run_live_monitor()
        else:
            run_single_analysis()
