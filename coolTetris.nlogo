globals[
  piece-spawn
  bound
  drop?
  move-left?
  move-right?
  rotr?
  rotl?
  game-over?
  next-spawn
  next
  piece
  rot
  goal
  level
  game-over-spawn
  score
  full-drop?
  piece-score-max
  piece-score-min
  lines-cleared
  chances
]

breed [ shadows ]
breed [ pieces ]
breed [ blocks ]
breed [ nexts ]
breed [ from-here ]


pieces-own[
  pos
]

blocks-own[
  up?
  down?
  left?
  right?
  drop-amount
  remove?
]

shadows-own[
  pos
]

to startup
  setup
end

to setup
  clear-all
  create-shadows 4[
    set shape "square"
    set color grey - 3
    set pos who + 1
  ]
  set rot 1
  set chances [75 50 50 100 100 100 100]
  set full-drop? false
  set goal 10
  set next-spawn patch (max-pxcor - 5) ( max-pycor - 2)
  set game-over? false
  set game-over-spawn patch ((bound + min-pxcor)/ 2) 0
  set drop? false
  set move-left? false
  set move-right? false
  set rotr? false
  set rotl? false
  set bound max-pxcor - 6
  set piece-spawn patch((bound + min-pxcor)/ 2 - 2) (max-pycor - 2)
  ask patches with[pycor > max-pycor - 2][set pcolor grey]
  ask patches with[pxcor >= bound][
    set pcolor grey
    if pxcor > bound and pxcor < max-pxcor and pycor < max-pycor and pycor >= max-pycor - 4[
      set pcolor black
    ]
  ]
  ifelse tetris-type = "tetris"[
    set piece random 7
    set next random 7
  ][ifelse tetris-type = "easy tetris"[
    set-piece-score
    set piece piece-ranked 0 piece-score-min
    set next piece-ranked 0 piece-score-min
  ][
    set-piece-score
    set piece piece-ranked chances piece-score-min
    ifelse tetris-type = "hard tetris"[
      set next piece-ranked chances piece-score-min
    ][
      set next piece-ranked 0 piece-score-min
    ]
  ]]
;  set-piece-score
;  set piece piece-ranked 6
  spawn-piece piece piece-spawn false false
;  set next piece-ranked 6
  spawn-piece next next-spawn true false
  set-shadow
  display
  reset-ticks
end

to set-shadow
  ask shadows [setxy [xcor] of one-of pieces with [pos = [pos] of myself]
                     [ycor] of one-of pieces with [pos = [pos] of myself]
               ;set shape shape-of one-of pieces with [pos = pos-of myself]
               ;set heading heading-of one-of pieces with [pos = pos-of myself]
               set color ([color] of one-of pieces) - 3]
  let clear? true
  ask shadows [if any? blocks-at 0 -1 or ycor = min-pycor[set clear? false]]
  while [clear?][ask shadows [set ycor ycor - 1]
                 ask shadows [if any? blocks-at 0 -1 or ycor = min-pycor[set clear? false]]]
  ;display
end

to go

  if game-over? [
;    let unit 2 ^ .5
;    let -unit (- unit)
;    ask game-over-spawn [
;    make-piece 0 0 -45 "x" true 0 red false
;    make-piece unit / 2 unit / 2 180 - 45 "bend" true 0 red false
;    make-piece unit 0 -45 "end" true 0 red false
;    make-piece unit / 2 -unit / 2 -90 - 45 "bend" true 0 red false
;    make-piece 0 -unit 90 - 45 "end" true 0 red false
;    make-piece -unit / 2 -unit / 2 -45 "bend" true 0 red false
;    make-piece -unit 0 180 - 45 "end" true 0 red false
;    make-piece (-unit / 2) (unit / 2) 90 - 45 "bend" true 0 red false
;    make-piece 0 unit -90 - 45 "end" true 0 red false]
;    display
  stop]
  every 1 / (level * 1.1 + 1) [drop]
  if drop? [drop set drop? false]
  if move-left? [move-left set move-left? false]
  if move-right? [move-right set move-right? false]
  if rotl? [rotl set rotl? false]
  if rotr? [rotr set rotr? false]
  if full-drop? [full-drop set full-drop? false]
  display
end

to rotl
  set-rot rot - 1
  set-shadow
end

to-report piece-ranked [arank alist]
  let mscore alist
  ;let nscore sort mscore
  let n 0
  ifelse is-list? arank[
    let point 0
    let go-on? true
    while [go-on?][
      ifelse item point arank > random 100 [
        set go-on? false
      ][
        set point point + 1
      ]
    ]
    set n item point reverse sort mscore
  ][
    set n item arank sort mscore
  ]
  ;print n
  let winners []
  let p 0
  while[p < length mscore][
    if item p mscore = n[set winners lput p winners]
    set p p + 1
  ]
  report one-of winners
end

