; ABM - LASSA FEVER TRANSMISSION
; STUDENT NAME: VICTOR ODOH
; ID: C2397722
; SCEDT, TEESSIDE UNIVERSITY
; Year: 2022




; Two agentsets are involved in this Model (Humans and rats)
; Hence defining two breeds as follows
breed [humans human]
breed [rats rat]

;       COLOUR CODES:
; Red rat (red - 2) - Multimammate Rat (All Assumed to be infectious)
; White Human - Healthy, not infected/infectious
; Yellow Human - Infected but not infectious (within virus incubation period)
; Orange Human (orange + 2) - Infectious with Mild Symptoms
; Red Human - Infectious with Severe Symptoms
; Cyan Human - Recovered, immune but still Infectious
; Lime Human (lime + 1) - Fully recovered and immune
; Gray Human - Dead


; Declaring humans owned variables
humans-own [
  hours            ; each tick represents an hour
  human_speed      ; to control human speed
]

; Declaring all global variables used...
; (excluding the sliders which do not need to be declared here)
globals [
  control_speed               ; to regulate speed of model
  infected_not_infectious     ; current count of infected humans within virus incubation period
  initial_mild_cases
  initial_severe_cases
  mild_cases_count         ; current count of all mild cases
  severe_cases_count       ; current count of all severe cases
  severe_cases             ; counting variable for infected humans with severe symptoms
  mild_cases               ; counting variable for infected humans with mild symptoms or asymptomatic
  total_mild_cases         ; includes intial mild cases
  total_severe_cases       ; includes initial severe cases
  fatalities               ; counting variable for human deaths
  total_fatalities         ; count of all deaths ever recorded
  immune_infectious      ; current count of recovered and immune humans that are still carriers
  immune_not_infectious  ; current count of immune humans who are no longer carriers
  %Mild_Cases
  %infected
  %uninfected
  %immune
  average_%CFR           ; average case fatality rate in percentage

  immune_or_severe_%infectiousness     ; virus spread chance of immune/recovered carriers
                                       ; or humans with severe symptoms assuming that they are hospitalized/isolated and pose little
                                       ; risk of infecting others

  current_cases       ; number of cases at the curent time
  total_cases         ; Count of all cases ever recorded : addition of counting variables (mild_cases + severe_cases)
  total_immune        ; includes both immune carriers and immune with no virus
  total_infected      ; all carrier humans
  total_infectious    ; all carrier humans excluding infected_not_infectious
]

; Defining the "setup" command procedure:
; Assigning initial values
to setup
  clear-all
  reset-ticks
  set %Mild_Cases (100 - %Severe_Cases)
  set initial_mild_cases (Initial_Number_Of_Cases * %Mild_Cases) / 100
  set initial_severe_cases (Initial_Number_Of_Cases * %Severe_Cases) / 100
  set immune_or_severe_%infectiousness %Infectiousness_Human_to_Human * (1 - Human_Behaviour_Factor)

  ; Declaring basic constant of the model
  set control_speed 1


  ; creating the rat agents with their properties
  ; Distributing them randomly across the patches/world
  create-rats Multimammate_Rat_Population [
    setxy random-xcor random-ycor
    set shape "mouse side"
    set color red - 2
    set size 0.8
  ]

  ; creating the human agents with initially infected humans
  ; Distributing them randomly across the patches/world
  create-humans Human_Population [
    setxy random-xcor random-ycor
    set shape "person"
    set color white
    set size 1
    set human_speed control_speed
  ]

  ; color coding to identify initial mild/severe cases
  ask n-of initial_mild_cases Humans
   [set color orange + 2]
  ask n-of initial_severe_cases Humans
   [ set color red ]
end       ; end of setup command procedure

