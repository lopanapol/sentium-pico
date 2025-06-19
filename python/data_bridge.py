import json
import time
import os
from datetime import datetime
from pathlib import Path

class DataBridge:
    def __init__(self, workspace_path="/Users/lopanapol/Sentium/sentium-pico-8"):
        self.workspace_path = Path(workspace_path)
        self.data_path = self.workspace_path / "data"
        self.session_logs_path = self.data_path / "session_logs"
        
        # File paths for data exchange
        self.conscious_export_file = self.data_path / "conscious_export.json"
        self.python_insights_file = self.data_path / "python_insights.json"
        
        # Ensure directories exist
        self.data_path.mkdir(exist_ok=True)
        self.session_logs_path.mkdir(exist_ok=True)
        
        print(f"Data bridge initialized at: {self.data_path}")
    
    def read_consciousness_data(self):
        """Read consciousness data exported from PICO-8"""
        try:
            if self.conscious_export_file.exists():
                with open(self.conscious_export_file, 'r') as f:
                    data = json.load(f)
                    print(f"Read consciousness data with {len(data.get('pixels', []))} pixels")
                    return data
            else:
                print("No consciousness data file found")
                return None
        except Exception as e:
            print(f"Error reading consciousness data: {e}")
            return None
    
    def write_insights(self, insights):
        """Write Python insights back for PICO-8 to read"""
        try:
            insights['timestamp'] = time.time()
            insights['generated_at'] = datetime.now().isoformat()
            
            with open(self.python_insights_file, 'w') as f:
                json.dump(insights, f, indent=2)
            
            print(f"Wrote insights: {list(insights.keys())}")
            return True
        except Exception as e:
            print(f"Error writing insights: {e}")
            return False
    
    def log_session_data(self, data):
        """Log session data for historical analysis"""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            log_file = self.session_logs_path / f"session_{timestamp}.json"
            
            with open(log_file, 'w') as f:
                json.dump(data, f, indent=2)
            
            print(f"Logged session data to: {log_file.name}")
            return True
        except Exception as e:
            print(f"Error logging session data: {e}")
            return False
    
    def create_sample_export(self):
        """Create a sample consciousness export for testing"""
        sample_data = {
            "timestamp": time.time(),
            "generation": 5,
            "pixel_count": 3,
            "pixels": [
                {
                    "id": 1,
                    "x": 64,
                    "y": 64,
                    "curiosity": 0.7,
                    "timidity": 0.3,
                    "energy": 15,
                    "age": 120,
                    "color": 8,
                    "memory": [
                        {"event": "division", "impact": 0.8},
                        {"event": "cursor_approach", "impact": 0.6}
                    ]
                },
                {
                    "id": 2,
                    "x": 80,
                    "y": 50,
                    "curiosity": 0.4,
                    "timidity": 0.8,
                    "energy": 12,
                    "age": 90,
                    "color": 12,
                    "memory": [
                        {"event": "energy_found", "impact": 0.5},
                        {"event": "cursor_flee", "impact": -0.4}
                    ]
                }
            ],
            "cursor_interaction": {
                "is_aware": True,
                "attention_level": 0.6,
                "collective_excitement": 0.45
            },
            "energy_cubes": 5,
            "session_duration": 300
        }
        
        with open(self.conscious_export_file, 'w') as f:
            json.dump(sample_data, f, indent=2)
        
        print("Created sample consciousness export for testing")
        return sample_data

if __name__ == "__main__":
    # Test the data bridge
    bridge = DataBridge()
    
    # Create sample data for testing
    sample_data = bridge.create_sample_export()
    
    # Test reading
    data = bridge.read_consciousness_data()
    if data:
        print(f"Successfully read {len(data['pixels'])} pixels from generation {data['generation']}")
    
    # Test insights writing
    test_insights = {
        "consciousness_score": 0.73,
        "dominant_personality": "curious",
        "behavior_prediction": "likely_to_approach_cursor",
        "generation_analysis": "increasing_diversity"
    }
    
    bridge.write_insights(test_insights)
    bridge.log_session_data(data)