to-report
  count-hight
  let mxcor min-pxcor
  let hight 0
  let lines count-lines
  while[mxcor < bound][
    let chight 0
    if any? turtles with [xcor = mxcor and breed != pieces][
      set chight max [ycor + max-pycor + 1] of turtles with [xcor = mxcor and breed != pieces]
    ]
    set hight hight + chight - lines
    set mxcor mxcor + 1
  ]
  report hight
end

to rotr
  set-rot rot + 1
  set-shadow
end

to set-rot [arot]
  let clear? true
  ifelse piece = 0[
    set arot ((arot - 1) mod 2) + 1
    ifelse arot = 1[
      ask pieces with [pos = 3][
        if any? blocks-at 1 0 or any? blocks-at -2 0 or any? blocks-at -1 0 or xcor < min-pxcor + 2 or xcor >= bound - 1
        [
          set clear? false
        ]
      ]
      if clear? [
        set rot 1
        let mx [xcor] of one-of pieces with [pos = 3]
        let my [ycor] of one-of pieces with [pos = 3]
        ask pieces with [pos = 1][setxy mx - 2 my
                                  set heading 90]
        ask pieces with [pos = 2][setxy mx - 1 my
                                  set heading 90]
        ask pieces with [pos = 3][set heading 90]
        ask pieces with [pos = 4][setxy mx + 1 my
                                  set heading 270]
      ]
    ][
      ask pieces with [pos = 3][
        if any? blocks-at 0 1 or any? blocks-at 0 2 or any? blocks-at 0 -1 or ycor > max-pycor - 2 or ycor = min-pycor[
          set clear? false
        ]
      ]
      if clear? [
        set rot 2
        let mx [xcor] of one-of pieces with [pos = 3]
        let my [ycor] of one-of pieces with [pos = 3]
        ask pieces with [pos = 1][setxy mx my + 2
                                  set heading 180]
        ask pieces with [pos = 2][setxy mx my + 1
                                  set heading 0]
        ask pieces with [pos = 3][set heading 0]
        ask pieces with [pos = 4][setxy mx my - 1
                                  set heading 0]
      ]
    ]

  ;;;;;;;;;;;;;;;;;;;;;;;;
  ;; MIDDLE FINGER PIECE;;
  ;;;;;;;;;;;;;;;;;;;;;;;;

  ][ifelse piece = 1[
    set arot ((arot - 1) mod 4) + 1
    ifelse arot = 1 [
      ask pieces with [pos = 2] [
        if any? blocks-at -1 0 or any? blocks-at 1 0 or any? blocks-at 0 -1 or ycor = min-pycor or xcor = min-pxcor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 1
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx - 1 my
                                  set heading 90]
        ask pieces with [pos = 2][set heading 180]
        ask pieces with [pos = 3][setxy mx my - 1
                                  set heading 0]
        ask pieces with [pos = 4][setxy mx + 1 my
                                  set heading 270]
      ]
    ][ifelse arot = 2 [
      ask pieces with [pos = 2] [
        if any? blocks-at -1 0 or any? blocks-at 0 1 or any? blocks-at 0 -1 or ycor = max-pycor or xcor = min-pxcor or ycor = max-pycor[
          set clear? false
        ]
      ]
      if clear?[
        set rot 2
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx my + 1
                                  set heading 180]
        ask pieces with [pos = 2][set heading 270]
        ask pieces with [pos = 3][setxy mx - 1 my
                                  set heading 90]
        ask pieces with [pos = 4][setxy mx my - 1
                                  set heading 0]
      ]
    ][ifelse arot = 3 [
      ask pieces with [pos = 2] [
        if any? blocks-at -1 0 or any? blocks-at 0 1 or any? blocks-at 1 0 or ycor = max-pycor or xcor = min-pxcor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 3
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx + 1 my
                                  set heading 270]
        ask pieces with [pos = 2][set heading 0]
        ask pieces with [pos = 3][setxy mx my + 1
                                  set heading 180]
        ask pieces with [pos = 4][setxy mx - 1 my
                                  set heading 90]
      ]
    ][ask pieces with [pos = 2] [
        if any? blocks-at 1 0 or any? blocks-at 0 1 or any? blocks-at 0 -1 or ycor = max-pycor or ycor = min-pycor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 4
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx my - 1
                                  set heading 0]
        ask pieces with [pos = 2][set heading 90]
        ask pieces with [pos = 3][setxy mx + 1 my
                                  set heading 270]
        ask pieces with [pos = 4][setxy mx my + 1
                                  set heading 180]
      ]
    ]]]
  ;;;;;;;;;;;;;;;;;;;;
  ;;ASS BLOCK;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;

  ][ifelse piece = 2 [
  ;;;;;;;;;;;;;;;;;;;;;
  ;;L PIECE;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;
  ][ifelse piece = 3[
    set arot ((arot - 1) mod 4) + 1
    ifelse arot = 1 [
      ask pieces with [pos = 3] [
        if any? blocks-at -1 0 or any? blocks-at 1 0 or any? blocks-at -1 -1 or ycor = min-pycor or xcor = min-pxcor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 1
        let mx [xcor] of one-of pieces with [pos = 3]
        let my [ycor] of one-of pieces with [pos = 3]
        ask pieces with [pos = 1][setxy mx - 1 my
                                  set heading 90]
        ask pieces with [pos = 2][setxy mx - 1 my - 1
                                  set heading 0]
        ask pieces with [pos = 3][set heading 90]
        ask pieces with [pos = 4][setxy mx + 1 my
                                  set heading 270]
      ]
    ][ifelse arot = 2 [
      ask pieces with [pos = 3] [
        if any? blocks-at -1 1 or any? blocks-at 0 1 or any? blocks-at 0 -1 or ycor = max-pycor or xcor = min-pxcor or ycor = max-pycor[
          set clear? false
        ]
      ]
      if clear?[
        set rot 2
        let mx [xcor] of one-of pieces with [pos = 3]
        let my [ycor] of one-of pieces with [pos = 3]
        ask pieces with [pos = 1][setxy mx my + 1
                                  set heading 180]
        ask pieces with [pos = 2][setxy mx - 1 my + 1
                                  set heading 90]
        ask pieces with [pos = 3][set heading 0]
        ask pieces with [pos = 4][setxy mx my - 1
                                  set heading 0]
      ]
    ][ifelse arot = 3 [
      ask pieces with [pos = 3] [
        if any? blocks-at -1 0 or any? blocks-at 1 1 or any? blocks-at 1 0 or ycor = max-pycor or xcor = min-pxcor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 3
        let mx [xcor] of one-of pieces with [pos = 3]
        let my [ycor] of one-of pieces with [pos = 3]
        ask pieces with [pos = 1][setxy mx + 1 my
                                  set heading 270]
        ask pieces with [pos = 2][setxy mx + 1 my + 1
                                  set heading 180]
        ask pieces with [pos = 3][set heading 90]
        ask pieces with [pos = 4][setxy mx - 1 my
                                  set heading 90]
      ]
    ][ask pieces with [pos = 3] [
        if any? blocks-at 1 -1 or any? blocks-at 0 1 or any? blocks-at 0 -1 or ycor = max-pycor or ycor = min-pycor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 4
        let mx [xcor] of one-of pieces with [pos = 3]
        let my [ycor] of one-of pieces with [pos = 3]
        ask pieces with [pos = 1][setxy mx my - 1
                                  set heading 0]
        ask pieces with [pos = 2][setxy mx + 1 my - 1
                                  set heading 270]
        ask pieces with [pos = 3][set heading 0]
        ask pieces with [pos = 4][setxy mx my + 1
                                  set heading 180]
      ]
    ]]]
  ;;;;;;;;;;;;;;;;;
  ;; the reverse L;
  ;;;;;;;;;;;;;;;;;
  ][ifelse piece = 4[
    set arot ((arot - 1) mod 4) + 1
    ifelse arot = 1 [
      ask pieces with [pos = 2] [
        if any? blocks-at -1 0 or any? blocks-at 1 0 or any? blocks-at 1 -1 or ycor = min-pycor or xcor = min-pxcor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 1
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx - 1 my
                                  set heading 90]
        ask pieces with [pos = 2][set heading 90]
        ask pieces with [pos = 3][setxy mx + 1 my
                                  set heading 180]
        ask pieces with [pos = 4][setxy mx + 1 my - 1
                                  set heading 0]
      ]
    ][ifelse arot = 2 [
      ask pieces with [pos = 2] [
        if any? blocks-at -1 -1 or any? blocks-at 0 1 or any? blocks-at 0 -1 or ycor = max-pycor or xcor = min-pxcor or ycor = max-pycor[
          set clear? false
        ]
      ]
      if clear?[
        set rot 2
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx my + 1
                                  set heading 180]
        ask pieces with [pos = 2][set heading 0]
        ask pieces with [pos = 3][setxy mx my - 1
                                  set heading -90]
        ask pieces with [pos = 4][setxy mx - 1 my - 1
                                  set heading 90]
      ]
    ][ifelse arot = 3 [
      ask pieces with [pos = 2] [
        if any? blocks-at -1 0 or any? blocks-at -1 1 or any? blocks-at 1 0 or ycor = max-pycor or xcor = min-pxcor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 3
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx + 1 my
                                  set heading 270]
        ask pieces with [pos = 2][set heading 90]
        ask pieces with [pos = 3][setxy mx - 1 my
                                  set heading 0]
        ask pieces with [pos = 4][setxy mx - 1 my + 1
                                  set heading 180]
      ]
    ][ask pieces with [pos = 2] [
        if any? blocks-at 1 1 or any? blocks-at 0 1 or any? blocks-at 0 -1 or ycor = max-pycor or ycor = min-pycor or xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear?[
        set rot 4
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx my - 1
                                  set heading 0]
        ask pieces with [pos = 2][set heading 0]
        ask pieces with [pos = 3][setxy mx my + 1
                                  set heading 90]
        ask pieces with [pos = 4][setxy mx + 1 my + 1
                                  set heading 270]
      ]
    ]]]
  ;;;;;;;;;;;;;;;
  ;;Z piece;;;;;;
  ;;;;;;;;;;;;;;;
  ][ifelse piece = 5[
    set arot ((arot - 1) mod 2) + 1
    ifelse arot = 1[
      ask pieces with [pos = 2][
        if any? blocks-at -1 0 or any? blocks-at 1 -1 or any? blocks-at 0 -1 or  xcor = bound - 1[
          set clear? false
        ]
      ]
      if clear? [
        set rot 1
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx - 1 my
                                  set heading 90]
        ask pieces with [pos = 2][set heading 180]
        ask pieces with [pos = 3][setxy mx my - 1
                                  set heading 0]
        ask pieces with [pos = 4][setxy mx + 1 my - 1
                                  set heading 270]
      ]
    ][
      ask pieces with [pos = 2][
        if any? blocks-at -1 0 or any? blocks-at -1 -1 or any? blocks-at 0 1 or ycor = max-pycor[
          set clear? false
        ]
      ]
      if clear? [
        set rot 2
        let mx [xcor] of one-of pieces with [pos = 2]
        let my [ycor] of one-of pieces with [pos = 2]
        ask pieces with [pos = 1][setxy mx my + 1
                                  set heading 180]
        ask pieces with [pos = 2][set heading -90]
        ask pieces with [pos = 3][setxy mx - 1 my
                                  set heading 90]
        ask pieces with [pos = 4][setxy mx - 1 my - 1
                                  set heading 0]
      ]
    ]
  ][
    set arot ((arot - 1) mod 2) + 1
    ifelse arot = 1[
      ask pieces with [pos = 3][
        if any? blocks-at -1 -1 or any? blocks-at 0 -1 or any? blocks-at 1 0 or  xcor = min-pxcor[
          set clear? false
        ]
      ]
      if clear? [
        set rot 1
        let mx [xcor] of one-of pieces with [pos = 3]
        let my [ycor] of one-of pieces with [pos = 3]
        ask pieces with [pos = 1][setxy mx - 1 my - 1
                                  set heading 90]
        ask pieces with [pos = 2][setxy mx my - 1
                                  set heading -90]
        ask pieces with [pos = 3][set heading 90]
        ask pieces with [pos = 4][setxy mx + 1 my
                                  set heading 270]
      ]
    ][
      ask pieces with [pos = 3][
        if any? blocks-at 1 0 or any? blocks-at 1 -1 or any? blocks-at 0 1 or ycor = max-pycor[
          set clear? false
        ]
      ]
      if clear? [
        set rot 2
        let mx [xcor] of one-of pieces with [pos = 3]
        let my [ycor] of one-of pieces with [pos = 3]
        ask pieces with [pos = 1][setxy mx + 1 my - 1
                                  set heading 0]
        ask pieces with [pos = 2][setxy mx + 1 my
                                  set heading 180]
        ask pieces with [pos = 3][set heading 0]
        ask pieces with [pos = 4][setxy mx my + 1
                                  set heading 180]
      ]
    ]
  ]]]]]]
