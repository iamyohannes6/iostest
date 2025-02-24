const axios = require('axios');
const config = require('../config/config');
const NodeCache = require('node-cache');

// Cache for 1 hour
const cache = new NodeCache({ stdTTL: 3600 });

class ExchangeRatesService {
  constructor() {
    this.api = axios.create({
      baseURL: config.exchangerates.baseUrl,
    });
  }

  async getHistoricalRates(timeframe) {
    const cacheKey = `historical_rates_${timeframe}`;
    const cachedData = cache.get(cacheKey);
    if (cachedData) return cachedData;

    try {
      const { days } = config.timeframes[timeframe];
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      // Format dates as YYYY-MM-DD
      const start_date = startDate.toISOString().split('T')[0];
      const end_date = endDate.toISOString().split('T')[0];

      const response = await this.api.get('/timeseries', {
        params: {
          access_key: config.exchangerates.apiKey,
          start_date,
          end_date,
          base: 'EUR',
          symbols: config.supportedSymbols.join(',')
        }
      });

      if (!response.data.success) {
        throw new Error(response.data.error?.info || 'Failed to fetch historical rates');
      }

      // Transform the data to match our expected format
      const result = {
        success: true,
        timeframe,
        rates: {},
        timestamps: []
      };

      // Sort timestamps to ensure chronological order
      result.timestamps = Object.keys(response.data.rates).sort();

      // Initialize rates object for each symbol
      config.supportedSymbols.forEach(symbol => {
        result.rates[symbol] = {};
        result.timestamps.forEach(timestamp => {
          result.rates[symbol][timestamp] = response.data.rates[timestamp][symbol] || 0;
        });
      });

      cache.set(cacheKey, result);
      return result;
    } catch (error) {
      console.error('ExchangeRates API Error:', error.response?.data || error.message);
      throw new Error(`Failed to fetch historical rates: ${error.response?.data?.error?.info || error.message}`);
    }
  }

  async refreshHistoricalRates(timeframe) {
    const cacheKey = `historical_rates_${timeframe}`;
    cache.del(cacheKey);
    return this.getHistoricalRates(timeframe);
  }
}

module.exports = new ExchangeRatesService(); 