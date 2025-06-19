#!/usr/bin/env python3
"""
Sentium Pico Python Bridge - Quick Setup and Test
"""

import subprocess
import sys
import os
from pathlib import Path

def run_command(cmd, description):
    """Run a shell command with description"""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {description} completed successfully")
            return True
        else:
            print(f"❌ {description} failed: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Error during {description}: {e}")
        return False

def check_python_deps():
    """Check if required Python packages are installed"""
    print("🔍 Checking Python dependencies...")
    
    required_packages = ['numpy', 'pandas', 'watchdog']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"  ✅ {package}")
        except ImportError:
            print(f"  ❌ {package} (missing)")
            missing_packages.append(package)
    
    return len(missing_packages) == 0, missing_packages

def setup_bridge():
    """Set up the Python bridge system"""
    print("🚀 Setting up Sentium Pico Python Bridge")
    print("="*50)
    
    # Check if we're in the right directory
    current_dir = Path.cwd()
    if not (current_dir / "data_bridge.py").exists():
        print("❌ Please run this script from the python/ directory")
        print(f"   Current directory: {current_dir}")
        print(f"   Expected files: data_bridge.py, simple_analyzer.py")
        return False
    
    # Check Python dependencies
    deps_ok, missing = check_python_deps()
    if not deps_ok:
        print(f"\n📦 Installing missing packages: {', '.join(missing)}")
        if not run_command("pip install " + " ".join(missing), "Installing dependencies"):
            print("❌ Failed to install dependencies. Try manually:")
            print(f"   pip install {' '.join(missing)}")
            return False
    
    # Test the data bridge
    print(f"\n🧪 Testing data bridge system...")
    if not run_command("python data_bridge.py", "Testing data bridge"):
        return False
    
    # Test the simple analyzer
    print(f"\n🧠 Testing consciousness analyzer...")
    if not run_command("python simple_analyzer.py", "Testing analyzer"):
        return False
    
    print(f"\n🎉 Setup completed successfully!")
    print(f"\nNext steps:")
    print(f"1. Open your PICO-8 game: sentium-pico.p8")
    print(f"2. Run the game (it will export consciousness data every 3 seconds)")
    print(f"3. Run analysis:")
    print(f"   • Single analysis: python simple_analyzer.py")
    print(f"   • Live monitoring: python run_analysis.py monitor")
    
    return True

def test_system():
    """Test the system with sample data"""
    print("🧪 Testing system with sample consciousness data...")
    
    from data_bridge import DataBridge
    from simple_analyzer import SimpleConsciousnessAnalyzer
    
    # Create sample data
    bridge = DataBridge()
    sample_data = bridge.create_sample_export()
    
    # Run analysis
    analyzer = SimpleConsciousnessAnalyzer()
    results = analyzer.analyze_consciousness()
    
    if results:
        print("\n✅ System test successful!")
        print(f"📊 Analyzed {results['pixel_count']} pixels from generation {results['generation']}")
        print(f"🧠 Consciousness level: {results['overall_consciousness_level']:.2f}")
        print(f"🎭 Dominant personality: {results['dominant_personality']}")
        return True
    else:
        print("\n❌ System test failed")
        return False

def show_usage():
    """Show usage instructions"""
    print("🧠 Sentium Pico Python Bridge")
    print("="*30)
    print("Commands:")
    print("  python setup.py setup  - Set up the bridge system")
    print("  python setup.py test   - Test with sample data")
    print("  python setup.py help   - Show this help")
    print()
    print("Analysis commands:")
    print("  python simple_analyzer.py      - Run simple analysis")
    print("  python consciousness_analyzer.py - Run full ML analysis (slower)")
    print("  python run_analysis.py monitor  - Live monitoring")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        show_usage()
        sys.exit(1)
    
    command = sys.argv[1].lower()
    
    if command == "setup":
        success = setup_bridge()
        sys.exit(0 if success else 1)
    elif command == "test":
        success = test_system()
        sys.exit(0 if success else 1)
    elif command == "help":
        show_usage()
        sys.exit(0)
    else:
        print(f"❌ Unknown command: {command}")
        show_usage()
        sys.exit(1)
