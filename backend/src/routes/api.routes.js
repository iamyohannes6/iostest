const express = require('express');
const router = express.Router();
const coinmarketcap = require('../services/coinmarketcap.service');
const coingecko = require('../services/coingecko.service');
const config = require('../config/config');

// Market Data Routes (Current Prices)
router.get('/market-data', async (req, res) => {
  try {
    const data = await coinmarketcap.getLatestPrices();
    res.json(data);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/market-data/refresh', async (req, res) => {
  try {
    const data = await coinmarketcap.refreshPrices();
    res.json(data);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Historical Data Routes
router.get('/historical-rates/:timeframe', async (req, res) => {
  const { timeframe } = req.params;
  const { symbols } = req.query;
  
  if (!config.timeframes[timeframe]) {
    return res.status(400).json({
      success: false,
      error: 'Invalid timeframe. Must be one of: daily, weekly, monthly'
    });
  }

  // Parse and validate symbols
  const requestedSymbols = symbols ? symbols.split(',') : [];
  const validSymbols = requestedSymbols.filter(symbol => 
    config.supportedSymbols.includes(symbol.toUpperCase())
  );

  if (validSymbols.length === 0) {
    return res.status(400).json({
      success: false,
      error: 'No valid symbols provided'
    });
  }

  try {
    const data = await coingecko.getHistoricalData(timeframe, validSymbols);
    res.json(data);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/historical-rates/:timeframe/refresh', async (req, res) => {
  const { timeframe } = req.params;
  const { symbols } = req.query;
  
  if (!config.timeframes[timeframe]) {
    return res.status(400).json({
      success: false,
      error: 'Invalid timeframe. Must be one of: daily, weekly, monthly'
    });
  }

  // Parse and validate symbols
  const requestedSymbols = symbols ? symbols.split(',') : [];
  const validSymbols = requestedSymbols.filter(symbol => 
    config.supportedSymbols.includes(symbol.toUpperCase())
  );

  if (validSymbols.length === 0) {
    return res.status(400).json({
      success: false,
      error: 'No valid symbols provided'
    });
  }

  try {
    const data = await coingecko.refreshHistoricalData(timeframe, validSymbols);
    res.json(data);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router; 