end

to move-left
  let clear? true
  ask pieces[
    if any? blocks-at -1 0 or xcor = min-pxcor[
      set clear? false
    ]
  ]
  if clear? [
    ask pieces[set xcor xcor - 1]
    set-shadow
  ]
end

to move-right
  let clear? true
  ask pieces[
    if any? blocks-at 1 0 or xcor = bound - 1[
      set clear? false
    ]
  ]
  if clear? [
    ask pieces[set xcor xcor + 1]
    set-shadow
  ]
end

to drop
  let clear? true
  ask pieces[
    if any? blocks-at 0 -1 or ycor = min-pycor[
      set clear? false
    ]
  ]
  ifelse clear? [ask pieces[set ycor ycor - 1]][
    ask pieces [
      let cshape shape
      set breed blocks
      set remove? false
      set shape cshape
      set color grey + 2
      hatch-from-here 1 [
        hide-turtle
      ]
      set drop-amount 0
      set-open-ends
    ]
    check-lines
    ask nexts [die]
    if tetris-type != "tetris" [set-piece-score]
    ifelse tetris-type != "evil tetris" [set piece next][
      set piece piece-ranked chances piece-score-min
    ]
    set rot 1
    spawn-piece piece piece-spawn false false
    ifelse tetris-type = "tetris"[
      set next random 7
    ][ifelse tetris-type = "easy tetris"[
      set next piece-ranked 0 piece-score-min
    ][ifelse tetris-type = "hard tetris"[
      set next piece-ranked chances piece-score-min
    ][
      set next piece-ranked 0 piece-score-min
    ]]]
    spawn-piece next next-spawn true false
    ask pieces [if any? blocks-here [set game-over? true]]
  ]
