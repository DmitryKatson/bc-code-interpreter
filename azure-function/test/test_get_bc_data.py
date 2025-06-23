import os
import sys
from pathlib import Path
from dotenv import load_dotenv

# Ensure the parent directory is in the path to import function_app
sys.path.append(str(Path(__file__).resolve().parent.parent))
from function_app import get_bc_data

# Load environment variables from .env file in the test folder
load_dotenv(dotenv_path=Path(__file__).parent / ".env")

def main():
  # Manually set parameters here
  environment = os.getenv("BC_ENVIRONMENT", "sandbox")
  relative_url = os.getenv("BC_RELATIVE_URL", "v2.0/companies")  # Example: 'v2.0/companies'

  try:
    data = get_bc_data(relative_url, environment)
    print("Result from get_bc_data:")
    print(data)
  except Exception as e:
    print(f"Error: {e}")

if __name__ == "__main__":
  main() 