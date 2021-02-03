#!/usr/bin/wish
package require Tk

if { $argc != 1 } {
  puts "No password given"
  exit 1
}

set password [lindex $argv 0]

wm title . "$password"
grid [ttk::frame .c -padding "3 3 12 12"] -column 0 -row 0 -sticky news
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

set row 0

set xclip [open "|xclip -o"]
set inclip [read $xclip]
close $xclip

proc cleanup {} {
  clipboard $::inclip
  destroy .
}

wm protocol . WM_DELETE_WINDOW cleanup
bind . <KeyPress-Escape> cleanup

proc clipboard {value} {
  set xclip [open "|xclip" w]
  puts -nonewline $xclip $value
  close $xclip
}

proc otp {name} {
  set passotp [open [list "|pass" "otp" $name]]
  set code [read -nonewline $passotp]
  close $passotp
  clipboard $code
}

set output [open |[list pass show $password]]
while { [gets $output line] >= 0 } {
  if { $row == 0} {
    grid [
      ttk::button .c.b$row -text "Password" -command [list clipboard $line]
      ] -column 0 -row $row -sticky e
    incr row
  } elseif {[set colon [string first ":" $line]] != -1} {
    set label [string trim [string range $line 0 [expr {$colon - 1}]]]
    set value [string trim [string range $line [expr {$colon + 1}] end]]
    if {[string compare $label "otpauth"]} {
      set command [list clipboard $value]
    } else {
      set command [list otp $password]
    }
    grid [
      ttk::button .c.b$row -text "$label" -command $command
      ] -column 0 -row $row -sticky e
    incr row
  }
}
close $output

foreach w [winfo children .c] {grid configure $w -padx 5 -pady 5}

wm geometry . -5+30
wm attributes . -topmost yes