end

to check-lines
  let spaces world-width - 7
  let line min-pycor
  let lines 0
  while [line <= max-pycor][
    if count blocks with [ycor = line] = spaces [
      ask blocks with [ycor = line] [set remove? true]
      ask blocks with [ycor > line] [set drop-amount drop-amount + 1]
      ask blocks with [ycor = line + 1] [set down? false set-shape]
      ask blocks with [ycor = line - 1] [set up? false set-shape]
      set lines lines + 1
      set lines-cleared lines-cleared + 1
    ]
    set line line + 1
  ]
  ask shadows [hide-turtle]
  display
  let black-range 0
  while [any? blocks with [remove?]][
    ask blocks with [remove? and black-range >= distance one-of((from-here with[ycor = [ycor] of myself]) with-min [distance myself])]
    [
      set color color - .5
    ]
    ask blocks with [remove? and color <= .3] [die]
    set black-range black-range + .7

  ]
  while[any? blocks with[drop-amount > 0]][
    ask blocks with [drop-amount > 0][
      set ycor ycor - .1
      set drop-amount drop-amount - .1
    ]
  ]
  ask blocks [set ycor round ycor]

  ask from-here [die]
  ask shadows [show-turtle]
  set goal goal - lines
  if goal <= 0 [
    let take-away goal
    set level level + 1
    set goal 10 + (5 * level) + take-away
  ]
  if lines = 1 [set lines 40]
  if lines = 2 [set lines 100]
  if lines = 3 [set lines 300]
  if lines = 4 [set lines 400]
  set score score + (level + 1)* lines
