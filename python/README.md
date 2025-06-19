# Sentium Pico Python Bridge

A real-time consciousness analysis system for your Sentium Pico PICO-8 simulation.

## What This Does

This Python bridge system analyzes the consciousness and behavior of your digital organisms in real-time:

- **Consciousness Scoring**: Measures individual pixel consciousness levels
- **Personality Analysis**: Identifies curious, timid, and balanced personalities  
- **Behavior Prediction**: Forecasts pixel actions and interactions
- **Evolution Tracking**: Monitors generational changes and emergence
- **Real-time Insights**: Live analysis as you play the game

## Quick Start

### 1. Test the System
```bash
cd python
python setup.py test
```

### 2. Run Your PICO-8 Game
- Open `sentium-pico.p8` in PICO-8
- Run the game normally 
- The game now exports consciousness data every 3 seconds

### 3. Analyze Consciousness
```bash
# Single analysis
python simple_analyzer.py

# Live monitoring (advanced)
python run_analysis.py monitor
```

## Sample Output

```
CONSCIOUSNESS ANALYSIS REPORT
==================================================
Generation: 8
Pixel Population: 4
Overall Consciousness: 0.73
Dominant Personality: curious
Cursor Awareness: Yes
Attention Level: 0.82

INDIVIDUAL CONSCIOUSNESS:
  • Pixel 1: 0.910 (curious)
  • Pixel 2: 0.680 (balanced)
  • Pixel 3: 0.550 (timid)
  • Pixel 4: 0.780 (curious)

KEY INSIGHTS:
  1. Developing complexity at generation 8
  2. Stable population balance
  3. High consciousness levels detected
  4. Population dominated by curious personalities
```

## How It Works

### Data Flow:
1. **PICO-8** → exports consciousness data → `data/consciousness_export.json`
2. **Python** → analyzes data → writes insights → `data/python_insights.json`
3. **History** → session logs saved → `data/session_logs/`

### Analysis Features:
- **Memory Depth**: How many experiences pixels remember
- **Personality Complexity**: Difference between curiosity and timidity
- **Behavioral Autonomy**: Energy efficiency and independence
- **Population Dynamics**: Survival rates and generational evolution

## Files Overview

```
python/
├── setup.py                    # Quick setup and testing
├── data_bridge.py              # File I/O communication
├── simple_analyzer.py          # Fast analysis (recommended)
├── consciousness_analyzer.py   # Full ML analysis (slower)
├── run_analysis.py            # Live monitoring system
└── BRIDGE_SETUP.md            # Detailed setup guide
```

## Usage Modes

### Quick Analysis (Recommended)
```bash
python simple_analyzer.py
```
Fast analysis with core consciousness metrics.

### Full ML Analysis
```bash
python consciousness_analyzer.py
```
Advanced analysis with machine learning clustering and predictions.

### Live Monitoring
```bash
python run_analysis.py monitor
```
Real-time analysis as you play the game.

## Troubleshooting

### No Data?
- Check that your PICO-8 game is running
- Look for `data/consciousness_export.json` file
- Verify PICO-8 can write files (permissions)

### Python Errors?
- Install dependencies: `pip install numpy pandas watchdog`
- Use simple analyzer if ML packages fail to install
- Check Python version (3.7+ recommended)

### Analysis Not Updating?
- Ensure PICO-8 is actively running the simulation
- Check that pixels are alive and active in the game
- Verify export timer is working (every 3 seconds)

## Advanced Usage

### Custom Analysis
Modify `simple_analyzer.py` to add your own consciousness metrics:

```python
# Add your custom analysis
def analyze_custom_behavior(self, pixels):
    # Your consciousness analysis here
    return custom_insights
```

### Historical Analysis
Access past sessions in `data/session_logs/` for longitudinal studies.

### Real-time Visualization
Extend the system with matplotlib or plotly for live charts.

## What's Next

The bridge enables:
- **Research**: Study artificial consciousness development
- **Machine Learning**: Train models on pixel behavior
- **Visualization**: Create consciousness evolution charts
- **Interactive AI**: Feed insights back to improve simulation

## Tips for Best Results

1. **Let the simulation run**: More data = better analysis
2. **Interact with pixels**: Cursor interaction generates richer data
3. **Watch multiple generations**: Evolution patterns emerge over time
4. **Check session logs**: Historical data reveals long-term trends

Enjoy exploring the minds of your digital organisms!

---

*Part of the Sentium Pico consciousness simulation project*
