    org $1000

*-------------------------------------------------------
*Dylan Murphy - C00204772
*Star Wars Game
*Known bugs: if your first collision is pirates
*the timer does not work and you will be left waiting forever
*do not understand why
*-------------------------------------------------------

*-------------------------------------------------------
*Validation values to be used, modify as needed
*Add additional validation values as required
*-------------------------------------------------------
exit        EQU 0      used to exit assembly program
min_fuel    EQU 100    min fuel requirement
max_fuel    EQU 2000   max fuel
min_ship    EQU 1      min number of ships
max_ship    EQU 9      max number of ships
min_crew    EQU 6      min crew
max_crew    EQU 10     max crew
min_rate    EQU 1      min rate of fuel use based of speed
max_rate    EQU 5      max rate e.g. Flank Speed       
hit_point   EQU 5      points accumilated on enemy ship strike
miss_point  EQU 8      points deducted for ordinace miss
min_distance EQU 40    min distance to travel is 40
mine_loc    EQU 100    example for a hit


*Start of Game
start:
    move.b  #100,$4000 put score/health in memory location $4000
    lea     $4000,A3   assign address A3 to that memory location


    bsr     welcome    branch to the welcome subroutine
    bsr     input      branch to the input subroutine
    bsr     game       branch to the game subroutine
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards

*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------
game:
    bsr     gameloop   branch to gameloop subroutine
    rts                return from game: subroutine
          
end:
    simhalt

*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------
welcome:
    bsr     endl            branch to endl subroutine
    lea     welcome_msg,A1  assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    bsr     endl            branch to endl subroutine
    rts                     return from welcome: subroutine

*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*-------------------------------------------------------    
input:
    bsr     fuel            branch to fuel input subroutine
    bsr     ships           branch to ship input subroutine
    bsr     rate            branch to rate (speed) input subroutine
    bsr     distance        branch to mission distance/location input subroutine
    bsr     crew            branch to crew input subroutine
    rts

*-------------------------------------------------------
*----------------Gameloop (main loop)-------------------
*------------------------------------------------------- 
gameloop:
    bsr     update          branch to update game subroutine          
    bsr     draw            branch to draw screen subroutine
    bsr     gameplay        branch to gameplay subroutine
    bsr     hud             branch to display HUD subroutine
    bsr     replay          branch to replay game subroutine
    rts                     return from gameloop: subroutine

*-------------------------------------------------------
*---------------Update Mission Progress-----------------
*  Move to battle location, engage enemy, fire and take
*  fire, complete mission and return to base
*------------------------------------------------------- 
update:
    bsr     endl            print a CR and LF
    bsr     decorate        decorate with dots using a loop
    lea     update_msg,A1   
    move.b  #14,D0
    trap    #15
    move    currentfuel, D4
    move    currentdistance, D5
    cmp     D5, D4
    bhi     distancehi
    blo     distancelow
    bsr     decorate
    rts
 
distancehi:
    lea     distancemsghi,A1
    move.b  #14,D0
    trap    #15
    move.b  #4, D0
    trap    #15
    rts
distancelow:
    lea     distancemsglow,A1
    move.b  #14,D0
    trap    #15
    bra     replay

*-------------------------------------------------------
*---------------Draw Mission Updates--------------------
* Draw the game progress information, status regarding
* mission
*------------------------------------------------------- 
draw:
    bsr     endl
    bsr     decorate
    lea     draw_msg,A1
    move.b  #14,D0
    trap    #15
    lea     starwars,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*-----------------------Ship Fuel-----------------------
* Input the fuel load for each ship. Fuel costs money
* For an advanced mark you need to manage this resource
*------------------------------------------------------- 
fuel:
    bsr     endl
    bsr     decorate
    lea     fuel_msg,A1
    move.b  #14,D0
    trap    #15
    Move.b  #4, D0
    trap    #15
    bsr     FuelValidation
    move    D1, currentfuel
    bsr     decorate
    rts

*-------------------------------------------------------
*--------------------Ship Inventory---------------------
* Number of ships to be allocated to a mission (flotilla)
*------------------------------------------------------- 
ships:
    bsr     endl
    bsr     decorate
    lea     ships_msg,A1
    move.b  #14,D0
    trap    #15
    Move.b  #4, D0
    trap    #15
    bsr     ShipValidation
    move    D1, currentships
    bsr     decorate
    rts