end

to-report count-lines
  let spaces world-width - 7
  let line min-pycor
  let lines 0
  while [line <= max-pycor][
    if (count blocks with [ycor = line])+(count shadows with [ycor = line]) = spaces [
      set lines lines + 1
    ]
    set line line + 1
  ]
  report lines
end

to set-open-ends
    set up? false
    set down? false
    set right? false
    set left? false
  ifelse shape = "o" [
  ][ifelse shape = "end"[
    ifelse heading = 0 [
      set up? true
    ][ifelse heading = 90[
      set right? true
    ][ifelse heading = 180[
      set down? true
    ][
      set left? true
    ]]]
  ][ifelse shape = "mid"[
    ifelse heading = 0 or heading = 180 [
      set up? true
      set down? true
    ][
      set left? true
      set right? true
    ]
  ][ifelse shape = "bend"[
    ifelse heading = 0 [
      set up? true
      set right? true
    ][ifelse heading = 90[
      set right? true
      set down? true
    ][ifelse heading = 180[
      set down? true
      set left? true
    ][
      set left? true
      set up? true
    ]]]
  ][ifelse shape = "t"[
    set up? true
    set down? true
    set right? true
    set left? true
    ifelse heading = 0 [
      set down? false
    ][ifelse heading = 90[
      set left? false
    ][ifelse heading = 180[
      set up? false
    ][
      set right? false
    ]]]
  ][
    set up? true
    set down? true
    set right? true
    set left? true
  ]]]]]
end

to set-shape
  let num-open 0
  if up? [set num-open 1]
  if right? [set num-open num-open + 1]
  if down? [set num-open num-open + 1]
  if left? [set num-open num-open + 1]
  ifelse num-open = 0 [
    set shape "o"
  ][ifelse num-open = 1[
    set shape "end"
    ifelse up? [set heading 0][
    ifelse right? [set heading 90][
    ifelse down? [set heading 180][
    set heading 270]]]
  ][ifelse num-open = 2[
    ifelse up?[
      ifelse right? [
        set shape "bend"
        set heading 0
      ][ifelse left? [
        set shape "bend"
        set heading 270
      ][
        set shape "mid"
        set heading 0
      ]]
    ][ifelse down?[
      ifelse right? [
        set shape "bend"
        set heading 90
      ][
        set shape "bend"
        set heading 180
      ]
    ][
      set shape "mid"
      set heading 90
    ]]
  ][ifelse num-open = 3 [
    set shape "t"
    ifelse not up?[set heading 180][
    ifelse not right?[set heading 270][
    ifelse not down?[set heading 0][
    set heading 90]]]
  ][
    set shape "x"
    set heading 0
  ]]]]
end

