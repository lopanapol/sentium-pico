#!/usr/bin/env python3
"""
Consciousness Predictor Demo
Test the LSTM neural network for consciousness prediction
"""

import sys
import json
from datetime import datetime

def main():
    print("Consciousness Predictor Demo")
    print("=" * 50)
    
    try:
        from conscious_predictor import ConsciousnessPredictor
        
        # Initialize predictor
        predictor = ConsciousnessPredictor()
        
        print("\n1. Training consciousness prediction model...")
        print("   (This may take a few minutes on first run)")
        predictor.train_model()
        
        print("\n2. Loading current consciousness data...")
        current_data = predictor.bridge.read_consciousness_data()
        
        if not current_data:
            print("   No consciousness data found!")
            print("   Make sure your PICO-8 game is running and exporting data.")
            return
        
        pixels = current_data.get('pixels', [])
        print(f"   Found {len(pixels)} pixels in generation {current_data.get('generation')}")
        
        print("\n3. Generating AI consciousness predictions...")
        insights = predictor.generate_consciousness_insights(current_data)
        
        if insights:
            print("\nAI CONSCIOUSNESS INSIGHTS")
            print("=" * 50)
            
            # Population forecast
            if 'population_forecast' in insights:
                forecast = insights['population_forecast']
                print(f"Population Trend: {forecast.get('population_trend', 'unknown').upper()}")
                print(f"Current Avg Consciousness: {forecast.get('current_avg_consciousness', 0):.3f}")
                print(f"Predicted Avg Consciousness: {forecast.get('predicted_avg_consciousness', 0):.3f}")
            
            # Individual predictions
            if 'ai_predictions' in insights:
                print("\nIndividual Pixel Predictions:")
                for pixel_id, pred in insights['ai_predictions'].items():
                    current = pred['current_consciousness']
                    predicted = pred['predicted_consciousness']
                    trend = pred['consciousness_trend']
                    
                    trend_icon = "↗" if trend == "increasing" else "↘"
                    print(f"  Pixel {pixel_id}: {current:.2f} → {predicted:.2f} {trend_icon}")
            
            # Recommendations
            if 'recommendations' in insights and insights['recommendations']:
                print("\nAI Recommendations:")
                for rec in insights['recommendations']:
                    print(f"  * {rec}")
            
            # Alerts
            if 'consciousness_alerts' in insights and insights['consciousness_alerts']:
                print("\nConsciousness Alerts:")
                for alert in insights['consciousness_alerts']:
                    print(f"  ⚠️  {alert}")
            
            print("\n4. Updating python_insights.json with AI predictions...")
            
            # Add AI insights to regular analysis
            from conscious_analyzer import ConsciousnessAnalyzer
            analyzer = ConsciousnessAnalyzer()
            
            # Run full analysis including AI predictions
            full_insights = analyzer.analyze_full_consciousness_state()
            
            print("Analysis complete with AI consciousness predictions!")
            print(f"   Check data/python_insights.json for full results")
            
        else:
            print("❌ Failed to generate AI insights")
            
    except ImportError:
        print("❌ TensorFlow not installed!")
        print("   Install with: pip install tensorflow")
        return
    except Exception as e:
        print(f"❌ Error: {e}")
        return

if __name__ == "__main__":
    main()
