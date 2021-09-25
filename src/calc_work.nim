from math import splitDecimal
from strformat import fmt
from strutils import parseInt, split
from terminal import setForegroundColor, ForegroundColor

type
  WorkDay = tuple
    begin: int
    lunch: tuple[begin: int, finish: int]
    finish: int

var
  shift: WorkDay

# Reads user input and parses looking for a time (HH:MM)
proc readTime (message: string): int =
  var time: seq[string] = @[]

  proc ask (): bool =
    setForegroundColor ForegroundColor.fgCyan
    echo message & " (24h format - HH:MM)"
    setForegroundColor ForegroundColor.fgWhite

    time = readLine(stdin).split(":")

  discard ask()
  while time.len <= 1 or time[0].parseInt > 24: discard ask()

  # Convert hour to minutes and add up with the minutes
  return time[0].parseInt * 60 + time[1].parseInt

#[
  Reads user input and spits back the amount of time they worked and how it affects their hour bank.
]#
proc main () =
  shift.begin = readTime "Provide me with the time you started your shift."
  shift.lunch = (begin: readTime("Provide me with the time you started your lunch break."), finish: readTime("Provide me with the time you finished your lunch break."))
  shift.finish = readTime "Provide me with the time you finished your shift."

  # How long does the shift lasts
  let shiftLength = readTime "Provide me with how long your shift is supposed to last."

  # How long they worked in hours.
  let workedForHours = (shift.finish - (shift.lunch.finish - shift.lunch.begin) - shift.begin) / 60

  # Make the amount of time they worked for more readable
  let workHourMinute = workedForHours.splitDecimal
  let workedMinutes: float = workHourMinute.floatpart * 100 * 60 / 100
  let workedHours = workHourMinute.intpart

  # Make the amount of time added/subtracted to their bank more readable
  let bankTime = (workedHours * 60 + workedMinutes - shiftLength.float) / 60
  let bankHourMinute = bankTime.splitDecimal
  let bankMinutes:float = (bankHourMinute.floatpart * 100 * 60 / 100).abs
  let bankHours = bankHourMinute.intpart.abs

  # Set whether the amount of time to their hour bank adds up or subtracts
  var bankSign: string = "-"
  if bankTime > 0: bankSign = "+"

  setForegroundColor ForegroundColor.fgGreen
  echo fmt"You've worked {workedHours.int}h{workedMinutes.int} today. Bank = {bankSign}{bankHours.int}h{bankMinutes.int}"

  setForegroundColor ForeGroundColor.fgYellow
  echo "\nPress ENTER to finish..."
  discard readLine stdin # "Pause" the program for them to see the results.

when isMainModule:
  main()