to spawn-piece [apiece aspawn atype? ahide?]
  ifelse apiece = 0[
    ask aspawn [
      make-piece 0 0 90 "end" atype? 1 red ahide?
      make-piece 1 0 90 "mid" atype? 2 red ahide?
      make-piece 2 0 90 "mid" atype? 3 red ahide?
      make-piece 3 0 -90 "end" atype? 4 red ahide?
    ]
  ][ifelse apiece = 1[
    ask aspawn [
      make-piece 1 0 90 "end" atype? 1 yellow ahide?
      make-piece 2 0 180 "t" atype? 2 yellow ahide?
      make-piece 2 -1 0 "end" atype? 3 yellow ahide?
      make-piece 3 0 270 "end" atype? 4 yellow ahide?
    ]
  ][ifelse apiece = 2[
    ask aspawn[
      make-piece 1 0 90 "bend" atype? 1 blue ahide?
      make-piece 1 -1 0 "bend" atype? 2 blue ahide?
      make-piece 2 0 180 "bend" atype? 3 blue ahide?
      make-piece 2 -1 270 "bend" atype? 4 blue ahide?
    ]
  ][ifelse apiece = 3[
    ask aspawn[
      make-piece 1 0 90 "bend" atype? 1 violet ahide?
      make-piece 1 -1 0 "end" atype? 2 violet ahide?
      make-piece 2 0 90 "mid" atype? 3 violet ahide?
      make-piece 3 0 270 "end" atype? 4 violet ahide?
    ]
  ][ifelse apiece = 4[
    ask aspawn[
      make-piece 1 0 90 "end" atype? 1 orange ahide?
      make-piece 2 0 90 "mid" atype? 2 orange ahide?
      make-piece 3 0 180 "bend" atype? 3 orange ahide?
      make-piece 3 -1 0 "end" atype? 4 orange ahide?
    ]
  ][ifelse apiece = 5[
    ask aspawn[
      make-piece 1 0 90 "end" atype? 1 cyan ahide?
      make-piece 2 0 180 "bend" atype? 2 cyan ahide?
      make-piece 2 -1 0 "bend" atype? 3 cyan ahide?
      make-piece 3 -1 270 "end" atype? 4 cyan ahide?
    ]
  ][
    ask aspawn[
      make-piece 1 -1 90 "end" atype? 1 green ahide?
      make-piece 2 -1 270 "bend" atype? 2 green ahide?
      make-piece 2 0 90 "bend" atype? 3 green ahide?
      make-piece 3 0 270 "end" atype? 4 green ahide?
    ]
  ]]]]]]
  set rot 1
  if not atype? [set-shadow]
end

;to show-next [apiece]
;  ifelse apiece = 0[
;    ask next-spawn [
;      make-piece 0 0 90 "end" true 1 red
;      make-piece 1 0 90 "mid" true 2 red
;      make-piece 2 0 90 "mid" true 3 red
;      make-piece 3 0 -90 "end" true 4 red
;    ]
;  ][ifelse apiece = 1[
;    ask next-spawn [
;      make-piece 1 0 90 "end" true 1 yellow
;      make-piece 2 0 180 "t" true 2 yellow
;      make-piece 2 -1 0 "end" true 3 yellow
;      make-piece 3 0 270 "end" true 4 yellow
;    ]
;  ][ifelse apiece = 2[
;    ask next-spawn[
;      make-piece 1 0 90 "bend" true 1 blue
;      make-piece 1 -1 0 "bend" true 2 blue
;      make-piece 2 0 180 "bend" true 3 blue
;      make-piece 2 -1 270 "bend" true 4 blue
;    ]
;  ][ifelse apiece = 3[
;    ask next-spawn[
;      make-piece 1 0 90 "bend" true 1 violet
;      make-piece 1 -1 0 "end" true 2 violet
;      make-piece 2 0 90 "mid" true 3 violet
;      make-piece 3 0 270 "end" true 4 violet
;    ]
;  ][ifelse apiece = 4[
;    ask next-spawn[
;      make-piece 1 0 90 "end" true 1 orange
;      make-piece 2 0 90 "mid" true 2 orange
;      make-piece 3 0 180 "bend" true 3 orange
;      make-piece 3 -1 0 "end" true 4 orange
;    ]
;  ][ifelse apiece = 5[
;    ask next-spawn[
;      make-piece 1 0 90 "end" true 1 cyan
;      make-piece 2 0 180 "bend" true 2 cyan
;      make-piece 2 -1 0 "bend" true 3 cyan
;      make-piece 3 -1 270 "end" true 4 cyan
;    ]
;  ][
;    ask next-spawn[
;      make-piece 1 -1 90 "end" true 1 green
;      make-piece 2 -1 270 "bend" true 2 green
;      make-piece 2 0 90 "bend" true 3 green
;      make-piece 3 0 270 "end" true 4 green
;    ]
;  ]]]]]]
;end

