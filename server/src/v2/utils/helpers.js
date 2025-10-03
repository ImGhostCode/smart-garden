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

// Calculate the next water time based on schedule properties
const calculateNextWaterTime = (schedule) => {
  const now = new Date();
  const currentMonth = now.getMonth() + 1; // JavaScript months are 0-indexed

  // Check if we're in active period (if defined)
  if (schedule.active_period) {
    const startMonth = validMonthToNumber(schedule.active_period.start_month);
    const endMonth = validMonthToNumber(schedule.active_period.end_month);

    // Handle year-spanning periods (e.g., Nov to Mar)
    const isInActivePeriod = startMonth <= endMonth
      ? (currentMonth >= startMonth && currentMonth <= endMonth)
      : (currentMonth >= startMonth || currentMonth <= endMonth);

    if (!isInActivePeriod) {
      // Find next start of active period
      let nextActiveMonth;
      if (startMonth <= endMonth) {
        // Same year period
        nextActiveMonth = currentMonth <= endMonth ? startMonth + 1 : startMonth;
      } else {
        // Year-spanning period
        nextActiveMonth = currentMonth <= endMonth ? startMonth : startMonth;
      }

      const nextYear = nextActiveMonth <= currentMonth ? now.getFullYear() + 1 : now.getFullYear();
      const nextActiveDate = new Date(nextYear, nextActiveMonth - 1, 1);
      return nextActiveDate.toISOString();
    }
  }

  // Parse start_time (format: "HH:MM:SS±HH:MM")
  const timeMatch = schedule.start_time.match(/^(\d{2}):(\d{2}):(\d{2})([+-])(\d{2}):(\d{2})$/);
  if (!timeMatch) {
    throw new Error('Invalid start_time format');
  }

  const [, hours, minutes, seconds, tzSign, tzHours, tzMinutes] = timeMatch;
  const startHour = parseInt(hours, 10);
  const startMinute = parseInt(minutes, 10);
  const startSecond = parseInt(seconds, 10);

  // Get timezone offset in hours
  const timezoneOffsetHours = (tzSign === '+' ? 1 : -1) * parseInt(tzHours, 10);
  const timezoneOffset = timezoneOffsetHours * 60 * 60 * 1000; // Convert to milliseconds

  // Parse interval to hours
  const intervalMatch = schedule.interval.match(/^(\d+)([smhd])$/);
  if (!intervalMatch) {
    throw new Error('Invalid interval format');
  }

  const value = parseInt(intervalMatch[1]);
  const unit = intervalMatch[2];
  let intervalHours;

  switch (unit) {
    case 's': intervalHours = value / 3600; break;
    case 'm': intervalHours = value / 60; break;
    case 'h': intervalHours = value; break;
    case 'd': intervalHours = value * 24; break;
    default: throw new Error('Invalid interval unit');
  }

  // Calculate execution times based on interval (similar to cron logic)
  let executionHours = [startHour];

  if (intervalHours === 12) {
    // Twice daily: original hour and 12 hours later
    executionHours = [startHour, (startHour + 12) % 24];
  } else if (intervalHours < 24) {
    // Multiple times per day
    executionHours = [];
    for (let h = 0; h < 24; h += intervalHours) {
      executionHours.push((startHour + h) % 24);
    }
  }
  // For 24h or longer intervals, keep original hour

  // Get current time in the schedule's timezone
  const nowInTimezone = new Date(now.getTime() + timezoneOffset);

  // Find next execution time
  let nextExecution = null;
  const sortedHours = [...executionHours].sort((a, b) => a - b);

  // Check today's times first
  for (const targetHour of sortedHours) {
    // Create time in target timezone
    const timezoneTime = new Date();
    timezoneTime.setUTCFullYear(nowInTimezone.getUTCFullYear());
    timezoneTime.setUTCMonth(nowInTimezone.getUTCMonth());
    timezoneTime.setUTCDate(nowInTimezone.getUTCDate());
    timezoneTime.setUTCHours(targetHour, startMinute, startSecond, 0);

    // Convert to UTC by subtracting timezone offset
    const utcTime = new Date(timezoneTime.getTime() - timezoneOffset);

    if (utcTime > now) {
      nextExecution = utcTime;
      break;
    }
  }

  // If no time today works, use tomorrow's earliest time
  if (!nextExecution) {
    const tomorrowInTimezone = new Date(nowInTimezone);
    tomorrowInTimezone.setUTCDate(tomorrowInTimezone.getUTCDate() + 1);
    tomorrowInTimezone.setUTCHours(sortedHours[0], startMinute, startSecond, 0);

    nextExecution = new Date(tomorrowInTimezone.getTime() - timezoneOffset);
  }

  // Handle day intervals (e.g., every 2 days, every 3 days)
  if (intervalHours >= 24 && intervalHours % 24 === 0) {
    const dayInterval = intervalHours / 24;
    let testExecution = new Date(nextExecution);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let daysDiff = Math.floor((testExecution - today) / (24 * 60 * 60 * 1000));
    while (daysDiff % dayInterval !== 0) {
      testExecution.setDate(testExecution.getDate() + 1);
      daysDiff++;
    }

    nextExecution = testExecution;
  }

  // Double-check we're still in active period for the calculated date
  if (schedule.active_period) {
    const nextMonth = nextExecution.getMonth() + 1;
    const startMonth = validMonthToNumber(schedule.active_period.start_month);
    const endMonth = validMonthToNumber(schedule.active_period.end_month);

    const isInActivePeriod = startMonth <= endMonth
      ? (nextMonth >= startMonth && nextMonth <= endMonth)
      : (nextMonth >= startMonth || nextMonth <= endMonth);

    if (!isInActivePeriod) {
      // Find next start of active period
      const nextActiveYear = nextMonth > endMonth && startMonth <= endMonth ? nextExecution.getFullYear() + 1 : nextExecution.getFullYear();
      const nextActivePeriodStart = new Date(nextActiveYear, startMonth - 1, 1);
      nextActivePeriodStart.setUTCHours(startHour, startMinute, startSecond, 0);
      const nextActivePeriodUTC = new Date(nextActivePeriodStart.getTime() - timezoneOffset);
      return nextActivePeriodUTC.toISOString();
    }
  }

  return nextExecution.toISOString();
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

// Convert duration string (e.g. "1h30m") to milliseconds
const durationToMilliseconds = (duration) => {
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

// Check if current time is within active period
const isActiveTime = (schedule, currentTime = new Date()) => {
  if (!schedule.active_period) {
    return true; // No active period restriction
  }

  const currentMonth = currentTime.getMonth() + 1;
  const startMonth = validMonthToNumber(schedule.active_period.start_month);
  const endMonth = validMonthToNumber(schedule.active_period.end_month);

  if (startMonth === null || endMonth === null) {
    return true; // Invalid months, assume active
  }

  // Handle year-spanning periods (e.g., Nov to Mar)
  const isInActivePeriod = startMonth <= endMonth
    ? (currentMonth >= startMonth && currentMonth <= endMonth)
    : (currentMonth >= startMonth || currentMonth <= endMonth);

  return isInActivePeriod;
};

// Scale watering duration based on weather control
const scaleWateringDuration = (schedule, weatherData) => {
  if (!schedule.weather_control || !weatherData) {
    return {
      duration: durationToMilliseconds(schedule.duration),
      scaleFactor: 1,
      adjustments: []
    };
  }

  let scaleFactor = 1;
  const adjustments = [];

  // Temperature scaling
  if (schedule.weather_control.temperature_control && weatherData.average_temperature) {
    const tempControl = schedule.weather_control.temperature_control;
    const currentTemp = weatherData.average_temperature.celsius;

    // Calculate temperature scale factor
    const tempDiff = currentTemp - tempControl.baseline_value;
    const tempScaleFactor = Math.max(0, Math.min(2, 1 + (tempDiff / tempControl.range) * tempControl.factor));

    scaleFactor *= tempScaleFactor;
    adjustments.push({
      type: 'temperature',
      baseline: tempControl.baseline_value,
      current: currentTemp,
      scaleFactor: tempScaleFactor
    });
  }

  // Rain scaling (inverted - more rain = less watering)
  if (schedule.weather_control.rain_control && weatherData.rain) {
    const rainControl = schedule.weather_control.rain_control;
    const currentRain = weatherData.rain.mm;

    // Calculate rain scale factor (inverted)
    const rainDiff = currentRain - rainControl.baseline_value;
    let rainScaleFactor = 1;

    if (rainDiff > 0) {
      // More rain than baseline - reduce watering
      rainScaleFactor = Math.max(0, 1 - (rainDiff / rainControl.range) * rainControl.factor);
    }

    scaleFactor *= rainScaleFactor;
    adjustments.push({
      type: 'rain',
      baseline: rainControl.baseline_value,
      current: currentRain,
      scaleFactor: rainScaleFactor
    });
  }

  // Ensure minimum duration (don't scale below 10% of original)
  scaleFactor = Math.max(0.1, scaleFactor);

  const originalDuration = durationToMilliseconds(schedule.duration);
  const scaledDuration = Math.round(originalDuration * scaleFactor);

  return {
    duration: scaledDuration,
    scaleFactor,
    adjustments,
    originalDuration
  };
};

// Calculate effective watering duration considering weather and skip logic
const calculateEffectiveWateringDuration = (schedule, weatherData, skipCount = 0) => {
  // If skip count is active, return 0 duration
  if (skipCount > 0) {
    return {
      duration: 0,
      scaleFactor: 0,
      reason: 'skipped_due_to_skip_count',
      skipCount,
      adjustments: []
    };
  }

  // Check if we're in active period
  if (!isActiveTime(schedule)) {
    return {
      duration: 0,
      scaleFactor: 0,
      reason: 'outside_active_period',
      adjustments: []
    };
  }

  // Calculate weather-scaled duration
  const scaling = scaleWateringDuration(schedule, weatherData);

  // If weather conditions result in very low duration, skip watering
  if (scaling.duration < 1000) { // Less than 1 second
    return {
      duration: 0,
      scaleFactor: scaling.scaleFactor,
      reason: 'weather_conditions_skip',
      adjustments: scaling.adjustments,
      originalDuration: scaling.originalDuration
    };
  }

  return {
    duration: scaling.duration,
    scaleFactor: scaling.scaleFactor,
    reason: 'normal_watering',
    adjustments: scaling.adjustments,
    originalDuration: scaling.originalDuration
  };
};

// Get next active water schedule from multiple schedules
const getNextActiveWaterSchedule = (waterSchedules) => {
  if (!waterSchedules || waterSchedules.length === 0) {
    return null;
  }

  const activeSchedules = [];

  for (const schedule of waterSchedules) {
    try {
      const nextWaterTime = calculateNextWaterTime(schedule);
      const nextDate = new Date(nextWaterTime);

      if (isActiveTime(schedule, nextDate)) {
        activeSchedules.push({
          schedule,
          nextWaterTime: nextDate
        });
      }
    } catch (error) {
      console.error(`Error calculating next water time for schedule ${schedule.id}:`, error);
    }
  }

  if (activeSchedules.length === 0) {
    return null;
  }

  // Sort by next water time and return the earliest
  activeSchedules.sort((a, b) => a.nextWaterTime - b.nextWaterTime);
  return activeSchedules[0].schedule;
};

// Format duration from milliseconds to human readable string
const formatDuration = (ms) => {
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
  addTimestamps,
  getMockWeatherData,
  getNextWaterTime,
  calculateNextWaterTime,
  validMonthToNumber,
  durationToMilliseconds,
  isActiveTime,
  scaleWateringDuration,
  calculateEffectiveWateringDuration,
  getNextActiveWaterSchedule,
  formatDuration
};