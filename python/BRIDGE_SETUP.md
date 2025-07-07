# Sentium Pico Python Bridge v2.0.0 Setup Guide

## Overview

The Python bridge system enables real-time AI-powered consciousness analysis of your Sentium Pico simulation using advanced Hugging Face transformer models and neural networks. This version introduces sophisticated natural language processing and machine learning capabilities for deeper consciousness understanding.

1. **Start Simple**: Run single analysis first to test the system
2. **Live Monitoring**: Best experience when running alongside PICO-8
3. **Historical Data**: Check `data/session_logs/` for past sessions
4. **Customize Analysis**: Modify `conscious_analyzer.py` for your needs
5. **Export Frequency**: Adjust `export_interval` in PICO-8 code if needed

## What's Next

The bridge system enables:
- **Enhanced AI**: Feed insights back to improve pixel behavior
- **Research**: Study artificial consciousness development
- **Visualization**: Create charts and graphs of consciousness evolution
- **Machine Learning**: Train models on pixel behavior patterns
- **Real-time Tuning**: Adjust simulation parameters based on analysis

Enjoy exploring the consciousness of your digital organisms!ile-based communication to exchange data between PICO-8 and Python.

## File Structure

```
/Users/lopanapol/Sentium/sentium-pico/
├── sentium-pico.p8              # Your PICO-8 game (now with export)
├── data/                        # Data exchange folder
│   ├── conscious_export.json    # PICO-8 writes here
│   ├── python_insights.json        # Python writes here
│   └── session_logs/               # Historical data
├── python/                      # Python analysis system
│   ├── requirements.txt            # Dependencies
│   ├── data_bridge.py              # File communication
│   ├── conscious_analyzer.py   # Main analysis engine
│   └── run_analysis.py            # Entry point
└── README.md, docs/, etc.
```

## Quick Start

### 1. Install Python Dependencies

```bash
cd /Users/lopanapol/Sentium/sentium-pico/python
pip install -r requirements.txt
```

### 2. Test the System

```bash
# Test with sample data (creates fake consciousness export)
python data_bridge.py

# Run single analysis
python run_analysis.py

# Start live monitoring
python run_analysis.py monitor
```

### 3. Run Your PICO-8 Game

1. Open `sentium-pico.p8` in PICO-8
2. Run the game normally
3. The game now exports consciousness data every 3 seconds to `data/conscious_export.json`

### 4. Start Live Analysis

```bash
cd python
python run_analysis.py monitor
```

## What You'll See

### Live Monitoring Output:
```
Consciousness Monitor initialized
Watching: /Users/lopanapol/Sentium/sentium-pico/data/conscious_export.json
Live consciousness monitoring started!

Consciousness data updated at 14:32:15
Generation 5 | Pixels: 3 | Consciousness: 0.67
Personalities: 2 explorer, 1 cautious
Emergence: Moderate (0.45)
Key insight: Developing complexity: Generation 5 building diversity
```

### Analysis Features:
- **Consciousness Scoring**: Individual pixel consciousness levels
- **Personality Clustering**: Groups pixels by behavior (explorer/cautious/balanced)
- **Behavior Prediction**: Predicts pixel actions (approach cursor, divide, etc.)
- **Emergence Metrics**: Measures complexity and diversity
- **Session Insights**: Human-readable observations

## How It Works

### PICO-8 Side:
- `export_consciousness_data()` runs every 3 seconds
- Exports pixel data, personalities, cursor interaction, energy levels
- Writes JSON to `data/conscious_export.json`
- Uses `printh()` function for file output

### Python Side:
- `DataBridge` handles file I/O
- `ConsciousnessAnalyzer` performs ML analysis
- `FileSystemWatcher` monitors for changes
- Real-time insights written back to `data/python_insights.json`

## Usage Modes

### Single Analysis
```bash
python run_analysis.py
```
Analyzes current consciousness state once.

### Live Monitoring
```bash
python run_analysis.py monitor
```
Continuously monitors and analyzes as you play.

### Batch Analysis
```bash
python conscious_analyzer.py
```
Direct analysis with detailed output.

## Advanced Features

### Consciousness Metrics:
- **Memory Depth**: How many experiences each pixel remembers
- **Personality Complexity**: Difference between curiosity and timidity
- **Behavioral Autonomy**: Energy efficiency over time
- **Emergence Score**: Overall system complexity

### Machine Learning:
- **K-Means Clustering**: Groups similar personalities
- **Behavioral Prediction**: Forecasts pixel actions
- **Pattern Recognition**: Identifies recurring behaviors
- **Evolution Tracking**: Monitors generational changes

## Troubleshooting

### No Data Export?
- Check that PICO-8 can write files (permissions)
- Verify `printh()` is working in your PICO-8 setup
- Look for the `conscious_export.json` file

### Python Errors?
- Install dependencies: `pip install -r requirements.txt`
- Check file paths in `data_bridge.py`
- Ensure the `data/` directory exists

### File Watching Issues?
- The `watchdog` library monitors file changes
- On some systems, file watching may have delays
- Try running single analysis instead of monitoring

## Tips

1. **Start Simple**: Run single analysis first to test the system
2. **Live Monitoring**: Best experience when running alongside PICO-8
3. **Historical Data**: Check `data/session_logs/` for past sessions
4. **Customize Analysis**: Modify `conscious_analyzer.py` for your needs
5. **Export Frequency**: Adjust `export_interval` in PICO-8 code if needed

## 🔮 What's Next?

The bridge system enables:
- **Enhanced AI**: Feed insights back to improve pixel behavior
- **Research**: Study artificial consciousness development
- **Visualization**: Create charts and graphs of consciousness evolution
- **Machine Learning**: Train models on pixel behavior patterns
- **Real-time Tuning**: Adjust simulation parameters based on analysis

Enjoy exploring the consciousness of your digital organisms! 🧠✨