; Defining the "go" command procedure:
to go
  ; asking rats to move randomly across the world
  ask rats [
    fd control_speed * -1 * ((1 / Human_Behaviour_Factor) * 0.01)
    rt random 100 lt random 100
  ]
  ; asking humans to move randomly across the world
  ask humans [
    fd human_speed * ((1 / Human_Behaviour_Factor) * 0.01)
    rt random 45 lt random 45
    set hours hours + 1    ; advancing hours counting variables
  ]

  ; asking humans that are infectious and applying human to human infection probability..
  ; ..to a nearby uninfected human, for possible infection
  ; color coding to identify each case
  ask humans [
    ifelse (color = orange + 2) [
      ask other humans-here [
        if random 100 < %Infectiousness_Human_to_Human [
          if color = white [
            set color yellow
            set infected_not_infectious infected_not_infectious + 1
            set hours 0
          ]
        ]
      ]
    ]

    ; asking rats and applying rat to human infection probability
    ; to nearby uninfected human in contact, for possible infection
    [
      ask rats [
        ask other humans-here [
          if random-float 100 < %Infectiousness_rat_to_Human [
            if color = white [
              set color yellow
              set hours 0
            ]
          ]
        ]
      ]
    ]

    ; If hospitalized or immune carrier, applying infection probability for possible infection...
    ; ... of other uninfected humans nearby
    if (color = cyan) or (color = red) [
      ask other humans-here [
        if random-float 100 < immune_or_severe_%infectiousness [
          if (color = white) [
            set color yellow
            set hours 0
          ]
        ]
      ]
    ]

    ; converting incubation period in days to hours
    ; what should happen if infection has exceded incubation period?
    ; applying %Severe_Cases probabilty to determine if an infected human...
    ; ... falls under the mild or severe case
    if (color = yellow) and (hours > (incubation_Period * 24)) [
      ifelse random-float 100 < %Severe_Cases [
        set color red
        set severe_cases severe_cases + 1   ; advancing severe_cases counting variable
        set hours 0
        set human_speed 0          ; if severe, assumes human is hospitalized and stops moving
      ]
      [
        set color orange + 2
        set mild_cases mild_cases + 1       ; advancing mild_cases counting variable
        set hours 0
        set human_speed 0.5        ; value assigned to variable to make speed a bit slower than that of other agents
      ]
    ]


    ; converting "days before recovery or death" in days to hours
    ; what should happen if infection has lingered for this period?
    ; applying case fatality probabilty of both type of cases to determine...
    ; ... if an infected human dies or survives
    ; "orange + 2" for mild case, red for severe case
    if (color = orange + 2) and (hours = (Sick_Days * 24)) [
      ifelse random-float 100 < CFR_Mild_Case [
        set color gray
        set fatalities fatalities + 1        ; advancing fatalities counting variable
        set hours 0
        set human_speed 0            ; if dead, human stops moving
      ]
      [
        set color cyan               ; if they survived, they become immune but still carriers (cyan from color coding)
        set hours 0
        set human_speed 0.5
      ]
    ]

    if (color = red) and (hours = (Sick_Days * 24)) [
      ifelse random-float 100 < CFR_Severe_Case [
        set color gray
        set fatalities fatalities + 1
        set hours 0
        set human_speed 0
      ]
      [
        set color cyan
        set hours 0
        set human_speed control_speed
      ]
    ]

    ; what should happen if immune carriers have exceeded the Infectious days after recovery?
    ; mark them as immune and no longer infectious (Lime)
    if (color = cyan) and (hours = (Infectious_Days_After_Recovery * 24)) [
      set color lime + 1       ; lime human is immune and no longer infectious
      set hours 0
      set human_speed control_speed
    ]
  ]

  ; Updating global variables for plotting purposes and for output display on monitor
  set infected_not_infectious count humans with [color = yellow]
  set mild_cases_count count humans with [color = orange + 2]
  set severe_cases_count count humans with [color = red]
  set immune_infectious count humans with [color = cyan]
  set immune_not_infectious count humans with [color = lime + 1]
  set total_immune (immune_infectious + immune_not_infectious)
  set current_cases (mild_cases_count + severe_cases_count)
  set total_mild_cases (mild_cases + initial_mild_cases)
  set total_severe_cases (severe_cases + initial_severe_cases)
  set total_cases (total_mild_cases + total_severe_cases)
  set total_infectious (current_cases + immune_infectious)
  set total_infected (infected_not_infectious + total_infectious + total_fatalities)
  set total_fatalities count humans with [color = gray]
  set average_%CFR (fatalities / total_cases) * 100
  set %infected (total_infected / Human_Population) * 100
  set %uninfected ((count humans with [color = white]) / Human_Population) * 100
  set %immune (total_immune / Human_Population) * 100

  if infected_not_infectious + current_cases + count humans with [color = white] = 0 [stop]   ; condition (if true) to halt simulation
  tick     ; advancing the tick counter by 1
