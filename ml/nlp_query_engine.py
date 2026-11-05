"""
AgriLink NLP Query Engine - Backward Compatibility Shim.
Forwarding to dedicated modular package: nlp_engine
"""
import sys
import os

# Ensure root directory is on system path
root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if root_dir not in sys.path:
    sys.path.insert(0, root_dir)

try:
    from nlp_engine.query_engine import FarmerDatabaseNLPQueryEngine
except ImportError:
    from nlp_engine import FarmerDatabaseNLPQueryEngine

__all__ = ["FarmerDatabaseNLPQueryEngine"]
