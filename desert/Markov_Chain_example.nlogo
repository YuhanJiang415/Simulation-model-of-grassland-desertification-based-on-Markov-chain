;;Markov model by Ben Davies
;;For more information see https://simulatingcomplexity.wordpress.com/2015/02/10/fun-with-markov-chains-a-tutorial-using-netlogo/

extensions [ gis ]
globals [
  weather
  NDVI-dataset    ;;NDVI
  to-desert
  wet-day
  dry-day
  num
]

patches-own [ growth NDVI countdown countdown-memory deserttime ]

; Sheep and wolves are both breeds of turtles
breed [ sheep a-sheep ]  ; sheep is its own plural, so we use "a-sheep" as the singular
breed [ wolves wolf ]
sheep-own [ energy ]       ; both wolves and sheep have energy
wolves-own [ energy ]

breed [sands sand]    ;; bright red turtles -- the leading edge of the sand
;breed [embers ember]  ;; turtles gradually fading from red to near black

;;clear the model, create weather variable with two states: wet or dry
;;seed patches with random growth and scale their colour accordingly
to setup
;  clear-all
;;;grass NDVI or Random
;  ifelse Grass = "Random"[
;  ask patches [
;    set growth random-float 10
;    set pcolor scale-color green growth 10 0
;    set countdown random min-grass-regrowth-time  ; initialize grass regrowth clocks randomly for brown patches
;    set countdown-memory countdown
;    set deserttime min-desert-spread-time
;    ]
;  ]
;  [
;  ; Note that setting the coordinate system here is optional, as
;  ; long as all of your datasets use the same coordinate system.
;  ;gis:load-coordinate-system (word projection ".prj")
;
;  display-NDVI-in-patches
;  match-cells-to-patches
;  ]
;;weather
;set weather one-of [ "WET" "DRY" ]
;
;;;Creat sheeps and wolves
;   create-sheep initial-number-sheep  ; create the sheep, then initialize their variables
;  [
;    set shape  "sheep"
;    set color pink
;    set size 1.5  ; easier to see
;    set label-color blue - 2
;    set energy random (2 * sheep-gain-from-food)
;    setxy random-xcor random-ycor
;  ]
;  create-wolves initial-number-wolves  ; create the wolves, then initialize their variables
;  [
;    set shape "wolf"
;    set color blue
;    set size 2  ; easier to see
;    set energy random (2 * wolf-gain-from-food)
;    setxy random-xcor random-ycor
;  ]
;;;Desert center
;  if Desert = "Random"[
;  create-sands 3
;  [
;    set shape "square"
;    setxy random-xcor random-ycor
;    set color brown
;    set size 2  ; easier to see
;
;  ]
;  ]
;  if Desert = "Edge" [
;  set-default-shape turtles "square"
;  ;; make a column of burning trees
;  ask patches with [pxcor = min-pxcor]
;    [
;   sprout-sands 1
;    [ set color brown ]
;    ;set burned-trees burned-trees + 1
;    ;set deserttime min-desert-spread-time
;    set growth 0
;    set pcolor brown
;   ]
;  ]
;  if Desert = "Min-growth" [
;    set-default-shape turtles "square"
;  ;; make a column of burning trees
;    ask patches with [ growth = min [growth] of patches ]
;    [
;      sprout-sands 1
;      [ set color brown ]
;    ;set burned-trees burned-trees + 1
;    ;set deserttime min-desert-spread-time
;    set growth 0
;    set pcolor brown
;   ]
;  ]
;
;;;calculator
;  set to-desert count patches with [pcolor = brown]
;
;  ifelse weather = "WET"
;  [set wet-day 1]
;  [set dry-day 1]

  set num 5
  file-open (word Grass Desert ".txt")
  file-print "DTW WTD g_grow d_grow s_number s_food s_repro w_number w_food w_repro ticks"
  ;file-close

initial

;  reset-ticks

end

to go

  ; stop the model if there are no wolves and the number of sheep gets very large
   if (to-desert / count patches ) > 0.7
  [

    user-message "The land is about to turn into a desert"
    file-print (word DTW " " WTD " " min-grass-regrowth-time " " min-desert-spread-time " " initial-number-sheep " " sheep-gain-from-food " " sheep-reproduce " " initial-number-wolves " " wolf-gain-from-food " " wolf-reproduce " " ticks)
    file-flush
    set min-desert-spread-time min-desert-spread-time + 1

    initial
    set num num - 1
    if (num < 0)[
    file-close
    stop
    ]
  ]

  ; stop the model if there are no wolves and no sheep;; either sands or embers
  ;if not any? turtles [ stop ]

