
module.exports =

  toYYMMDD : (date) ->
    # date.getYear() doesn't exist in later Node's cuz it suffers from Y2k issues.
    # so, use date.getFullYear() and do mod 100 to get the last two
    # the month is returned as 0-11, so, add one to it
    # the month needs to be zero padded, so, prefix a zero, then grab the last two
    # do the same zero padding for the day's date
    "#{date.getFullYear() % 100}#{('0' + (date.getMonth() + 1))[-2...]}#{('0' + date.getDate())[-2...]}"

  # zero pad both the hour and minute
  toHHMM : (date) -> "#{('0' + date.getHours())[-2...]}#{('0' + date.getMinutes())[-2...]}"
