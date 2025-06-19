import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import json
import time
from datetime import datetime
from data_bridge import DataBridge

class ConsciousnessAnalyzer:
    def __init__(self):
        self.bridge = DataBridge()
        self.personality_clusters = None
        self.behavior_patterns = {}
        self.consciousness_metrics = {}
        
    def analyze_pixel_consciousness(self, pixel_data):
        """Analyze individual pixel consciousness metrics"""
        consciousness_scores = []
        
        for pixel in pixel_data:
            # Calculate consciousness score based on multiple factors
            memory_depth = len(pixel.get('memory', []))
            personality_complexity = abs(pixel.get('curiosity', 0.5) - pixel.get('timidity', 0.5))
            behavioral_autonomy = pixel.get('energy', 0) / max(pixel.get('age', 1), 1)
            
            # Weighted consciousness score
            consciousness_score = (
                memory_depth * 0.3 +
                personality_complexity * 0.4 +
                behavioral_autonomy * 0.3
            )
            
            consciousness_scores.append({
                'pixel_id': pixel.get('id'),
                'consciousness_score': consciousness_score,
                'memory_depth': memory_depth,
                'personality_complexity': personality_complexity,
                'behavioral_autonomy': behavioral_autonomy
            })
        
        return consciousness_scores
    
    def analyze_personality_clusters(self, pixels):
        """Cluster pixels by personality traits"""
        if len(pixels) < 2:
            return {"error": "Need at least 2 pixels for clustering"}
        
        # Extract personality features
        features = []
        pixel_ids = []
        
        for pixel in pixels:
            features.append([
                pixel.get('curiosity', 0.5),
                pixel.get('timidity', 0.5),
                pixel.get('energy', 0) / 30.0,  # Normalize energy
                len(pixel.get('memory', [])) / 10.0  # Normalize memory depth
            ])
            pixel_ids.append(pixel.get('id'))
        
        features = np.array(features)
        
        # Standardize features
        scaler = StandardScaler()
        features_scaled = scaler.fit_transform(features)
        
        # Determine optimal number of clusters (max 3 for small datasets)
        n_clusters = min(3, len(pixels))
        
        # Perform clustering
        kmeans = KMeans(n_clusters=n_clusters, random_state=42)
        clusters = kmeans.fit_predict(features_scaled)
        
        # Analyze cluster characteristics
        cluster_analysis = {}
        for i in range(n_clusters):
            cluster_pixels = [pixels[j] for j in range(len(pixels)) if clusters[j] == i]
            
            avg_curiosity = np.mean([p.get('curiosity', 0.5) for p in cluster_pixels])
            avg_timidity = np.mean([p.get('timidity', 0.5) for p in cluster_pixels])
            
            # Classify personality type
            if avg_curiosity > 0.6 and avg_timidity < 0.4:
                personality_type = "explorer"
            elif avg_curiosity < 0.4 and avg_timidity > 0.6:
                personality_type = "cautious"
            else:
                personality_type = "balanced"
            
            cluster_analysis[f"cluster_{i}"] = {
                "personality_type": personality_type,
                "avg_curiosity": float(avg_curiosity),
                "avg_timidity": float(avg_timidity),
                "pixel_count": len(cluster_pixels),
                "pixel_ids": [p.get('id') for p in cluster_pixels]
            }
        
        return cluster_analysis
    
    def predict_behavior(self, pixels, cursor_data):
        """Predict likely pixel behaviors based on current state"""
        predictions = {}
        
        cursor_aware = cursor_data.get('is_aware', False)
        attention_level = cursor_data.get('attention_level', 0)
        
        for pixel in pixels:
            curiosity = pixel.get('curiosity', 0.5)
            timidity = pixel.get('timidity', 0.5)
            energy = pixel.get('energy', 0)
            
            # Predict cursor interaction behavior
            if cursor_aware:
                approach_probability = curiosity * attention_level - timidity * 0.5
                flee_probability = timidity * attention_level - curiosity * 0.3
            else:
                approach_probability = 0.1
                flee_probability = 0.1
            
            # Predict division likelihood
            division_probability = 0 if energy < 20 else (energy - 20) / 10.0 * 0.8
            
            # Predict death risk
            death_risk = 0.1 if energy > 5 else 0.8
            
            predictions[pixel.get('id')] = {
                "approach_cursor": max(0, min(1, approach_probability)),
                "flee_from_cursor": max(0, min(1, flee_probability)),
                "likely_to_divide": max(0, min(1, division_probability)),
                "death_risk": max(0, min(1, death_risk)),
                "predicted_action": self._get_dominant_prediction(
                    approach_probability, flee_probability, division_probability, death_risk
                )
            }
        
        return predictions
    
    def _get_dominant_prediction(self, approach, flee, divide, death):
        """Get the most likely action"""
        actions = {
            "approach_cursor": approach,
            "flee_cursor": flee,
            "divide": divide,
            "maintain_status": 0.5,
            "death": death
        }
        return max(actions, key=actions.get)
    
    def calculate_emergence_metrics(self, data):
        """Calculate metrics for emergent behavior"""
        pixels = data.get('pixels', [])
        generation = data.get('generation', 1)
        
        if not pixels:
            return {"error": "No pixels to analyze"}
        
        # Diversity metrics
        curiosity_values = [p.get('curiosity', 0.5) for p in pixels]
        timidity_values = [p.get('timidity', 0.5) for p in pixels]
        
        curiosity_diversity = np.std(curiosity_values)
        timidity_diversity = np.std(timidity_values)
        
        # Collective behavior metrics
        avg_energy = np.mean([p.get('energy', 0) for p in pixels])
        total_memory_events = sum(len(p.get('memory', [])) for p in pixels)
        
        # Evolution pressure
        evolution_pressure = generation * 0.1 + curiosity_diversity + timidity_diversity
        
        return {
            "personality_diversity": float(curiosity_diversity + timidity_diversity),
            "collective_energy": float(avg_energy),
            "memory_richness": total_memory_events,
            "evolution_pressure": float(evolution_pressure),
            "emergence_score": float((
                curiosity_diversity * 0.3 +
                timidity_diversity * 0.3 +
                (total_memory_events / len(pixels)) * 0.4
            ))
        }
    
    def analyze_full_consciousness_state(self):
        """Perform complete consciousness analysis"""
        print("Starting consciousness analysis...")
        
        # Read data from PICO-8
        data = self.bridge.read_consciousness_data()
        if not data:
            print("No consciousness data available")
            return None
        
        pixels = data.get('pixels', [])
        cursor_data = data.get('cursor_interaction', {})
        
        print(f"Analyzing {len(pixels)} pixels from generation {data.get('generation')}")
        
        # Perform all analyses
        consciousness_scores = self.analyze_pixel_consciousness(pixels)
        personality_clusters = self.analyze_personality_clusters(pixels)
        behavior_predictions = self.predict_behavior(pixels, cursor_data)
        emergence_metrics = self.calculate_emergence_metrics(data)
        
        # Compile comprehensive insights
        insights = {
            "analysis_timestamp": datetime.now().isoformat(),
            "generation": data.get('generation'),
            "pixel_count": len(pixels),
            "consciousness_scores": consciousness_scores,
            "personality_clusters": personality_clusters,
            "behavior_predictions": behavior_predictions,
            "emergence_metrics": emergence_metrics,
            "overall_consciousness_level": float(np.mean([
                score['consciousness_score'] for score in consciousness_scores
            ])) if consciousness_scores else 0,
            "dominant_personality": self._get_dominant_personality(personality_clusters),
            "session_insights": self._generate_session_insights(data, emergence_metrics)
        }
        
        # Write insights back to PICO-8
        self.bridge.write_insights(insights)
        
        # Log session data
        self.bridge.log_session_data(data)
        
        print(f"Analysis complete! Overall consciousness level: {insights['overall_consciousness_level']:.2f}")
        
        return insights
    
    def _get_dominant_personality(self, clusters):
        """Determine the dominant personality type in the population"""
        if isinstance(clusters, dict) and 'error' not in clusters:
            personality_counts = {}
            for cluster_data in clusters.values():
                ptype = cluster_data.get('personality_type', 'unknown')
                count = cluster_data.get('pixel_count', 0)
                personality_counts[ptype] = personality_counts.get(ptype, 0) + count
            
            if personality_counts:
                return max(personality_counts, key=personality_counts.get)
        
        return "unknown"
    
    def _generate_session_insights(self, data, emergence_metrics):
        """Generate human-readable insights about the session"""
        insights = []
        
        pixels = data.get('pixels', [])
        generation = data.get('generation', 1)
        
        # Generation insights
        if generation > 10:
            insights.append(f"Advanced evolution: Generation {generation} shows mature ecosystem")
        elif generation > 5:
            insights.append(f"Developing complexity: Generation {generation} building diversity")
        else:
            insights.append(f"Early stage: Generation {generation} still evolving")
        
        # Population insights
        if len(pixels) >= 6:
            insights.append("Thriving population with high survival rates")
        elif len(pixels) >= 3:
            insights.append("Stable population maintaining balance")
        else:
            insights.append("Small population - critical survival phase")
        
        # Behavior insights
        emergence_score = emergence_metrics.get('emergence_score', 0)
        if emergence_score > 0.7:
            insights.append("High emergence: Complex behaviors developing")
        elif emergence_score > 0.4:
            insights.append("Moderate emergence: Interesting patterns forming")
        else:
            insights.append("Low emergence: Simple behavioral patterns")
        
        # Cursor interaction insights
        cursor_data = data.get('cursor_interaction', {})
        if cursor_data.get('is_aware', False):
            attention = cursor_data.get('attention_level', 0)
            if attention > 0.7:
                insights.append("High cursor awareness: Pixels actively responding to presence")
            elif attention > 0.3:
                insights.append("Moderate cursor awareness: Some pixels noticing interaction")
            else:
                insights.append("Low cursor awareness: Minimal response to presence")
        
        return insights

if __name__ == "__main__":
    analyzer = ConsciousnessAnalyzer()
    results = analyzer.analyze_full_consciousness_state()
    
    if results:
        print("\nKey Insights:")
        for insight in results.get('session_insights', []):
            print(f"  • {insight}")
        
        print(f"\nConsciousness Level: {results['overall_consciousness_level']:.2f}")
        print(f"Dominant Personality: {results['dominant_personality']}")
        print(f"Emergence Score: {results['emergence_metrics']['emergence_score']:.2f}")
