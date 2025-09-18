// Helper functions for the Garden App

const generateXid = () => {
  const chars = '0123456789abcdefghijklmnopqrstuv';
  let result = '';
  for (let i = 0; i < 24; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

const createLink = (rel, href) => ({ rel, href });

const validateXid = (id) => {
  return typeof id === 'string' && id.length === 24 && /^[0-9a-v]{20}$/.test(id);
};

const addTimestamps = (obj) => ({
  ...obj,
  created_at: new Date().toISOString()
});

const getMockWeatherData = () => ({
  rain: {
    mm: parseFloat(process.env.DEFAULT_WEATHER_RAIN) || 2.5,
    scale_factor: 0.8
  },
  average_temperature: {
    celsius: parseFloat(process.env.DEFAULT_WEATHER_TEMP) || 22.5,
    scale_factor: 1.0
  }
});

const getNextWaterTime = () => {
  return new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
};

const validMonthToNumber = (month) => {
  switch (month) {
    case 'Jan': return 1;
    case 'Feb': return 2;
    case 'Mar': return 3;
    case 'Apr': return 4;
    case 'May': return 5;
    case 'Jun': return 6;
    case 'Jul': return 7;
    case 'Aug': return 8;
    case 'Sep': return 9;
    case 'Oct': return 10;
    case 'Nov': return 11;
    case 'Dec': return 12;
    default: return null;
  }
};

module.exports = {
  generateXid,
  createLink,
  validateXid,
  addTimestamps,
  getMockWeatherData,
  getNextWaterTime,
  validMonthToNumber
};