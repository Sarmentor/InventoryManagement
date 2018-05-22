;;; Include files for communication and BDI agents
__includes ["communication.nls" "bdi.nls" "SellerAgent.nls" "ClientAgent.nls"]

globals [
  ;colects-left
  ;colects-on-sellers
  ;colects-arrived crashed
  mean-buying-price
  mean-time-to-provide-items
  internal-buy-counter
  external-buy-counter
  int-ext-ratio
  ]

breed [ bases base]
breed [clients-arrived client-arrived]
breed [crashes crash]
patches-own [distance-base road street-name]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setting up the Experiment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Procedure that sets up the Simulation Environment.
;;; Used to create the streets, label distances and so forth.
to setupSimulationEnvironment
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  clear-all
  set mean-buying-price 0
  set mean-time-to-provide-items 0
  set internal-buy-counter 0
  set external-buy-counter 0
  set int-ext-ratio 0
  ask patches [
        set pcolor black 
        set road 0
        set distance-base -1]
  setup-streets
  setup-sellers
  setup-clients
  setup-base
  label-patches
  reset-ticks
end 


;;; Setup streets, i.e. areas in grey and places an approrpiate value for the road patch variable.
;;; Road variable is 1 if its a lane and 2 if it is a junction. The value 2, is assigned easily, since lanes
;;; where streets are crossing are accessed twice in the following code. 
to setup-streets
  let px min-pxcor
  while [px <= max-pxcor]
    [
    ask patches with [pxcor = px or pxcor = px + 1 or pxcor = px + 2] [set pcolor grey set road road + 1]
    ask patches with [pycor = px or pycor = px + 1 or pycor = px + 2] [set pcolor grey set road road + 1]
    ask patches with [road = 2] [set pcolor 4]
    set px px + 8
    ]
end

;;; creates the base turtle and places it in the center. It could be placed anywhere, but this looks rather good
;;; in the simulation environment.
to setup-base
  create-bases 1 [
  set shape "pentagon"
  set size 5
  set heading 0
  set color yellow
  setxy pxcor - 1 pycor - 1
  ask patches with [distance myself = 3] [set pcolor yellow 
                                          set distance-base 0]
  ]
end


;;; Setting up the distance guidance
;;; In order to have the sellers to find their way back to the base, every patch that is a part 
;;; of the street has its manhattan distance stored in a patch-own variable distance-base. 
;;; This facilitates directing sellers towards the base. 
to label-patches
  while [any? patches with [distance-base < 0 and road > 0] ]
        [setup-distances-base]  
  
  if show-labeling? [ask patches with [road > 0] [set plabel distance-base]]
end

