import os
from dotenv import load_dotenv
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "")
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY", "")
MARKET_API_KEY = os.getenv("MARKET_API_KEY", "")
POLICY_API_KEY = os.getenv("POLICY_API_KEY", "")
OPTIONS_API_KEY = os.getenv("OPTIONS_API_KEY", "")
PUBLISH_CHANNELS = os.getenv("PUBLISH_CHANNELS", "local")