;to show-next [apiece]
;  ifelse apiece = 0[
;    ask next-spawn [
;      make-piece 0 0 180 "end" true 0 red
;      make-piece 0 -1 0 "mid" true 0 red
;      make-piece 0 -2 0 "mid" true 0 red
;      make-piece 0 -3 0 "end" true 0 red
;    ]
;  ][ifelse apiece = 1[
;    ask next-spawn [
;      make-piece 0 -1 180 "end" true 0 yellow
;      make-piece 0 -2 90 "t" true 0 yellow
;      make-piece 1 -2 270 "end" true 0 yellow
;      make-piece 0 -3 0 "end" true 0 yellow
;    ]
;  ][ifelse apiece = 2[
;    ask next-spawn[
;      make-piece 0 -3 0 "bend" true 0 blue
;      make-piece 0 -2 90 "bend" true 0 blue
;      make-piece 1 -2 180 "bend" true 0 blue
;      make-piece 1 -3 270 "bend" true 0 blue
;    ]
;  ][ifelse apiece = 3[
;    ask next-spawn[
;      make-piece 0 -1 180 "end" true 0 violet
;      make-piece 0 -2 0 "mid" true 0 violet
;      make-piece 0 -3 0 "bend" true 0 violet
;      make-piece 1 -3 270 "end" true 0 violet
;    ]
;  ][ifelse apiece = 4[
;    ask next-spawn[
;      make-piece 1 -1 180 "end" true 0 orange
;      make-piece 1 -2 0 "mid" true 0 orange
;      make-piece 1 -3 270 "bend" true 0 orange
;      make-piece 0 -3 90 "end" true 0 orange
;    ]
;  ][ifelse apiece = 5[
;    ask next-spawn[
;      make-piece 1 -1 180 "end" true 0 cyan
;      make-piece 1 -2 270 "bend" true 0 cyan
;      make-piece 0 -2 90 "bend" true 0 cyan
;      make-piece 0 -3 0 "end" true 0 cyan
;    ]
;  ][
;    ask next-spawn[
;      make-piece 0 -1 180 "end" true 0 green
;      make-piece 0 -2 0 "bend" true 0 green
;      make-piece 1 -2 180 "bend" true 0 green
;      make-piece 1 -3 0 "end" true 0 green
;    ]
;  ]]]]]]
;end

to make-piece [ax ay aheading ashape abreed apos acolor ahide?]
  sprout 1 [
    if ahide? [set hidden? true]
    set xcor xcor + ax
    set ycor ycor + ay
    set heading aheading
    set color acolor
   ; set size 1
    ifelse abreed [
      set breed nexts
    ][
      set breed pieces
      set pos apos
    ]
    set shape ashape
  ]
end

to full-drop
  let clear? true
  ask pieces [if ycor = min-pycor or any? blocks-at 0 -1 [set clear? false]]
  while [clear?] [drop ask pieces [if ycor = min-pycor or any? blocks-at 0 -1 [set clear? false]]]
  drop
end

to set-piece-score
  set piece 0
  set piece-score-max []
  set piece-score-min []
  let mrot 0
  while [piece <= 6][
    ifelse piece = 0 or piece = 5 or piece = 6[set mrot 2][
    ifelse piece = 1 or piece = 3 or piece = 4[set mrot 4][
    set mrot 1]]
    let crot 1
    let min-hight count patches with [pycor < max-pycor - 2 and pxcor < bound]
    let max-hight 0
    while [crot <= mrot][
       ask pieces [die]
       spawn-piece piece piece-spawn false true
       set-rot crot
       set-shadow
       let clear? true
       ask pieces [if any? blocks-at -1 0 or xcor = min-pxcor[set clear? false]]
       while[clear?][
         ask pieces [set xcor xcor - 1]
         ask pieces [if any? blocks-at -1 0 or xcor = min-pxcor[set clear? false]]
       ]
       set-shadow
       let temp count-hight
       if temp < min-hight[set min-hight temp]
       if temp > max-hight[set max-hight temp]
       set clear? true
       ask pieces [if any? blocks-at 1 0 or xcor = bound - 1[set clear? false]]
       while[clear?][
         ask pieces [set xcor xcor + 1]
         set-shadow
         set temp count-hight
         if temp < min-hight[set min-hight temp]
         if temp > max-hight[set max-hight temp]
         ask pieces [if any? blocks-at 1 0 or xcor = bound - 1[set clear? false]]
       ]
       set crot crot + 1
       ask pieces [die]
;      spawn-piece piece piece-spawn false false
;      set-rot crot
;      set-shadow
;      set max-lines count-lines
;      let clear? true
;      ask pieces [if any? blocks-at 1 0 or xcor = bound - 1 [set clear? false]]
;      while [clear?][
;        ask pieces [set xcor xcor + 1]
;        set-shadow
;        if count-lines > max-lines[set max-lines count-lines]
;        ask pieces [if any? blocks-at 1 0 or xcor = bound - 1 [set clear? false]]
;        if piece = 4 and rot = 2 [without-interruption [ask pieces[ type xcor type " "]]]
;        print " "
;      ]
;      ask pieces [die]
;      spawn-piece piece piece-spawn false false
;      display
;      set-rot crot
;      set clear? true
;      ask pieces [if any? blocks-at -1 0 or xcor = (- screen-edge-x) [set clear? false]]
;      while [clear?][
;        ask pieces [set xcor xcor - 1]
;        display
;        if count-lines > max-lines[set max-lines count-lines]
;        ask pieces [if any? blocks-at -1 0 or xcor = (- screen-edge-x) [set clear? false]]
;      ]
;      ask pieces [die]
;      set crot crot + 1
    ]
    set piece-score-max lput max-hight piece-score-max
    set piece-score-min lput min-hight piece-score-min
    set piece piece + 1
  ]
  ask pieces [die]
  ;display
