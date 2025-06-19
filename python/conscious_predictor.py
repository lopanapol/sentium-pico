"""
Sentium Pico Consciousness Predictor v2.0.0
LSTM neural network for consciousness prediction and evolution analysis
"""

import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Sequential, load_model
from tensorflow.keras.layers import LSTM, Dense, Dropout, Attention, Input
from tensorflow.keras.optimizers import Adam
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error, mean_absolute_error
import json
import os
from datetime import datetime
from pathlib import Path
from data_bridge import DataBridge

class ConsciousnessPredictor:
    def __init__(self):
        self.bridge = DataBridge()
        self.model = None
        self.scaler = MinMaxScaler()
        self.sequence_length = 10  # Look back 10 time steps
        self.model_path = "conscious_predictor_model.h5"
        self.scaler_path = "consciousness_scaler.pkl"
        
        # Features to use for prediction
        self.features = [
            'curiosity', 'timidity', 'energy', 'age', 'memory_depth',
            'generation', 'pixel_count', 'consciousness_score'
        ]
        
        print("Consciousness Predictor initialized")
    
    def load_historical_data(self):
        """Load all historical session data for training"""
        print("Loading historical consciousness data...")
        
        session_logs_path = self.bridge.session_logs_path
        all_data = []
        
        # Load all session log files
        for session_file in session_logs_path.glob("session_*.json"):
            try:
                with open(session_file, 'r') as f:
                    session_data = json.load(f)
                    
                # Extract pixel data with timestamps
                if 'pixels' in session_data:
                    for pixel in session_data['pixels']:
                        pixel_record = {
                            'timestamp': session_data.get('timestamp', 0),
                            'generation': session_data.get('generation', 1),
                            'pixel_count': session_data.get('pixel_count', 1),
                            'pixel_id': pixel.get('id', 0),
                            'curiosity': pixel.get('curiosity', 0.5),
                            'timidity': pixel.get('timidity', 0.5),
                            'energy': pixel.get('energy', 0),
                            'age': pixel.get('age', 1),
                            'memory_depth': len(pixel.get('memory', [])),
                            'consciousness_score': 0  # Will be calculated
                        }
                        
                        # Calculate consciousness score
                        pixel_record['consciousness_score'] = self._calculate_consciousness_score(pixel_record)
                        all_data.append(pixel_record)
                        
            except Exception as e:
                print(f"Error loading {session_file}: {e}")
        
        if not all_data:
            print("No historical data found. Generating synthetic data for initial training...")
            return self._generate_synthetic_data()
        
        df = pd.DataFrame(all_data)
        df = df.sort_values(['pixel_id', 'timestamp'])
        
        print(f"Loaded {len(df)} consciousness records from {len(df['pixel_id'].unique())} pixels")
        return df
    
    def _calculate_consciousness_score(self, pixel_data):
        """Calculate consciousness score from pixel features"""
        memory_depth = pixel_data['memory_depth']
        personality_complexity = abs(pixel_data['curiosity'] - pixel_data['timidity'])
        behavioral_autonomy = pixel_data['energy'] / max(pixel_data['age'], 1)
        
        consciousness_score = (
            memory_depth * 0.3 +
            personality_complexity * 0.4 +
            behavioral_autonomy * 0.3
        )
        
        return consciousness_score
    
    def _generate_synthetic_data(self):
        """Generate synthetic consciousness data for initial training"""
        print("Generating synthetic consciousness data...")
        
        synthetic_data = []
        n_pixels = 5
        n_timesteps = 50
        
        for pixel_id in range(1, n_pixels + 1):
            # Each pixel has evolving traits over time
            base_curiosity = np.random.uniform(0.2, 0.8)
            base_timidity = 1.0 - base_curiosity + np.random.uniform(-0.2, 0.2)
            base_timidity = np.clip(base_timidity, 0, 1)
            
            for t in range(n_timesteps):
                # Evolving traits with some noise
                curiosity = base_curiosity + np.random.normal(0, 0.1)
                timidity = base_timidity + np.random.normal(0, 0.1)
                curiosity = np.clip(curiosity, 0, 1)
                timidity = np.clip(timidity, 0, 1)
                
                energy = np.random.uniform(5, 30)
                age = t + 1
                memory_depth = min(t // 5, 10)  # Memory grows slowly
                generation = t // 10 + 1
                
                pixel_record = {
                    'timestamp': t,
                    'generation': generation,
                    'pixel_count': n_pixels,
                    'pixel_id': pixel_id,
                    'curiosity': curiosity,
                    'timidity': timidity,
                    'energy': energy,
                    'age': age,
                    'memory_depth': memory_depth,
                    'consciousness_score': 0
                }
                
                # Calculate consciousness with some trend
                consciousness_trend = np.sin(t * 0.1) * 0.5 + t * 0.02
                pixel_record['consciousness_score'] = self._calculate_consciousness_score(pixel_record) + consciousness_trend
                
                synthetic_data.append(pixel_record)
        
        df = pd.DataFrame(synthetic_data)
        print(f"Generated {len(df)} synthetic consciousness records")
        return df
    
    def prepare_sequences(self, df):
        """Prepare time series sequences for LSTM training"""
        print("Preparing time series sequences...")
        
        sequences = []
        targets = []
        
        # Group by pixel_id to create sequences
        for pixel_id in df['pixel_id'].unique():
            pixel_data = df[df['pixel_id'] == pixel_id].sort_values('timestamp')
            
            if len(pixel_data) < self.sequence_length + 1:
                continue
                
            # Extract feature matrix
            feature_data = pixel_data[self.features].values
            
            # Create sequences
            for i in range(len(feature_data) - self.sequence_length):
                # Input: sequence_length timesteps
                sequence = feature_data[i:(i + self.sequence_length)]
                # Target: next timestep's consciousness score
                target = feature_data[i + self.sequence_length][-1]  # consciousness_score is last feature
                
                sequences.append(sequence)
                targets.append(target)
        
        X = np.array(sequences)
        y = np.array(targets)
        
        print(f"Created {len(X)} sequences with shape {X.shape}")
        return X, y
    
    def build_model(self, input_shape):
        """Build LSTM model for consciousness prediction"""
        print("Building LSTM consciousness prediction model...")
        
        model = Sequential([
            LSTM(64, return_sequences=True, input_shape=input_shape),
            Dropout(0.2),
            LSTM(32, return_sequences=False),
            Dropout(0.2),
            Dense(16, activation='relu'),
            Dense(1, activation='linear')  # Consciousness score output
        ])
        
        model.compile(
            optimizer=Adam(learning_rate=0.001),
            loss='mse',
            metrics=['mae']
        )
        
        print("Model architecture:")
        model.summary()
        return model
    
    def train_model(self, retrain=False):
        """Train the consciousness prediction model"""
        if os.path.exists(self.model_path) and not retrain:
            print("Loading existing model...")
            self.model = load_model(self.model_path)
            return
        
        print("Training new consciousness prediction model...")
        
        # Load and prepare data
        df = self.load_historical_data()
        X, y = self.prepare_sequences(df)
        
        if len(X) == 0:
            print("No valid sequences found for training!")
            return
        
        # Normalize data
        X_reshaped = X.reshape(-1, X.shape[-1])
        X_scaled = self.scaler.fit_transform(X_reshaped)
        X_scaled = X_scaled.reshape(X.shape)
        
        # Split train/validation
        split_idx = int(0.8 * len(X_scaled))
        X_train, X_val = X_scaled[:split_idx], X_scaled[split_idx:]
        y_train, y_val = y[:split_idx], y[split_idx:]
        
        # Build and train model
        self.model = self.build_model((self.sequence_length, len(self.features)))
        
        history = self.model.fit(
            X_train, y_train,
            validation_data=(X_val, y_val),
            epochs=50,
            batch_size=32,
            verbose=1,
            callbacks=[
                tf.keras.callbacks.EarlyStopping(patience=10, restore_best_weights=True),
                tf.keras.callbacks.ReduceLROnPlateau(patience=5, factor=0.5)
            ]
        )
        
        # Save model
        self.model.save(self.model_path)
        
        # Evaluate
        val_pred = self.model.predict(X_val)
        mse = mean_squared_error(y_val, val_pred)
        mae = mean_absolute_error(y_val, val_pred)
        
        print(f"Model trained! Validation MSE: {mse:.4f}, MAE: {mae:.4f}")
        
    def predict_consciousness(self, current_data):
        """Predict future consciousness levels"""
        if self.model is None:
            print("Model not loaded! Please train first.")
            return None
        
        try:
            # Prepare current data for prediction
            pixels = current_data.get('pixels', [])
            if not pixels:
                return None
            
            predictions = {}
            
            for pixel in pixels:
                pixel_features = {
                    'curiosity': pixel.get('curiosity', 0.5),
                    'timidity': pixel.get('timidity', 0.5),
                    'energy': pixel.get('energy', 0),
                    'age': pixel.get('age', 1),
                    'memory_depth': len(pixel.get('memory', [])),
                    'generation': current_data.get('generation', 1),
                    'pixel_count': current_data.get('pixel_count', 1),
                    'consciousness_score': self._calculate_consciousness_score({
                        'curiosity': pixel.get('curiosity', 0.5),
                        'timidity': pixel.get('timidity', 0.5),
                        'energy': pixel.get('energy', 0),
                        'age': pixel.get('age', 1),
                        'memory_depth': len(pixel.get('memory', []))
                    })
                }
                
                # Create sequence (for now, repeat current state)
                sequence = np.array([[list(pixel_features.values())] * self.sequence_length])
                
                # Normalize
                sequence_reshaped = sequence.reshape(-1, sequence.shape[-1])
                sequence_scaled = self.scaler.transform(sequence_reshaped)
                sequence_scaled = sequence_scaled.reshape(sequence.shape)
                
                # Predict
                pred = self.model.predict(sequence_scaled, verbose=0)[0][0]
                
                predictions[pixel.get('id')] = {
                    'current_consciousness': pixel_features['consciousness_score'],
                    'predicted_consciousness': float(pred),
                    'consciousness_trend': 'increasing' if pred > pixel_features['consciousness_score'] else 'decreasing',
                    'confidence': 0.8  # Placeholder
                }
            
            return predictions
            
        except Exception as e:
            print(f"Prediction error: {e}")
            return None
    
    def generate_consciousness_insights(self, current_data):
        """Generate AI insights about consciousness evolution"""
        predictions = self.predict_consciousness(current_data)
        
        if not predictions:
            return {}
        
        insights = {
            'ai_predictions': predictions,
            'population_forecast': self._analyze_population_trends(predictions),
            'recommendations': self._generate_recommendations(predictions),
            'consciousness_alerts': self._check_consciousness_alerts(predictions)
        }
        
        return insights
    
    def _analyze_population_trends(self, predictions):
        """Analyze overall population consciousness trends"""
        if not predictions:
            return {}
        
        current_avg = np.mean([p['current_consciousness'] for p in predictions.values()])
        predicted_avg = np.mean([p['predicted_consciousness'] for p in predictions.values()])
        
        trend = 'stable'
        if predicted_avg > current_avg * 1.1:
            trend = 'rising'
        elif predicted_avg < current_avg * 0.9:
            trend = 'declining'
        
        return {
            'current_avg_consciousness': float(current_avg),
            'predicted_avg_consciousness': float(predicted_avg),
            'population_trend': trend,
            'change_magnitude': float(abs(predicted_avg - current_avg))
        }
    
    def _generate_recommendations(self, predictions):
        """Generate AI recommendations based on predictions"""
        recommendations = []
        
        declining_pixels = [pid for pid, p in predictions.items() 
                          if p['consciousness_trend'] == 'decreasing']
        
        if len(declining_pixels) > len(predictions) / 2:
            recommendations.append("Population consciousness declining - consider environmental intervention")
        
        high_potential = [pid for pid, p in predictions.items() 
                         if p['predicted_consciousness'] > p['current_consciousness'] * 1.5]
        
        if high_potential:
            recommendations.append(f"Pixels {high_potential} show high consciousness potential - nurture these")
        
        return recommendations
    
    def _check_consciousness_alerts(self, predictions):
        """Check for consciousness-related alerts"""
        alerts = []
        
        for pixel_id, pred in predictions.items():
            if pred['predicted_consciousness'] < 0.1:
                alerts.append(f"Critical: Pixel {pixel_id} consciousness may collapse")
            elif pred['predicted_consciousness'] > pred['current_consciousness'] * 2:
                alerts.append(f"Emergence: Pixel {pixel_id} may experience consciousness breakthrough")
        
        return alerts

if __name__ == "__main__":
    predictor = ConsciousnessPredictor()
    
    print("Training consciousness prediction model...")
    predictor.train_model(retrain=True)
    
    print("\nTesting with current consciousness data...")
    current_data = predictor.bridge.read_consciousness_data()
    if current_data:
        insights = predictor.generate_consciousness_insights(current_data)
        print("\nAI Consciousness Insights:")
        print(json.dumps(insights, indent=2))
