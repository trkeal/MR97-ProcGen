DEFINT A-Z
DECLARE FUNCTION DetectCard% ()
DECLARE SUB SBInit ()
DECLARE SUB WriteReg (Reg%, Value%)
DECLARE SUB SBPlay (note%)
'CONST false = 0, true = NOT false

'include once "old drivers.bas"

DEFINT A-Z
SUB SBInit
'  Initialize the sound card             
                                                        
'(This is the "quick-and-dirty" method; what it's doing is zeroing out

'  all of the card's registers.  I haven't had any problems with this.)


                                                        
FOR q = 1 TO &HF5
  CALL WriteReg(q, 0)
NEXT q
                                                        
END SUB

SUB SBPlay (freq%)
'  Purpose:      Plays a note            
'  Variables:    freq% - Frequency (00-FF hex)
'                duration% - Duration (n seconds) (not used)
'  I'm still working on this part, it may be ugly, but it works <g>.

'  The first group of WriteRegs is the modulator, the second is the

'  carrier.                              
'  If you just want to know how to create your own instrument, play around

'  with the second values in the first four calls to WriteReg in each group.

'  :-)  Have fun!  - Brett               
                                                        
CALL WriteReg(&H20, &HFB)     ' Set modulator's multiple to F
CALL WriteReg(&H40, &H3)    ' Set modulator's level to 40 dB
CALL WriteReg(&H60, &H0)   ' Modulator attack: quick, decay: long

CALL WriteReg(&H87, &HF)   ' Modulator sustain: medium, release: medium
CALL WriteReg(&HA0, freq%)
                                                        
                                                        
CALL WriteReg(&H23, &HF)   ' Set carrier's multiple to 0
CALL WriteReg(&H43, &H0)   ' Set carrier's level to 0 dB
CALL WriteReg(&H63, &HF0)  ' Carrier attack: quick, decay: long

CALL WriteReg(&H83, &HFF)  ' Carrier sustain: quick, release: quick
CALL WriteReg(&HB0, &H20)  ' Octave      
                                                        
CALL WriteReg(&HE0, &H0)   ' Waveform argument for Tom..
                           ' &H00 is the default, but I felt like
                           ' dropping it in for you.. :)
                                                        
' I originally had an extra argument, duration!, but for some reason
' I wanted to do the timing outside of this sub..  You can change it back

' if needs require..                     
                                                        
'TimeUp! = TIMER + duation!              
'WHILE TimeUp! > TIMER: WEND  ' Worst you can be off is .182 of a second

END SUB

FUNCTION DetectCard%
                                                        
'  Purpose:   Detects an AdLib-compatible card.
'             Returns -1 (true) if detected and 0 (false) if not.
'  Variables: Nope                       
                                                        
CALL WriteReg(&H4, &H60)
CALL WriteReg(&H4, &H80)
B = INP(&H388)
CALL WriteReg(&H2, &HFF)
CALL WriteReg(&H4, &H21)
  FOR x = 0 TO 130
    a = INP(&H388)
  NEXT x
c = INP(&H388)
CALL WriteReg(&H4, &H60)
CALL WriteReg(&H4, &H80)
Success = 0
IF (B AND &HE0) = &H0 THEN
  IF (c AND &HE0) = &HC0 THEN
    Success = -1
  END IF
END IF
DetectCard% = Success
END FUNCTION

SUB WriteReg (Reg%, Value%)
'  Purpose:   Writes to any of the SB/AdLib's registers
'  Variables: Reg%: Register number,     
'             Value%: Value to insert in register
'              (Note: The registers are from 00-F5 (hex))
OUT &H388, Reg     '388h = address/status port, 389h = dataport
  FOR x = 0 TO 5   ' This tells the SB what register we want to write to


    a = INP(&H388) ' After we write to the address port we must wait 3.3ms

  NEXT x
                                                        
OUT &H389, Value   ' Send the value for the register to 389h
  FOR x = 0 TO 34  ' Here we must also wait, this time 23ms
    a = INP(&H388)
  NEXT x
END SUB
