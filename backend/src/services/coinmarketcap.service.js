const axios = require('axios');
const config = require('../config/config');
const NodeCache = require('node-cache');
const fs = require('fs').promises;
const path = require('path');

// Cache for 5 minutes for current prices
const priceCache = new NodeCache({ stdTTL: 300 });
const HISTORY_FILE = path.join(__dirname, '../data/price_history.json');

class CoinMarketCapService {
  constructor() {
    this.api = axios.create({
      baseURL: config.coinmarketcap.baseUrl,
      headers: {
        'X-CMC_PRO_API_KEY': config.coinmarketcap.apiKey,
        'Accept': 'application/json',
      },
    });
    this.initializeHistory();
  }

  async initializeHistory() {
    try {
      await fs.mkdir(path.join(__dirname, '../data'), { recursive: true });
      try {
        await fs.access(HISTORY_FILE);
      } catch {
        // File doesn't exist, create it with empty history
        await fs.writeFile(HISTORY_FILE, JSON.stringify({
          data: {},
          lastUpdate: null
        }));
      }
    } catch (error) {
      console.error('Error initializing history:', error);
    }
  }

  async getLatestPrices() {
    const cachedData = priceCache.get('latest_prices');
    if (cachedData) return cachedData;

    try {
      const symbols = config.supportedSymbols.join(',');
      const response = await this.api.get('/cryptocurrency/quotes/latest', {
        params: {
          symbol: symbols,
          convert: 'EUR'
        }
      });

      if (!response.data.data) {
        throw new Error('Invalid response from CoinMarketCap API');
      }

      const result = {
        success: true,
        timestamp: new Date().toISOString(),
        data: []
      };

      for (const symbol of config.supportedSymbols) {
        const cryptoData = response.data.data[symbol]?.[0];
        if (cryptoData && cryptoData.quote && cryptoData.quote.EUR) {
          result.data.push({
            symbol: symbol,
            price: cryptoData.quote.EUR.price,
            change24h: cryptoData.quote.EUR.percent_change_24h
          });
        }
      }

      // Save to history
      await this.saveToHistory(result);

      priceCache.set('latest_prices', result);
      return result;
    } catch (error) {
      console.error('CoinMarketCap API Error:', error.response?.data || error.message);
      throw new Error('Failed to fetch latest prices from CoinMarketCap');
    }
  }

  async saveToHistory(priceData) {
    try {
      const historyStr = await fs.readFile(HISTORY_FILE, 'utf8');
      const history = JSON.parse(historyStr);
      
      // Add new price points
      priceData.data.forEach(item => {
        if (!history.data[item.symbol]) {
          history.data[item.symbol] = [];
        }
        history.data[item.symbol].push({
          timestamp: priceData.timestamp,
          price: item.price
        });

        // Keep only last 30 days of data
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        history.data[item.symbol] = history.data[item.symbol].filter(point => 
          new Date(point.timestamp) > thirtyDaysAgo
        );
      });

      history.lastUpdate = priceData.timestamp;
      await fs.writeFile(HISTORY_FILE, JSON.stringify(history, null, 2));
    } catch (error) {
      console.error('Error saving to history:', error);
    }
  }

  async getHistoricalData(timeframe) {
    try {
      const historyStr = await fs.readFile(HISTORY_FILE, 'utf8');
      const history = JSON.parse(historyStr);
      
      const now = new Date();
      let startDate;
      
      switch (timeframe) {
        case 'daily':
          startDate = new Date(now - 24 * 60 * 60 * 1000);
          break;
        case 'weekly':
          startDate = new Date(now - 7 * 24 * 60 * 60 * 1000);
          break;
        case 'monthly':
          startDate = new Date(now - 30 * 24 * 60 * 60 * 1000);
          break;
        default:
          startDate = new Date(now - 30 * 24 * 60 * 60 * 1000);
      }

      const result = {
        success: true,
        timeframe,
        rates: {},
        timestamps: []
      };

      // Get all timestamps from all symbols
      const allTimestamps = new Set();
      Object.values(history.data).forEach(points => {
        points.forEach(point => {
          if (new Date(point.timestamp) > startDate) {
            allTimestamps.add(point.timestamp);
          }
        });
      });

      result.timestamps = Array.from(allTimestamps).sort();

      // Fill in rates for each symbol
      for (const symbol of config.supportedSymbols) {
        result.rates[symbol] = {};
        const symbolData = history.data[symbol] || [];
        
        result.timestamps.forEach(timestamp => {
          const point = symbolData.find(p => p.timestamp === timestamp);
          result.rates[symbol][timestamp] = point ? point.price : null;
        });
      }

      return result;
    } catch (error) {
      console.error('Error getting historical data:', error);
      throw new Error('Failed to get historical data');
    }
  }

  async refreshPrices() {
    priceCache.del('latest_prices');
    return this.getLatestPrices();
  }

  async refreshHistoricalData(timeframe) {
    return this.getHistoricalData(timeframe);
  }
}

module.exports = new CoinMarketCapService(); 