;  if count sheep = 0 [
;     create-sheep initial-number-sheep  ; create the sheep, then initialize their variables
;   [
;    set shape  "sheep"
;    set color pink
;    set size 1.5  ; easier to see
;    set label-color blue - 2
;    set energy random (2 * sheep-gain-from-food)
;    setxy random-xcor random-ycor
;   ]
;  ]
;  if count wolves = 0 [
;   create-wolves initial-number-wolves  ; create the wolves, then initialize their variables
;   [
;    set shape "wolf"
;    set color blue
;    set size 2  ; easier to see
;    set energy random (2 * wolf-gain-from-food)
;    setxy random-xcor random-ycor
;   ]
;  ]

    markov-rain

    ask sands
    [
      ask neighbors4 with [pcolor > 59.9 ]
        [
        ignite
       ]
    ]

   ask sheep [
     move
     ;in this version, sheep eat grass, grass grows, and it costs sheep energy to move
     set energy energy - 1  ; deduct energy for sheep only if running sheep-wolves-grass model version
     eat-grass  ; sheep eat grass only if running the sheep-wolves-grass model version
     death ; sheep die from starvation only if running the sheep-wolves-grass model version
    if count sheep < max-sheep [
    reproduce-sheep  ; sheep reproduce at a random rate governed by a slider
    ]
  ]

  ask wolves [
    move
    set energy energy - 1  ; wolves lose energy as they move
    eat-sheep ; wolves eat a sheep on their patch
    death ; wolves die if they run out of energy
    reproduce-wolves ; wolves reproduce at a random rate governed by a slider
  ]

  ask patches [grow-grass]

  set to-desert count patches with [pcolor = brown]
  ;if ticks = 500 [ stop ]

  ifelse weather = "WET"
  [
    set wet-day wet-day + 1
  ]
  [set dry-day dry-day + 1]

    file-open ("weather.txt")
    file-print weather
    file-flush

  tick
end

to initial
 ; clear-all
;;grass NDVI or Random
    clear-ticks
    clear-turtles
    clear-patches
    clear-drawing
    clear-all-plots
    clear-output
;Grass
  ifelse Grass = "Random"[
    ask patches with [(random 100) < density]
    [
    set growth random-float 10
    set pcolor scale-color green growth 10 0
    set countdown random min-grass-regrowth-time  ; initialize grass regrowth clocks randomly for brown patches
    set countdown-memory countdown
    set deserttime min-desert-spread-time
    ]
    ask patches with[growth = 0]
    [
    set pcolor scale-color green growth 10 0
    set countdown 11 * min-grass-regrowth-time  ; initialize grass regrowth clocks randomly for brown patches
    set countdown-memory countdown
    set deserttime min-desert-spread-time
    ]
  ]
  [
  ; Note that setting the coordinate system here is optional, as
  ; long as all of your datasets use the same coordinate system.
  ;gis:load-coordinate-system (word projection ".prj")

  display-NDVI-in-patches
  match-cells-to-patches
  ]
;weather
set weather one-of [ "WET" "DRY" ]

;;Creat sheeps and wolves
   create-sheep initial-number-sheep  ; create the sheep, then initialize their variables
  [
    set shape  "sheep"
    set color pink
    set size 1.5  ; easier to see
    set label-color blue - 2
    set energy random (2 * sheep-gain-from-food)
    setxy random-xcor random-ycor
  ]
  create-wolves initial-number-wolves  ; create the wolves, then initialize their variables
  [
    set shape "wolf"
    set color blue
    set size 2  ; easier to see
    set energy random (2 * wolf-gain-from-food)
    setxy random-xcor random-ycor
  ]
;;Desert center
  if Desert = "Random"[
  create-sands 3
  [
    set shape "square"
    setxy random-xcor random-ycor
    set color brown
    set size 2  ; easier to see

  ]
  ]
  if Desert = "Edge" [
  set-default-shape turtles "square"
  ;; make a column of burning trees
  ask patches with [pxcor = min-pxcor]
    [
   sprout-sands 1
    [ set color brown ]
    ;set burned-trees burned-trees + 1
    ;set deserttime min-desert-spread-time
    set growth 0
    set pcolor brown
   ]
  ]
  if Desert = "Min-growth" [
    set-default-shape turtles "square"
  ;; make a column of burning trees
    ask patches with [ growth = min [growth] of patches ]
    [
      sprout-sands 1
      [ set color brown ]
    ;set burned-trees burned-trees + 1
    ;set deserttime min-desert-spread-time
    set growth 0
    set pcolor brown
   ]
  ]

;;calculator
  set to-desert 0
  set to-desert count patches with [pcolor = brown]


  set wet-day 0
  set dry-day 0
  ifelse weather = "WET"
  [set wet-day 1]
  [set dry-day 1]

   reset-ticks