end
@#$#@#$#@
GRAPHICS-WINDOW
216
10
566
421
8
9
20.0
1
10
1
1
1
0
1
1
1
-8
8
-9
9
0
0
1
ticks
30.0

BUTTON
19
64
82
97
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

BUTTON
82
64
145
97
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
119
116
207
149
clockwise
set rotr? true
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
19
116
119
149
c-clockwise
set rotl? true
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
29
182
92
215
drop
set drop? true
NIL
1
T
OBSERVER
NIL
K
NIL
NIL
1

BUTTON
42
149
105
182
left
set move-left? true
NIL
1
T
OBSERVER
NIL
J
NIL
NIL
1

BUTTON
105
149
168
182
right
set move-right? true
NIL
1
T
OBSERVER
NIL
L
NIL
NIL
1

MONITOR
573
10
630
55
NIL
score
3
1
11

MONITOR
573
157
630
202
NIL
level
3
1
11

MONITOR
573
108
630
153
NIL
goal
3
1
11

BUTTON
92
182
170
215
full-drop
set full-drop? true
NIL
1
T
OBSERVER
NIL
I
NIL
NIL
1

CHOOSER
18
10
156
55
tetris-type
tetris-type
"easy tetris" "tetris" "hard tetris" "evil tetris"
3

MONITOR
573
59
630
104
lines
lines-cleared
3
1
11

TEXTBOX
24
101
174
119
^^ Press setup first
11
0.0
1

TEXTBOX
33
229
183
285
How to play:\nChoose tetris type, then presss setup. Then click go and play using keyboard keys.
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

Classic Tetris with some fun variations!

## HOW TO USE IT

Choose Tetris type, click setup, click go, then play using keyboard buttons.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

bend
true
0
Rectangle -7500403 true true 0 0 300 300
Line -16777216 false 0 300 45 255
Line -16777216 false 45 0 45 255
Line -16777216 false 255 0 255 45
Line -16777216 false 255 45 300 45
Line -16777216 false 255 45 300 0
Line -16777216 false 45 255 300 255
Line -16777216 false 0 0 0 300
Line -16777216 false 0 300 300 300

end
true
0
Rectangle -7500403 true true 0 0 300 300
Line -16777216 false 0 300 45 255
Line -16777216 false 45 255 255 255
Line -16777216 false 255 255 300 300
Line -16777216 false 255 255 255 0
Line -16777216 false 45 255 45 0
Line -16777216 false 0 300 300 300
Line -16777216 false 0 300 0 0
Line -16777216 false 300 0 300 300

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

mid
true
0
Rectangle -7500403 true true 0 0 300 300
Line -16777216 false 0 0 0 300
Line -16777216 false 45 0 45 300
Line -16777216 false 255 0 255 300
Line -16777216 false 300 0 300 300

o
true
0
Rectangle -7500403 true true 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Rectangle -16777216 false false 45 45 255 255
Line -16777216 false 0 0 45 45
Line -16777216 false 255 45 300 0
Line -16777216 false 255 255 300 300
Line -16777216 false 45 255 0 300

square
false
0
Rectangle -7500403 true true 30 30 270 270

t
true
0
Rectangle -7500403 true true 0 0 300 300
Line -16777216 false 45 0 45 45
Line -16777216 false 45 45 0 45
Line -16777216 false 255 0 255 45
Line -16777216 false 255 45 300 45
Line -16777216 false 0 255 300 255
Line -16777216 false 45 45 0 0
Line -16777216 false 255 45 300 0
Line -16777216 false 0 300 300 300

x
true
0
Rectangle -7500403 true true 0 0 300 300
Line -16777216 false 0 0 45 45
Line -16777216 false 45 45 45 0
Line -16777216 false 45 45 0 45
Line -16777216 false 255 45 255 0
Line -16777216 false 255 45 300 45
Line -16777216 false 255 45 300 0
Line -16777216 false 255 300 255 255
Line -16777216 false 255 255 300 255
Line -16777216 false 255 255 300 300
Line -16777216 false 45 300 45 255
Line -16777216 false 45 255 0 255
Line -16777216 false 0 300 45 255

@#$#@#$#@
NetLogo 5.3.1
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