end
@#$#@#$#@
GRAPHICS-WINDOW
258
45
888
676
-1
-1
18.85
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
0
46
216
79
Human_Population
Human_Population
2
1000
500.0
1
1
NIL
HORIZONTAL

SLIDER
0
82
216
115
Multimammate_Rat_Population
Multimammate_Rat_Population
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
0
116
183
149
Initial_Number_Of_Cases
Initial_Number_Of_Cases
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
0
511
251
544
%Infectiousness_Human_to_Human
%Infectiousness_Human_to_Human
0
100
20.0
0.01
1
%
HORIZONTAL

SLIDER
0
475
251
508
%Infectiousness_Rat_to_Human
%Infectiousness_Rat_to_Human
0
100
40.0
0.01
1
%
HORIZONTAL

SLIDER
0
164
218
197
%Severe_Cases
%Severe_Cases
0
100
20.0
1
1
%
HORIZONTAL

SLIDER
0
258
198
291
Incubation_Period
Incubation_Period
6
21
10.0
1
1
Days
HORIZONTAL

SLIDER
0
293
198
326
Sick_Days
Sick_Days
2
21
15.0
1
1
Days
HORIZONTAL

SLIDER
0
389
172
422
CFR_Mild_Case
CFR_Mild_Case
0
100
1.0
1
1
%
HORIZONTAL

SLIDER
0
424
173
457
CFR_Severe_Case
CFR_Severe_Case
0
100
15.0
1
1
%
HORIZONTAL

SLIDER
0
614
236
647
Human_Behaviour_Factor
Human_Behaviour_Factor
0.01
0.99
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
0
328
248
361
Infectious_Days_After_Recovery
Infectious_Days_After_Recovery
0
100
90.0
1
1
Days
HORIZONTAL

BUTTON
895
326
1045
359
Initialize Simulation
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

BUTTON
1048
326
1206
359
Run/Stop Simulation
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

MONITOR
0
200
130
245
%Mild_Cases
%Mild_Cases
2
1
11

MONITOR
897
554
991
599
Future Cases
infected_not_infectious
0
1
11

MONITOR
897
603
1030
648
Immune Carriers
immune_infectious
0
1
11

MONITOR
1256
554
1359
599
Current Cases
current_cases
0
1
11

MONITOR
996
554
1114
599
Current Mild Cases
mild_cases_count
0
1
11

MONITOR
1119
554
1250
599
Current Severe Cases
severe_cases_count
0
1
11

MONITOR
1256
505
1359
550
Total fatalities
total_fatalities
0
1
11

MONITOR
896
378
950
423
Days
ticks / 24
0
1
11

MONITOR
897
440
989
485
% Uninfected
%uninfected
2
1
11

MONITOR
993
440
1068
485
% Infected
%infected
2
1
11

PLOT
895
45
1401
323
Human Population Health Status
Hours
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Uninfected" 1.0 0 -5516827 true "" "plot count humans with [color = white]"
"Infected" 1.0 0 -2674135 true "" "plot total_infected\n"
"Immune" 1.0 0 -10899396 true "" "plot total_immune"
"Fatalities" 1.0 0 -16777216 true "" "plot count humans with [color = gray]"