*-------------------------------------------------------
*---------------------Ship(s) Speed---------------------
* Ships speed to and from a mission (flotilla of ships)
*------------------------------------------------------- 
rate:
    bsr     endl
    bsr     decorate
    lea     rate_msg,A1
    move.b  #14,D0
    trap    #15
    Move.b  #4, D0
    trap    #15
    bsr     SpeedValidation
    move    D1, currentspeed
    bsr     decorate
    rts

*-------------------------------------------------------
*------------------Mission Distance---------------------
* Distance to target or battle location
*------------------------------------------------------- 
distance:
    bsr     endl
    bsr     decorate
    lea     distance_msg,A1
    move.b  #14,D0
    trap    #15
    Move.b  #4, D0
    trap    #15
    bsr     DistanceValidation
    move    D1, currentdistance
    bsr     decorate
    rts

*-------------------------------------------------------
*-----------------------Ships Crew----------------------
* Number of crew onboard
*-------------------------------------------------------   
crew:
    bsr     endl
    bsr     decorate
    lea     crew_msg,A1
    move.b  #14,D0
    trap    #15
    Move.b  #4, D0
    trap    #15
    bsr     CrewValidation
    move    D1, currentcrew
    bsr     decorate
    rts

*-------------------------------------------------------
*---Game Play (Mission Progress, Battle Maneuvers)------
*------------------------------------------------------- 
gameplay:
    bsr     endl
    bsr     decorate
    lea     gameplay_msg,A1
    move.b  #14,D0
    trap    #15
    lea     missionstart,A1
    move.b  #14,D0
    trap    #15
    bsr     pause
    bsr     collision
    bsr     pause
    lea     completed,A1
    move.b  #14,D0
    trap    #15
    bsr     calscore
    bsr     decorate
    rts

pause:
    clr     D1
    move.b  2*100, D1
    move.b  #23, D0
    trap    #15
    clr     D1
    rts

calscore:
    move currentcrew*currentships, totalcrew
    move totalcrew, $4000
    rts
*-------------------------------------------------------
*-----------------Heads Up Display (Score)--------------
* Retrieves the score from memory location
*-------------------------------------------------------   
hud:

    bsr     endl
    bsr     decorate
    lea     hud_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  (A3),D1     retrieve the value A3 point to and move to D1
    move.b  #3,D0       move literal 3 to D0
    trap    #15         intrepret value in D0, which 3 which displays D1
    bsr     decorate
    rts

*-------------------------------------------------------
*-----------------------Taking Fire---------------------
* This could be used for collision detection, if 
*-------------------------------------------------------
collision:

   move  currentfuel, D4
   move  currentdistance, D5
   sub   D5, D4
   move  D4, currentfuel
   move  currentfuel, D4
   move  currentdistance, D5
   cmp   D5, D4
   bhi   collisionchance
   
   rts
   
collisionchance:
    
    move.b  #8,d0
    trap    #15
    and.l   #$5FFFFF,d1     prevent overflow in divu
    divu    #100,d1         time count / 100
    swap    d1              swap upper and lower words of D1 to put remainder in low word
    addq.w  #1,d1           d1.w contains number from 1 to 100
    move    d1,d2           d2 = d1
    
    move    #40,d3          1 to 40 is safe
    cmp     d3,d2
    blo     safe
    beq     danger
    bhi     danger
 
safe:
    move.b  #8,d0
    trap    #15
    and.l   #$5FFFFF,d1     
    divu    #100,d1         
    swap    d1              
    addq.w  #1,d1           
    move    d1,d2          
    
    move    #40,d3          
    cmp     d3,d2
    blo     addship
    beq     addfuel
    bhi     addfuel

addship:
    lea     plusship,A1
    move.b  #14,D0
    trap    #15

    move    currentships, D4
    Add     #1, d4
    move.l  d4, d5
    move    d5, currentships
    bsr     collision

addfuel:
    lea     plusfuel,a1
    move.b  #14,d0
    trap    #15
 
    move    currentfuel, d4
    Add     #100, d4
    move.l  d4, d5
    move    d5, currentfuel
    bsr     collision
    
