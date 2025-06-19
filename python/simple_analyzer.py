"""
Sentium Pico Simple Consciousness Analyzer v2.0.0
Lightweight consciousness analysis without heavy ML dependencies
"""

import json
import time
from datetime import datetime
from data_bridge import DataBridge

class SimpleConsciousnessAnalyzer:
    def __init__(self):
        self.bridge = DataBridge()
    
    def analyze_consciousness(self):
        """Simple consciousness analysis without heavy ML dependencies"""
        print("Starting simple consciousness analysis...")
        
        # Read data from PICO-8
        data = self.bridge.read_consciousness_data()
        if not data:
            print("No consciousness data available")
            return None
        
        pixels = data.get('pixels', [])
        cursor_data = data.get('cursor_interaction', {})
        generation = data.get('generation', 1)
        
        print(f"Analyzing {len(pixels)} pixels from generation {generation}")
        
        # Simple consciousness scoring
        consciousness_scores = []
        for pixel in pixels:
            memory_depth = len(pixel.get('memory', []))
            curiosity = pixel.get('curiosity', 0.5)
            timidity = pixel.get('timidity', 0.5)
            energy = pixel.get('energy', 0)
            
            # Simple consciousness formula
            personality_complexity = abs(curiosity - timidity)
            consciousness_score = (memory_depth * 0.3 + personality_complexity * 0.4 + energy/30 * 0.3)
            
            consciousness_scores.append({
                'pixel_id': pixel.get('id'),
                'consciousness_score': consciousness_score,
                'personality': 'curious' if curiosity > timidity else 'timid' if timidity > curiosity else 'balanced'
            })
        
        # Calculate averages
        avg_consciousness = sum(s['consciousness_score'] for s in consciousness_scores) / len(consciousness_scores) if consciousness_scores else 0
        
        # Personality distribution
        personality_counts = {}
        for score in consciousness_scores:
            ptype = score['personality']
            personality_counts[ptype] = personality_counts.get(ptype, 0) + 1
        
        dominant_personality = max(personality_counts, key=personality_counts.get) if personality_counts else 'unknown'
        
        # Generate insights
        insights = {
            "analysis_timestamp": datetime.now().isoformat(),
            "generation": generation,
            "pixel_count": len(pixels),
            "consciousness_scores": consciousness_scores,
            "overall_consciousness_level": float(avg_consciousness),
            "dominant_personality": dominant_personality,
            "personality_distribution": personality_counts,
            "cursor_awareness": cursor_data.get('is_aware', False),
            "attention_level": cursor_data.get('attention_level', 0),
            "session_insights": self._generate_insights(data, avg_consciousness, personality_counts)
        }
        
        # Write insights back
        self.bridge.write_insights(insights)
        self.bridge.log_session_data(data)
        
        return insights
    
    def _generate_insights(self, data, avg_consciousness, personality_counts):
        """Generate simple insights"""
        insights = []
        
        generation = data.get('generation', 1)
        pixel_count = len(data.get('pixels', []))
        
        # Generation insights
        if generation > 10:
            insights.append(f"Mature ecosystem at generation {generation}")
        elif generation > 5:
            insights.append(f"Developing complexity at generation {generation}")
        else:
            insights.append(f"Early evolution stage - generation {generation}")
        
        # Population insights
        if pixel_count >= 6:
            insights.append("Thriving population with high survival")
        elif pixel_count >= 3:
            insights.append("Stable population balance")
        else:
            insights.append("Small population in survival mode")
        
        # Consciousness insights
        if avg_consciousness > 0.7:
            insights.append("High consciousness levels detected")
        elif avg_consciousness > 0.4:
            insights.append("Moderate consciousness emergence")
        else:
            insights.append("Simple behavioral patterns")
        
        # Personality insights
        if personality_counts:
            dominant = max(personality_counts, key=personality_counts.get)
            count = personality_counts[dominant]
            insights.append(f"Population dominated by {dominant} personalities ({count} pixels)")
        
        return insights

if __name__ == "__main__":
    analyzer = SimpleConsciousnessAnalyzer()
    results = analyzer.analyze_consciousness()
    
    if results:
        print("\n" + "="*50)
        print("CONSCIOUSNESS ANALYSIS REPORT")
        print("="*50)
        
        print(f"Generation: {results.get('generation', 'Unknown')}")
        print(f"Pixel Population: {results.get('pixel_count', 0)}")
        print(f"Overall Consciousness: {results.get('overall_consciousness_level', 0):.3f}")
        print(f"Dominant Personality: {results.get('dominant_personality', 'Unknown')}")
        print(f"Cursor Awareness: {'Yes' if results.get('cursor_awareness') else 'No'}")
        print(f"Attention Level: {results.get('attention_level', 0):.2f}")
        
        # Individual scores
        print(f"\nINDIVIDUAL CONSCIOUSNESS:")
        for score in results.get('consciousness_scores', []):
            pixel_id = score.get('pixel_id', '?')
            c_score = score.get('consciousness_score', 0)
            personality = score.get('personality', 'unknown')
            print(f"  • Pixel {pixel_id}: {c_score:.3f} ({personality})")
        
        # Personality distribution
        dist = results.get('personality_distribution', {})
        if dist:
            print(f"\nPERSONALITY DISTRIBUTION:")
            for ptype, count in dist.items():
                print(f"  • {ptype.title()}: {count} pixels")
        
        # Insights
        insights = results.get('session_insights', [])
        if insights:
            print(f"\nKEY INSIGHTS:")
            for i, insight in enumerate(insights, 1):
                print(f"  {i}. {insight}")
        
        print("\n" + "="*50)
    else:
        print("Analysis failed - no data available")