MONITOR
953
378
1010
423
Weeks
ticks / (24 * 7)
1
1
11

MONITOR
1069
378
1119
423
Years
ticks / (24 * 365)
1
1
11

MONITOR
1255
439
1358
484
Average % CFR
average_%CFR
2
1
11

MONITOR
1036
505
1136
550
Total Mild Cases
total_mild_cases
0
1
11

MONITOR
1072
440
1146
485
% Immune
%immune
2
1
11

TEXTBOX
367
10
799
40
Simulation of Lassa Fever Transmission
22
0.0
1

MONITOR
897
505
1032
550
Total Confirmed Cases
total_cases
0
1
11

MONITOR
1036
603
1226
648
Immune and No longer Infectious
immune_not_infectious
0
1
11

MONITOR
1140
505
1252
550
Total Severe Cases
total_severe_cases
0
1
11

TEXTBOX
0
376
202
404
Case Fatality Rate (CFR) in Percentage
10
0.0
1

TEXTBOX
5
575
258
620
A measure of the degree of Hygiene ( that can mitigate/slow down rodent activiites) and social distancing being practiced
10
0.0
1

MONITOR
1013
378
1066
423
Months
ticks / (24 * 30)
1
1
11

@#$#@#$#@
## WHAT IS IT?

This model simulates Lassa Virus Transmission, an endemic predominantly in the western region of Africa. It is able to estimate the size of imminent attacks at any time based on some input parameters. It also confirms the degree of impact of community hygiene and social distancing on the virus transmission rate over time, and can serve as a research aid tool for epidemiologists or health organisations.

## HOW IT WORKS

Interface includes sets of parameters in the form of sliders which users can use to adjust the inputs based on the requirements of their experiment.

- Initialize Simulation; It is configured as a “once-only” button to setup or initialize the simulation. Clicking this button activates the “setup” command procedure, a block of codes written in the code tab.

- Run/Pause Simulation; This is configured as a “forever” button. Clicking this button activates the “go” command procedure in the code tab which then runs / pauses the simulation.


## HOW TO USE IT

- Human_Population: This slider can be used by a user to select a variable number of human agents to be populated into the world (Graphics window). Since at least two persons are required for a viral transmission to occur, the minimum number for the slider was set to “2”. After selecting the desired number of human agents, clicking the Initialize Simulation button will reset the simulation and reflect the set number of human agents all placed randomly across the world.

- Multimammate_Rat_Population: to select a variable number of infectious rat agents which the user needs to be populated into the world. Clicking the Initialize Simulation button sets up the simulation with the desired number of rats and places them randomly across the world.

- Initial_Number_Of_Cases: For selecting a pre-existing number of cases (infectious human agents) at the beginning of the simulation. Clicking the Initialize Simulation button displays the selected Initial number of cases scattered randomly among all agents within the world.

- %Severe_Cases: This indicates the percentage of the initial number of infected human agents that were severely affected by the virus. Based on the user’s selection, the system computes and populates the exact number of infected humans with severe symptoms in the world.

- Incubation_Period: It represents the length of time in days that it will take for a newly infected human to begin to exhibit some symptoms and become infectious. Users can select a variable number of days depending on what their simulation/ experiment needs.

- Sick_Days: Length of time in days for an infectious human to either recover or die from fighting the virus. This begins to count immediately after the incubation period elapses. Sliding left or right selects a variable number of days which the system uses to perform calculations and actions based on some conditions.

- Infectious_Days_After_Recovery: Length of time in days that the virus lasts in a human agent that survived the viral infection and had become immune. During these days, the human agent is still infectious and hence, still poses a risk (though minimal) of infecting other nearby humans in contact. A variable number of days can be selected as required for simulation.