danger:
    lea     piratesmsg,A1
    move.b  #14,d0
    trap    #15

    move.b  #8,d0
    trap    #15
    and.l   #$5FFFFF,d1     
    divu    #100,d1         
    swap    d1              
    addq.w  #1,d1           
    move    d1,d2          
    
    move    #40,d3          
    cmp     d3,d2
    blo     safe
    beq     collisionlost
    bhi     collisionlost


collisionlost:
    move.b  #8,d0
    trap    #15
    and.l   #$5FFFFF,d1     
    divu    #100,d1         
    swap    d1              
    addq.w  #1,d1           
    move    d1,d2          
    
    move    #40,d3          
    cmp     d3,d2
    blo     collisionship
    beq     collisionfuel
    bhi     collisionfuel

collisionfuel:
    bsr     pause
    lea     lostfuel,A1
    move.b  #14,D0
    trap    #15

    move    currentfuel, D4
    sub     #50, D4
    move    D4, D5
    move    D5, currentfuel

    bsr     collision
 
collisionship:
    lea     lostship,A1
    move.b  #14,D0
    trap    #15

    move    currentships, D4
    sub     #1, D4
    move    D4, D5
    move    D5, currentships
    bsr    collision
    
*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------
loop:
    move.b  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     next    repeat until D0=0

*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------
decorate:
    move.b  #60, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
*-------------------------------------------------------
*------------------------Replay-------------------------
*-------------------------------------------------------
replay:
    bsr     endl
    lea     replay_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15

    cmp     #exit,D1
    beq     end         if SR Z register contains 1 beq => Branch Equals
    bsr     start

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
*-------------------------------------------------------
*-------------------Validation--------------------------
*-------------------------------------------------------
FuelValidation:
    cmp     #min_fuel, D1
    blo     FuelError                  validation and then matching errors for each individual variable
    
    rts

FuelError:
    lea     ErrorMsgLow,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    move    D1, currentcrew
    bra     FuelValidation

ShipValidation:
    cmp     #min_ship, D1
    blo     ShipErrorLOW
    
    cmp     #max_ship, D1
    bhi     ShipErrorHigh
    
    rts
    
ShipErrorLow:
    lea     ErrorMsgLow, A1
    move.b  #14, D0
    trap    #15
    
    move.b  #4, D0
    trap    #15
    bra     ShipValidation
    
ShipErrorHigh:
    lea     ErrorMsgHigh, A1
    move.b  #14, D0
    trap    #15
    
    move.b  #4, D0
    trap    #15
    bra     ShipValidation

SpeedValidation:
    cmp     #min_rate, D1
    blo     SpeedErrorLOW
    
    cmp     #max_rate, D1
    bhi     SpeedErrorHigh
    
    rts
    
SpeedErrorLow:
    lea     ErrorMsgLow, A1
    move.b   #14, D0
    trap    #15
    
    move.b #4, D0
    trap    #15
    bra     SpeedValidation
    
SpeedErrorHigh:
    lea     ErrorMsgHigh, A1
    move.b   #14, D0
    trap    #15
    
    move.b   #4, D0
    trap     #15
    bra     SpeedValidation
    
CrewValidation:
    cmp     #min_crew, D1
    blo     CrewErrorLOW

    cmp     #max_crew, D1
    bhi     CrewErrorhigh

    rts
    
CrewErrorLow:
    lea     ErrorMsgLow, A1
    move.b  #14, D0
    trap    #15
    
    move.b   #4, D0
    trap     #15
    bra      CrewValidation
    
CrewErrorhigh:
    lea     ErrorMsghigh, A1
    move.b  #14, D0
    trap    #15
    
    move.b   #4, D0
    trap     #15
    bra      CrewValidation

DistanceValidation:
    cmp     #min_distance, D1
    blo     DistanceError
    
    rts

DistanceError:
    lea     ErrorMsgLow,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    bra     DistanceValidation

    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------
starwars:       dc.b    '************************************************************'
                dc.b    $0d, $0a
                dc.b    ''
                dc.b    $0d,$0a
                dc.b    '   ****  *****  **   *****    ** *** **   **  ****      ****  '
                dc.b    $0d, $0a    
                dc.b    '   **      *   * |*  *  **     *  *  *   * |* * **     **      '
                dc.b    $0d, $0a
                dc.b    ' *****     *   *  *  *   **      ***     *  * *  **  *****  ',0  
