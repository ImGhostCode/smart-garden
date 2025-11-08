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

// Convert duration string (e.g. "1h30m") to milliseconds
const durationToMillis = (duration) => {
  if (typeof duration === 'number') return duration;
  if (typeof duration !== 'string') return 0;
  const regex = /(\d+)([smhd])/g;
  let match;
  let totalMs = 0;
  const unitToMs = { s: 1000, m: 60000, h: 3600000, d: 86400000 };

  while ((match = regex.exec(duration)) !== null) {
    const value = parseInt(match[1], 10);
    const unit = match[2];
    totalMs += value * unitToMs[unit];
  }
  return totalMs;
};

function durationToSeconds(durationStr) {
  if (!durationStr) return 0;

  const match = durationStr.match(/^(\d+)(ms|s|m|h)$/);
  if (!match) return 0;

  const value = parseInt(match[1]);
  const unit = match[2];

  switch (unit) {
    case 'ms': return value / 1000;
    case 's': return value;
    case 'm': return value * 60;
    case 'h': return value * 3600;
    default: return 0;
  }
}

// Format duration from milliseconds to human readable string
const millisToDuration = (ms) => {
  if (ms === 0) return '0s';

  const seconds = Math.floor((ms / 1000) % 60);
  const minutes = Math.floor((ms / (1000 * 60)) % 60);
  const hours = Math.floor((ms / (1000 * 60 * 60)) % 24);
  const days = Math.floor(ms / (1000 * 60 * 60 * 24));

  const parts = [];
  if (days > 0) parts.push(`${days}d`);
  if (hours > 0) parts.push(`${hours}h`);
  if (minutes > 0) parts.push(`${minutes}m`);
  if (seconds > 0) parts.push(`${seconds}s`);

  return parts.join(' ') || '0s';
};


module.exports = {
  generateXid,
  createLink,
  validMonthToNumber,
  durationToMillis,
  millisToDuration,
  durationToSeconds
};