end


to display-NDVI-in-patches
  ;clear-all
    clear-ticks
    clear-turtles
    clear-patches
    clear-drawing
    clear-all-plots
    clear-output
  set NDVI-dataset gis:load-dataset "mminndvi.asc"
  ; Set the world envelope to the union of all of our dataset's envelopes
  gis:set-world-envelope gis:envelope-of NDVI-dataset
  let horizontal-gradient gis:convolve NDVI-dataset 3 3 [ 1 1 1 0 0 0 -1 -1 -1 ] 1 1
  let vertical-gradient gis:convolve NDVI-dataset 3 3 [ 1 0 -1 1 0 -1 1 0 -1 ] 1 1

  gis:paint NDVI-dataset 0

  ; This is the preferred way of copying values from a raster dataset
  ; into a patch variable: in one step, using gis:apply-raster.
  gis:apply-raster NDVI-dataset NDVI
  ; Now, just to make sure it worked, we'll color each patch by its
  ; NDVI value.
  let min-NDVI gis:minimum-of NDVI-dataset
  let max-NDVI gis:maximum-of NDVI-dataset
  ask patches
  [ ; note the use of the "<= 0 or >= 0" technique to filter out
    ; "not a number" values, as discussed in the documentation.
    if (NDVI <= 0) or (NDVI >= 0)
    [ set pcolor scale-color black NDVI min-NDVI max-NDVI ] ]
end

; This is an example of how to select a subset of a raster dataset
; whose size and shape matches the dimensions of the NetLogo world.
; It doesn't actually draw anything; it just modifies the coordinate
; transformation to line up patch boundaries with raster cell
; boundaries. You need to call one of the other commands after calling
; this one to see its effect.
to match-cells-to-patches
  gis:set-world-envelope gis:raster-world-envelope NDVI-dataset 0 0
  clear-drawing
  ;clear-turtles
  ask patches[
  set growth (NDVI ^ 0.25) * (2 ^ 1.5) / max [NDVI] of patches * 10
  set pcolor scale-color green growth 10 0
    ifelse growth != 0 and max [growth] of patches != 0[
      set countdown min-grass-regrowth-time / ( growth / max [growth] of patches );
    ]
    [set countdown min-grass-regrowth-time * 11 ]
    set countdown-memory countdown
    set deserttime min-desert-spread-time
  ]
end


;; creates the sand turtles
to ignite  ;; patch procedure

 ifelse deserttime <= 0 [
  sprout-sands 1
    [ set color brown ]
  set pcolor brown
  ;set burned-trees burned-trees + 1
  set deserttime min-desert-spread-time
  ]
  [
  set deserttime deserttime - 1
  ]
end

;;; achieve fading color effect for the sand as it burns
;to fade-embers
;  ask sands
;    [ set color color - 0.3  ;; make red darker
;      if color < red - 3.5     ;; are we almost at brown?
;        [ set pcolor brown
;          ;die
;  ] ]
;end
;

;;if the weather is currently wet AND a randomly drawn value between 0 and 1 is less
;;than the wet-to-dry transition, transition to dry conditions
;;ELSE
;;if the weather is currently dry AND a randomly drawn value between 0 and 1 is less
;;than the wet-to-dry transition, transition to wet conditions
to markov-rain
  ifelse weather = "WET" [
    if random-float 1.000 < WTD [
      set weather "DRY"

    ]
  ]
  [
    if random-float 1.000 < DTW [
      set weather "WET"
    ]
  ]
end

;;if conditions are wet AND grass is not at its maximum, grow grass and recolor patches
;;ELSE
;;if conditions are dry AND grass is not at its minimum, decrease grass and recolor patches
to grow-grass
  ifelse weather = "WET" [
    ifelse countdown <= 0[
    if growth <= 9 and pcolor != brown [
      set growth growth + 1
      set pcolor scale-color green growth 10 0
    ]
    if 9 < growth and growth < 10 and pcolor != brown [
      set growth 10
      set pcolor scale-color green growth 10 0
    ]
      set countdown countdown-memory
    ]
    [
     set countdown countdown - 1
    ]
  ]
  [
    if growth > 1 and pcolor != brown [
      set growth growth - 1
      set pcolor scale-color green growth 10 0
    ]
    if growth <= 1 and pcolor != brown [
      set growth 0
      set pcolor scale-color green growth 10 0
    ]
  ]
end


to move  ; turtle procedure
  rt random 50
  lt random 50
  fd 1
end

