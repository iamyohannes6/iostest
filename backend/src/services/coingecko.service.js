const axios = require('axios');
const config = require('../config/config');
const NodeCache = require('node-cache');

// Cache for 1 hour for historical data
const historicalCache = new NodeCache({ stdTTL: 3600 });

class CoinGeckoService {
  constructor() {
    this.api = axios.create({
      baseURL: 'https://api.coingecko.com/api/v3',
      headers: {
        'X-CG-Demo-API-Key': config.coingecko.apiKey,
        'Accept': 'application/json',
      },
    });
    this.coinIds = {
      'BTC': 'bitcoin',
      'ETH': 'ethereum',
      'USDC': 'usd-coin',
      'SHIB': 'shiba-inu',
      'LCX': 'lcx',
      'DOGE': 'dogecoin',
      'LINK': 'chainlink',
      'SOL': 'solana'
    };
  }

  async getHistoricalData(timeframe, symbols = []) {
    const symbolKey = symbols.sort().join(',');
    const cacheKey = `historical_${timeframe}_${symbolKey}`;
    const cachedData = historicalCache.get(cacheKey);
    if (cachedData) return cachedData;

    try {
      let days;
      switch (timeframe) {
        case 'daily':
          days = 2; // Minimum 2 days to get hourly data
          break;
        case 'weekly':
          days = 7;
          break;
        case 'monthly':
          days = 30;
          break;
        default:
          days = 30;
      }

      const result = {
        success: true,
        timeframe,
        rates: {},
        timestamps: []
      };

      // Only fetch data for requested symbols
      const symbolsToFetch = symbols.length > 0 ? symbols : Object.keys(this.coinIds);

      // Fetch historical data for each coin with delay between requests
      for (const symbol of symbolsToFetch) {
        const id = this.coinIds[symbol.toUpperCase()];
        if (!id) continue;

        try {
          // Using the correct CoinGecko endpoint for market chart data
          const response = await this.api.get(`/coins/${id}/market_chart`, {
            params: {
              vs_currency: 'eur',
              days: days.toString(),
              precision: 'full'
            }
          });

          if (response.data && response.data.prices) {
            // Process price data
            response.data.prices.forEach(([timestamp, price]) => {
              const isoTime = new Date(timestamp).toISOString();
              if (!result.timestamps.includes(isoTime)) {
                result.timestamps.push(isoTime);
              }
              if (!result.rates[symbol]) {
                result.rates[symbol] = {};
              }
              result.rates[symbol][isoTime] = price;
            });
          }

          // Add delay between requests to avoid rate limiting
          await new Promise(resolve => setTimeout(resolve, 2000)); // Increased delay to 2 seconds
        } catch (error) {
          if (error.response) {
            console.error(`Error fetching data for ${symbol}:`, error.response.status, error.response.data);
          } else {
            console.error(`Error fetching data for ${symbol}:`, error.message);
          }
          continue; // Skip to next coin if there's an error
        }
      }

      // Sort timestamps
      result.timestamps.sort();

      if (Object.keys(result.rates).length > 0) {
        historicalCache.set(cacheKey, result);
      }
      return result;
    } catch (error) {
      console.error('Error getting historical data:', error);
      throw new Error('Failed to get historical data from CoinGecko');
    }
  }

  async refreshHistoricalData(timeframe, symbols = []) {
    const symbolKey = symbols.sort().join(',');
    const cacheKey = `historical_${timeframe}_${symbolKey}`;
    historicalCache.del(cacheKey);
    return this.getHistoricalData(timeframe, symbols);
  }
}

module.exports = new CoinGeckoService(); 