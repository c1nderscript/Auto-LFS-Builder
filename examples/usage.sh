#!/bin/bash

# Auto-LFS-Builder Usage Example
# This script demonstrates how to use the Auto-LFS-Builder installation and basic usage

set -e

echo "Auto-LFS-Builder Usage Example"
echo "==============================="
echo ""

# Example 1: Quick installation with defaults
echo "1. Quick installation (default settings):"
echo "   curl -sSL https://raw.githubusercontent.com/c1nderscript/Auto-LFS-Builder/main/install.sh | bash"
echo ""

# Example 2: Custom installation
echo "2. Custom installation with specific settings:"
echo "   ./install.sh --install-dir /opt/lfs-builder --workspace /var/lfs --build-profile developer --parallel-jobs 8"
echo ""

# Example 3: Basic usage after installation
echo "3. Basic usage after installation:"
echo "   cd ~/auto-lfs-builder"
echo "   source activate"
echo "   ./lfs-validate"
echo "   ./lfs-build"
echo ""

# Example 4: Manual steps
echo "4. Manual step-by-step process:"
echo "   # Clone repository"
echo "   git clone https://github.com/c1nderscript/Auto-LFS-Builder.git"
echo "   cd Auto-LFS-Builder"
echo ""
echo "   # Install dependencies (Ubuntu/Debian)"
echo "   sudo apt-get update"
echo "   sudo apt-get install -y build-essential bison flex gawk texinfo wget curl git python3 python3-pip python3-venv libxml2-utils pandoc"
echo ""
echo "   # Set up Python environment"
echo "   python3 -m venv venv"
echo "   source venv/bin/activate"
echo "   pip install -r requirements.txt"
echo ""
echo "   # Configure environment (edit as needed)"
echo "   export LFS_WORKSPACE=\"\$HOME/lfs-workspace\""
echo "   export BUILD_PROFILE=\"desktop_gnome\""
echo "   export PARALLEL_JOBS=\"\$(nproc)\""
echo ""
echo "   # Run validation"
echo "   bash generated/validation_suite.sh"
echo ""
echo "   # Parse documentation and build"
echo "   python3 -m src.parsers.lfs_parser docs/lfs-git/chapter01/chapter01.xml"
echo "   bash generated/complete_build.sh"
echo ""

# Example 5: Different build profiles
echo "5. Available build profiles:"
echo "   desktop_gnome  - Full GNOME desktop with networking"
echo "   minimal        - Base LFS system only"
echo "   server         - Server configuration with networking, no GUI"
echo "   developer      - Development tools and environment"
echo ""

# Example 6: Troubleshooting
echo "6. Troubleshooting:"
echo "   # Check system requirements"
echo "   df -h .  # Check disk space (need 50GB+)"
echo "   free -h  # Check memory (recommend 4GB+)"
echo ""
echo "   # Run validation"
echo "   ./lfs-validate"
echo ""
echo "   # Check logs"
echo "   tail -f logs/build.log"
echo ""
echo "   # Clean and retry"
echo "   ./lfs-clean"
echo "   ./lfs-build"
echo ""

echo "For detailed documentation, see:"
echo "- README.md  (quick start)"
echo "- SETUP.md   (detailed configuration)"
echo "- AGENTS.md  (advanced usage)"
echo ""
echo "Happy building!"
