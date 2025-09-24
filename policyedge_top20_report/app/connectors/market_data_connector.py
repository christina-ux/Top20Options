class MarketDataConnector:
    def __init__(self, api_key: str):
        self.api_key = api_key
    async def fetch(self, symbols: list[str]) -> dict:
        # TODO: implement with your provider (e.g., websocket/rest)
        # return {symbol: {"pct": ..., "vwap_rel": ..., "iv_rank": ...}, ...}
        return {}
