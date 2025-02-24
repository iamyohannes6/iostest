require('dotenv').config();

module.exports = {
  coinmarketcap: {
    apiKey: '0a74b9f2-9921-4c94-8f73-466766516a36',
    baseUrl: 'https://pro-api.coinmarketcap.com/v2',
  },
  coingecko: {
    apiKey: 'CG-HabizN4uDnC59FeH82VY3gQC',
  },
  supportedSymbols: ['BTC', 'ETH', 'USDC', 'SHIB', 'LCX', 'DOGE', 'LINK', 'SOL'],
  timeframes: {
    daily: { days: 1, interval: 'hourly' },
    weekly: { days: 7, interval: 'daily' },
    monthly: { days: 30, interval: 'daily' },
  }
}; 