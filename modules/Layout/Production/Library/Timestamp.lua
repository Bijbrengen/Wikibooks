local timestamp = {}

function timestamp.valid( day, month, year )
  -- Check if the year is a leap year.
  local isLeapYear = year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0);

  -- Check if the day is within the valid range for the given month and year.
  local daysInMonth = {31, isLeapYear and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
  
  -- If the day is less or equal then the maximum for the given month the date is ok.
  return day <= daysInMonth[ month ];
end

return timestamp;