crlf:           dc.b    $0D,$0A,0
welcome_msg:    dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    '                   Star Wars The Game                       '
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A,0
fuel_msg:       dc.b    'Fuel load (each ship needs at least 100 units of fuel, max 2000)'
                dc.b    $0D,$0A
                dc.b    'Enter Fuel load : ',0
ships_msg:      dc.b    'Number of mission ships ( between 1 - 9 ) : ',0
rate_msg:       dc.b    'One Third[1], Two Thirds[2], Standard speed[3], ' 
                dc.b    $0D,$0A
                dc.b    'Full Speed[4], Flank Speed[5] units fuel per click'
                dc.b    $0D,$0A
                dc.b    'Enter Speed : ',0
distance_msg:   dc.b    'Mission distance, min is 40 e.g. 40 (with 100 units of fuel  '
                dc.b    $0D,$0A
                dc.b    'One Third speed 20 units remain for manuvouirs) ships '
                dc.b    $0D,$0A
                dc.b    'without fuel are lost.'
                dc.b    $0D,$0A
                dc.b    'Enter mission distance : ',0
crew_msg:       dc.b    'Each ships need at least 5 crew members and a Captain'
                dc.b    $0D,$0A
                dc.b    'minimum requirement is 6, Max is 10 i.e. Captain x 1 and crew x 5.'
                dc.b    $0D,$0A
                dc.b    'Enter # of Crew : ',0
ErrorMsgLow:    dc.b    'Too low, enter a valid number :',0
ErrorMsgHigh:   dc.b    'Too High, enter a valid number :',0
gameplay_msg:   dc.b    'Add Gameplay !',0
                dc.b    $0D, $0A
update_msg:     dc.b    'Update Gameplay !',0
                dc.b    $0D, $0A
draw_msg:       dc.b    'Draw Screen !',0
                dc.b    $0D, $0A
hit_msg:        dc.b    ''
                dc.b    $0D, $0A
                dc.b    'Strike!'
                dc.b    $0D, $0A
                dc.b    '' ,0
miss_msg:       dc.b    'Miss!',0
loop_msg:       dc.b    '.',0
replay_msg:     dc.b    'Enter 0 to Quit any other number to replay : ',0
hud_msg:        dc.b    'Score : ',0
distancemsghi:  dc.b    $0D, $0A
                dc.b    'You have enough fuel to complete the mission'
                dc.b    $0D, $0A
                dc.b    'Enter 1 to go ahead with the mission :',0
distancemsglow: dc.b    $0D, $0A
                dc.b    'You do not have enough fuel to complete the mission',0
                dc.b    $0D, $0A
missionstart:   dc.b    $0D, $0A
                dc.b    'Starting your mission in 5! , 4! , 3! , 2! , 1!,,,,, ',0
                dc.b    $0D, $0A
                
piratesmsg:     dc.b    ''
                dc.b    $0D, $0A
                dc.b    'Pirates ahead!',0
astroidsmsg:    dc.b    ''
                dc.b    $0D, $0A
                dc.b    'Astroids ahead!',0
piratesmsg2:    dc.b    ''
                dc.b    $0D, $0A
                dc.b    'You evaded the pirates!',0
astroidsmsg2:   dc.b    ''
                dc.b    $0D, $0A
                dc.b    'You successfully navigated the astroid field!',0
lostship:       dc.b    ''
                dc.b    $0D, $0A
                dc.b    'You lost a ship!',0
lostfuel:       dc.b    'You lost fuel!',0
                dc.b    $0D, $0A
plusship:       dc.b    ''
                dc.b    $0D, $0A
                dc.b    'You gained a ship!',0
plusfuel:       dc.b    'You gained fuel!',0
                dc.b    $0D, $0A

completed:      dc.b    'Mission Completed!',0
reward:         dc.b    'Youve earned score for each crew member that survived :',0
health:     ds.w    1
score:      ds.w    1 reserve space for score
currentFuel      ds.w    1
currentships     ds.w    1
currentspeed     ds.w    1
currentcrew      ds.w    1
currentdistance  ds.w    1
fuelpership      ds.w    1
totalcrew        ds.w    1
    end start



















*~Font name~Courier~
*~Font size~15~
*~Tab type~1~
*~Tab size~4~