;;; Auxiliary procedure to compute the distance guidance. 
to setup-distances-base
   let labeled-patches patches with [distance-base >= 0]
   ask labeled-patches [
             let dis distance-base 
             ask neighbors4 with [distance-base < 0 and road > 0] [set distance-base dis + 1]
             ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Running the Experiment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Running the experiment until not more fires are left for simulation and 
;;; no more fires are still buring. 
;;; Asks the sellers to execute their reeactive behaviour and creates colects on various parts
;;; of the area stohastically. 
to run-experiment
  ask sellers [seller-behaviour]
  ask clients [clients-behaviour]
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Place the turtle somewhere where there is noboby else and there is a road. 
to rand-xy-co-on-road
  let x 0
  let y 0
  
  loop [ 
    set x random-pxcor 
    set y random-pycor
    if not any? turtles-on patch-at x y and [road > 0] of patch-at x y [setxy x y stop]
  ]
end 
@#$#@#$#@
GRAPHICS-WINDOW
1140
10
1748
639
22
22
13.303030303030303
1
10
1
1
1
0
1
1
1
-22
22
-22
22
0
0
1
ticks
30.0

SLIDER
142
64
314
97
no-of-sellers
no-of-sellers
0
5
5
1
1
NIL
HORIZONTAL

SLIDER
142
103
314
136
nclients
nclients
0
100
2
1
1
NIL
HORIZONTAL

BUTTON
7
66
74
99
Set up
setupSimulationEnvironment
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
7
105
126
138
Run Experiment
run-experiment
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
6
209
172
254
NIL
ticks
17
1
11

SWITCH
183
240
319
273
show-labeling?
show-labeling?
1
1
-1000

SLIDER
143
143
315
176
speed
speed
0
2
2
0.1
1
NIL
HORIZONTAL

BUTTON
7
144
70
177
Step
run-experiment
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
184
275
330
308
show_messages
show_messages
1
1
-1000

SWITCH
184
311
329
344
show-intentions
show-intentions
1
1
-1000

SLIDER
184
354
356
387
cfp-deadline
cfp-deadline
0
100
15
5
1
NIL
HORIZONTAL

SLIDER
183
391
355
424
auction_rounds
auction_rounds
3
10
3
1
1
NIL
HORIZONTAL

SWITCH
182
203
320
236
internal-trade
internal-trade
0
1
-1000

PLOT
394
51
594
201
int-ext-ratio
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot int-ext-ratio"

PLOT
632
51
832
201
Mean Buying Price
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean-buying-price"

PLOT
396
244
596
394
Internal Buy Counter
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot internal-buy-counter"

PLOT
629
244
829
394
External Buy Counter
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot external-buy-counter"

PLOT
860
51
1060
201
Average time to provide (Ticks)
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean-time-to-provide-items"

MONITOR
8
266
137
311
Internal Buy Counter
internal-buy-counter
17
1
11

MONITOR
9
318
141
363
External Buy Counter
external-buy-counter
17
1
11

MONITOR
11
373
174
418
Internal and External Ratio
int-ext-ratio
17
1
11

MONITOR
861
245
1080
290
Average time to provide (Ticks) Value
mean-time-to-provide-items
3
1
11

MONITOR
861
302
974
347
Mean Buying Price
mean-buying-price
3
1
11

@#$#@#$#@
## WHAT IS IT?

A simple multi agent scenario, simulating the seller transportation in a city.   
The passangers appear in random locations and at random times and initiate a Contract Net to find the nearest available seller.   

## HOW IT WORKS

sellers have to move only on the predetermined lanes and avoid collisions between them. This is controlled by the reactive layer of the seller agent.

As soon as a passenger agent appears in the simulation environment, it inites a Contract Net protocol in order to locate the nearest seller. Its initial color is yellow. As soon it successfully locates a seller for trasportation to the base, its color becomes green.   
sellers receive the original cfp and report back their position from the initiator passenger. Upon acceptance of their proposal, they form a plan to pick-up the passenger and transport him to the base.

Travelling to the base is done by moving on the patch that has the closest distance from the base. This distance is stored in the patch-own distance-base variable.

## PARAMETERS

A number of parameters control the experiment.   
- Number of sellers  
- Number of colects  
- Probability to turn: defines the probability according to which the agent will decide to turn on a junction.   
- Speed: The travelling Speed of the agents.  
- Show labelling: Indicates the disctance of each patch from the base (used to guide sellers to the base-i.e. map)  
- Show messages/intetions: Simple debugging for BDI libraries.  
- CFP deadline: deadline for cfp in the contract Net.  
- Crash control: controling whether an agent has crashed on something (ex due to high speed).

## CREDITS AND REFERENCES

Described in   
I. Sakellariou, P. Kefalas, and I. Stamatopoulou. MAS coursework design in NetLogo. In M. Beer, M. Fasli, and D. Richards, editors, Proceedings of the International Workshop on the Educational Uses of Multi-Agent Systems (EDUMAS'09), pages 47-54, 2009.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

base
true
0
Rectangle -13345367 true false 255 0 270 300
Rectangle -13345367 true false 30 0 45 300
Polygon -7500403 true true 150 15 135 30 120 75 120 120 30 165 30 195 120 180 135 225 105 255 120 270 150 255 180 270 195 255 165 225 180 180 270 195 270 165 180 120 180 75 165 30
Line -1 false 150 0 150 45
Line -1 false 150 75 150 120
Line -1 false 150 150 150 195
Line -1 false 150 225 150 270
Line -1 false 150 285 150 300

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

client
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

crash
true
0
Polygon -2674135 true false 150 0 120 105 30 60 90 150 30 225 150 180 90 285 150 225 210 285 180 180 285 165 195 135 240 30 150 105

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

seller
true
0
Rectangle -7500403 true true 60 -15 240 285
Rectangle -1184463 true false 45 90 60 210
Rectangle -7500403 true true 45 45 60 90
Polygon -16777216 true false 210 120 90 120 75 105 75 90 75 75 105 60 120 60 150 60 180 60 195 60 225 75 225 105
Polygon -16777216 true false 225 225 210 210 210 180 225 180 225 225
Polygon -16777216 true false 75 165 90 165 90 135 75 120 75 165
Polygon -16777216 true false 225 165 210 165 210 135 225 120 225 165
Polygon -16777216 true false 75 225 90 210 90 180 75 180 75 225
Polygon -16777216 true false 195 255 105 255 90 240 90 225 105 210 150 210 180 210 195 210 210 225 210 240
Rectangle -7500403 true true 45 210 60 255
Rectangle -7500403 true true 240 210 255 255
Rectangle -7500403 true true 240 45 255 90
Rectangle -1184463 true false 240 90 255 210
Rectangle -1184463 true false 120 150 150 180
Line -16777216 false 105 0 105 60
Line -16777216 false 195 0 195 60
Line -16777216 false 60 120 75 120
Line -16777216 false 225 120 240 120
Line -16777216 false 60 225 75 225
Line -16777216 false 225 225 240 225
Rectangle -2674135 true false 60 285 90 300
Rectangle -2674135 true false 210 285 240 300
Polygon -1 true false 75 0 105 0 75 30
Polygon -1 true false 225 0 195 0 225 30
Rectangle -1184463 true false 90 180 120 210
Rectangle -1184463 true false 150 180 180 210
Rectangle -1184463 true false 180 150 210 180
Line -16777216 false 60 45 60 255
Line -16777216 false 240 45 240 255
Rectangle -1184463 true false 150 120 180 150
Rectangle -1184463 true false 90 120 120 150

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