- CFR_Mild_Case: For selecting or adjusting the Case Fatality Rate (CFR) in percentage for infectious human agents with mild symptoms. The system takes whatever value that was selected as an input argument and calculates the probability of the agent dieing after the Sick Days has elapsed.

- CFR_Severe_Case: For selecting the Case Fatality Rate in percentage for infectious human agents with severe symptoms. Just like the former, the user can adjust or modify the parameter value. The system then computes the Case Fatality Rate to determine if the human agent dies or not.

- %Infectiousness_Rat_to_Humans: This slider can be used to set the probability in percentage, of a rat-to-human transmission for every instance of time when an uninfected human agent gets in contact with rat agent.

- %Infectiousness_Human_to_Human: A user can use this slider to select the probability in percentage, of a human-to-human transmission of the virus for every instance of time that an uninfected human agent gets in contact with an already infectious human agent.

- Human_Behaviour_Factor: A factor which represents the level of hygiene or social distancing being practiced by humans in the world. The least value that can be selected is set at 0.01 and the highest value is set at 0.99. This system uses this value to adjust the speed of both agent sets in slightly different ways. The higher the value, the higher the degree of hygiene practice (and vice versa) which will mitigate the activities of the disease carrying rats in the world. This behavior is represented in the model by slowing down the speed (activities) of the rat agents, as well as improving social distancing for the human agents. The speed of both agent sets gets slower as the value gets higher.


## THINGS TO NOTICE

The color changes helps to monitor the transition from one health status to the other, of the human agents.

- White Human: Healthy, not infected.
- Yellow Human: future case
- Orange Human: Mild case.
- Red Human: Severe case.
- Cyan Human: Immune carriers
- Lime Human: Fully recovered and immune
- Gray Human: Dead human
- Rats in red



## THINGS TO TRY

You can adjust the Human_Behaviour_Factor slider to see how the level of comminity hygiene / social distance being practiced affects the Lassa virus transmission

you can also adjust the human / rat population to analyze the effect of population density on the Lassa virus transmission.

## EXTENDING THE MODEL

Some logical assumptions had to be made in the design/coding of the model. For instance, a fixed population size (0% growth rate) was assumed for both agent sets. A lower spread chance was assumed for humans with severe symptoms and that they must have been hospitalized with restricted movement / visits.
Seasonal drivers of the transmission of LASV, among other scenarios, were not considered in the design. These are some of the limitations of the model hence the simulation outcomes are to serve as a guide for research purposes and not to be entirely relied upon for predicting future occurrences.

As research on LF gets more extensive, the scope of the model design could be expanded to include other real-world scenarios that can be used to build a more sophisticated model with increased precision in simulation.


## RELATED MODELS

the “HIV” and “Virus” models in Netlogo's model library

## CREDITS AND REFERENCES

1. André Calero Valdez (@sumidu) web calerovaldez.com

2. Wilensky, U. (1998). NetLogo Virus model. http://ccl.northwestern.edu/netlogo/models/Virus. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
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

mouse side
false
0
Polygon -7500403 true true 38 162 24 165 19 174 22 192 47 213 90 225 135 230 161 240 178 262 150 246 117 238 73 232 36 220 11 196 7 171 15 153 37 146 46 145
Polygon -7500403 true true 289 142 271 165 237 164 217 185 235 192 254 192 259 199 245 200 248 203 226 199 200 194 155 195 122 185 84 187 91 195 82 192 83 201 72 190 67 199 62 185 46 183 36 165 40 134 57 115 74 106 60 109 90 97 112 94 92 93 130 86 154 88 134 81 183 90 197 94 183 86 212 95 211 88 224 83 235 88 248 97 246 90 257 107 255 97 270 120
Polygon -16777216 true false 234 100 220 96 210 100 214 111 228 116 239 115
Circle -16777216 true false 246 117 20
Line -7500403 true 270 153 282 174
Line -7500403 true 272 153 255 173
Line -7500403 true 269 156 268 177

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
NetLogo 6.3.0
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