to eat-grass  ; sheep procedure
;  ; sheep eat grass and turn the patch brown
;  ifelse growth > 1 [
;    set energy energy + (sheep-gain-from-food * growth / 10)  ; sheep gain energy by eating
;    set growth 0
;    set pcolor scale-color green growth 10 0
;  ]
;  [
;  set energy energy
;  ]
if pcolor != brown [
  set energy energy + (sheep-gain-from-food * growth / 10)  ; sheep gain energy by eating
  set growth 0
  set pcolor scale-color green growth 10 0
  ]

end

to reproduce-sheep  ; sheep procedure
  if random-float 100 < sheep-reproduce [  ; throw "dice" to see if you will reproduce
    set energy (energy / 2)                ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]   ; hatch an offspring and move it forward 1 step
  ]
end

to reproduce-wolves  ; wolf procedure
  if random-float 100 < wolf-reproduce [  ; throw "dice" to see if you will reproduce
    set energy (energy / 2)               ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]  ; hatch an offspring and move it forward 1 step
  ]
end

to eat-sheep  ; wolf procedure
  let prey one-of sheep-here                    ; grab a random sheep
  if prey != nobody  [                          ; did we get one? if so,
    ask prey [ die ]                            ; kill it, and...
    set energy energy + wolf-gain-from-food     ; get energy from eating
  ]
end

to death  ; turtle procedure (i.e. both wolf and sheep procedure)
  ; when energy dips below zero, die
  if energy < 0 [ die ]
end
@#$#@#$#@
GRAPHICS-WINDOW
224
24
787
588
-1
-1
5.5
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

SLIDER
19
279
190
312
WTD
WTD
0
1.00
0.12
0.01
1
NIL
HORIZONTAL

SLIDER
19
311
190
344
DTW
DTW
0
1.00
0.3
0.01
1
NIL
HORIZONTAL

BUTTON
76
10
133
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
22
10
77
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
805
252
1149
417
Grass
Time
Growth
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"grass" 1.0 0 -14439633 true "" "plot mean [ growth ] of patches"

SLIDER
21
363
191
396
initial-number-sheep
initial-number-sheep
0
500
200.0
1
1
NIL
HORIZONTAL

SLIDER
19
511
190
544
initial-number-wolves
initial-number-wolves
0
500
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
22
346
172
364
Sheep setting
12
0.0
1

SLIDER
21
396
191
429
sheep-gain-from-food
sheep-gain-from-food
0
50
4.0
1
1
NIL
HORIZONTAL

SLIDER
21
428
191
461
sheep-reproduce
sheep-reproduce
0
100
4.0
1
1
%
HORIZONTAL

TEXTBOX
22
495
172
513
Wolf settings
12
0.0
1

SLIDER
19
544
190
577
wolf-gain-from-food
wolf-gain-from-food
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
19
576
190
609
wolf-reproduce
wolf-reproduce
0
100
5.0
1
1
%
HORIZONTAL

PLOT
804
85
1148
252
population
Time
NIL
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"sheep" 1.0 0 -1664597 true "" "plot count sheep"
"wolves" 1.0 0 -13345367 true "" "plot count wolves"

MONITOR
805
32
862
77
sheep
count sheep
0
1
11

MONITOR
860
32
917
77
wolves
count wolves
0
1
11

MONITOR
916
32
974
77
grass
mean [growth] of patches
2
1
11

CHOOSER
20
60
188
105
Grass
Grass
"Random" "NDVI"
0

CHOOSER
19
186
189
231
Desert
Desert
"Min-growth" "Random" "Edge" "No"
1

SLIDER
20
103
188
136
min-grass-regrowth-time
min-grass-regrowth-time
0
10
1.0
1
1
NIL
HORIZONTAL

MONITOR
1031
32
1089
77
weather
weather
17
1
11

MONITOR
974
32
1031
77
Desert
to-desert / (count patches)
2
1
11

TEXTBOX
22
263
171
281
Weather setting
12
0.0
1

TEXTBOX
24
44
141
62
Grass seting
12
0.0
1

SLIDER
19
229
189
262
min-desert-spread-time
min-desert-spread-time
0
100
10.0
1
1
NIL
HORIZONTAL

TEXTBOX
23
170
173
188
Desertification setting
12
0.0
1

PLOT
805
417
1149
581
weather
Time
daycount
0.0
100.0
0.0
1.0
true
true
"" ""
PENS
"DRY" 1.0 0 -2674135 true "" "plot dry-day / (dry-day + wet-day)"
"WET" 1.0 0 -8990512 true "" "plot wet-day / (dry-day + wet-day)"

BUTTON
133
10
188
43
NDVI
display-NDVI-in-patches
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
20
136
188
169
density
density
0
100
80.0
1
1
%
HORIZONTAL

SLIDER
21
461
191
494
max-sheep
max-sheep
0
1000
1000.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

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

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
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
