###
Folk Tune Finder tune explorer!

Code for drawing keyboards, typesetting staves, plotting melody trees.

Copyright Joe Wass 2011 - 2013
joe@afandian.com
###
ACCIDENTAL =
  SHARP: 's'
  FLAT: 'f'
  NATURAL: 'n'

MIDDLE_C = 60

# Some music theory.
class Theory

  constructor : () -> 
    # The order of preference for black note labelling (D sharp vs E flat) is based on only using black notes for minor scales.
    @DIATONIC_DEGREES =
      0:  [{degree: 0, accidental: ACCIDENTAL.NATURAL}], # C      
      1:  [{degree: 0, accidental: ACCIDENTAL.SHARP}, {degree: 1, accidental: ACCIDENTAL.FLAT}], # C# / Db
      2:  [{degree: 1, accidental: ACCIDENTAL.NATURAL}], # D      
      3:  [{degree: 2, accidental: ACCIDENTAL.FLAT}, {degree: 1, accidental: ACCIDENTAL.SHARP}], # D# / Eb
      4:  [{degree: 2, accidental: ACCIDENTAL.NATURAL}], # E      
      5:  [{degree: 3, accidental: ACCIDENTAL.NATURAL}], # F      
      6:  [{degree: 3, accidental: ACCIDENTAL.SHARP}, {degree: 4, accidental: ACCIDENTAL.FLAT}], # F# / Gb
      7:  [{degree: 4, accidental: ACCIDENTAL.NATURAL}], # G      
      8:  [{degree: 4, accidental: ACCIDENTAL.SHARP}, {degree: 5, accidental: ACCIDENTAL.FLAT}], # G# / Ab
      9:  [{degree: 5, accidental: ACCIDENTAL.NATURAL}], # A      
      10: [{degree: 6, accidental: ACCIDENTAL.FLAT}, {degree: 5, accidental: ACCIDENTAL.SHARP}], # A# / Bb
      11: [{degree: 6, accidental: ACCIDENTAL.NATURAL}] # B      

    @DIATONIC_NOTE_NAMES = ["C", "D", "E", "F", "G", "A", "B"]
  
  # For a given pitch, return the position within the scale starting on the relativeTo.
  # Both numbers are MIDI pitches.
  # Return object of:
  # chromaticDegree: chromatic degree within the scale.
  # accidental: Natural or accidental
  # diatonicDegree: Diatonic degree of scale (0 - 11)
  # diatonicRelative: Diatonic degree of scale relative to note, may be positive or negative.
  positionRelativeToPitch : (givenPitch, relativeTo) ->
      # TODO: MEMOIZE!
      # We need to produce something with a valid absolute value when compared to relativeTo,
      # which it wouln't if it had a lower value.
      # This seems a really stupid way to do it, but it works.
      # Am I being stupid?
      absPitch = givenPitch

      while absPitch < relativeTo
        absPitch += 12

      # The degree within the scale, 0 to 11
      degree = Math.abs((relativeTo-absPitch) % 12)

      # There are sharp/flat alternatives, but for now just get the first one that comes.
      diatonicDegree = @DIATONIC_DEGREES[degree][0].degree
      diatonicAccidental = @DIATONIC_DEGREES[degree][0].accidental

      relativeOctave = Math.floor((givenPitch - relativeTo) / 12)
      diatonicRelative = relativeOctave * 7 + diatonicDegree

      octave = Math.floor(givenPitch / 12)
      
      chromaticDegree: degree
      chromaticAbsolute: givenPitch
      diatonicDegree: diatonicDegree
      diatonicAccidental: diatonicAccidental
      diatonicRelative: diatonicRelative
      octave: octave
  

  noteName : (pitch) ->
      contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C)

      # Ignore sharp or flat hinting for now, take the first option.
      name = @DIATONIC_NOTE_NAMES[contextualDegree.diatonicDegree]

      name = name + if contextualDegree.diatonicAccidental == ACCIDENTAL.SHARP
        "#"
      else if contextualDegree.diatonicAccidental == ACCIDENTAL.FLAT
        "b"
      else
        ""

      name

# TODO singleton. Static methods?
theory = new Theory

# A keyboard adaptor that draws a keyboard on a canvas.
class CanvasKeyboardDrawer
  constructor : (@keyboard, @WHITE_NOTE_WIDTH, height) -> 
    
    @WHITE_NOTE_HEIGHT = height
    @BLACK_NOTE_HEIGHT = height * 0.5

    @BLACK_NOTE_WIDTH = @WHITE_NOTE_WIDTH / 2

    # Marker for Middle X
    @MIDDLE_C_MARKER_RADIUS = @WHITE_NOTE_WIDTH / 4

    # Black note offset from corresponding white note, sharp and flat.
    @BLACK_NOTE_OFFSET_S = @WHITE_NOTE_WIDTH - @BLACK_NOTE_WIDTH / 2
    @BLACK_NOTE_OFFSET_F = @WHITE_NOTE_WIDTH - @BLACK_NOTE_WIDTH / 2

    # Offset in pixels of the keyboard.
    # Used to shift they keyboard left when lowest note isn't zero.
    @keyboardOffset = -@keyOffset(contextualDegree = theory.positionRelativeToPitch(@keyboard.LOWEST_PITCH, MIDDLE_C))
  
  # set draw style. 1 - headline, 2, auxiliary repeating ones.
  setDrawStyle : (@mode) ->
    if @mode == 0
      @BLACK_NOTE_HEIGHT = @WHITE_NOTE_HEIGHT * 0.5
      @WHITE_NOTE_FILL_STYLE = "rgba(240, 240, 240, 1)"
      @WHITE_NOTE_STROKE_STYLE = "rgba(10, 10, 10, 1)"

      @BLACK_NOTE_FILL_STYLE = "rgba(10, 10, 10, 1)"
      @BLACK_NOTE_STROKE_STYLE = "rgba(40, 40, 40, 1)"
    else
      @BLACK_NOTE_HEIGHT = @WHITE_NOTE_HEIGHT

      @WHITE_NOTE_FILL_STYLE = "rgba(240, 240, 240, 1)"
      @WHITE_NOTE_STROKE_STYLE = "rgba(10, 10, 10, 0.4)"

      @BLACK_NOTE_FILL_STYLE = "rgba(100, 100, 100, 1)"
      @BLACK_NOTE_STROKE_STYLE = "rgba(100, 100, 100, 1)"


  draw : (graphicsContext, vNumber) ->
    # Draw the keyboard.
    # vertical number, for drawing vertically stacked keyboards.

    # Vertical keyboard number.
    vNumber |= 0

    @graphicsContext = graphicsContext

    @graphicsContext.save()
    @graphicsContext.translate(0, vNumber * @WHITE_NOTE_HEIGHT)

    # Draw White notes.

    @graphicsContext.fillStyle = @WHITE_NOTE_FILL_STYLE
    @graphicsContext.strokeStyle = @WHITE_NOTE_STROKE_STYLE
    @graphicsContext.lineWidth = 1

    for pitch in [@keyboard.LOWEST_PITCH..@keyboard.HIGHEST_PITCH]
      contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C)
      if contextualDegree.diatonicAccidental == ACCIDENTAL.NATURAL
        @drawKey(contextualDegree)

    # Then draw black notes over them.

    @graphicsContext.fillStyle = @BLACK_NOTE_FILL_STYLE
    @graphicsContext.strokeStyle = @BLACK_NOTE_LINE_STYLE
    @graphicsContext.lineWidth = 1

    for pitch in [@keyboard.LOWEST_PITCH..@keyboard.HIGHEST_PITCH]
      contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C)
      if contextualDegree.diatonicAccidental != ACCIDENTAL.NATURAL
        @drawKey(contextualDegree)

    # Middle C marker.

    if @keyboard.LOWEST_PITCH <= 60 <= @keyboard.HIGHEST_PITCH
      middleCX = @keyOffset(theory.positionRelativeToPitch(60, MIDDLE_C)) + @keyboardOffset 
      graphicsContext.fillStyle = "rgba(0,0,0,0.25)"
      graphicsContext.lineWidth = 1
      graphicsContext.strokeStyle = "rgba(0,0,0,0,0.125)"

      graphicsContext.beginPath()
      graphicsContext.arc(middleCX + @WHITE_NOTE_WIDTH / 2, @WHITE_NOTE_HEIGHT * 0.75, @MIDDLE_C_MARKER_RADIUS, 0, 2 * Math.PI, false)
      graphicsContext.fill()
      graphicsContext.stroke()

    @graphicsContext.restore()

  # Callback.
  drawKey : (contextualDegree) -> 
    x = @keyOffset(contextualDegree) + @keyboardOffset 
    if contextualDegree.diatonicAccidental == ACCIDENTAL.NATURAL 
      # White note.
      @graphicsContext.fillRect(x, 0, @WHITE_NOTE_WIDTH, @WHITE_NOTE_HEIGHT)
      @graphicsContext.strokeRect(x, 0, @WHITE_NOTE_WIDTH, @WHITE_NOTE_HEIGHT)

    else if contextualDegree.diatonicAccidental == ACCIDENTAL.SHARP
      # Black note, sharp.
      @graphicsContext.fillRect(x + @BLACK_NOTE_OFFSET_S, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)
      @graphicsContext.strokeRect(x + @BLACK_NOTE_OFFSET_S, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)

    else if contextualDegree.diatonicAccidental == ACCIDENTAL.FLAT
      # Black note, flat.
      @graphicsContext.fillRect(x + @BLACK_NOTE_OFFSET_F, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)
      @graphicsContext.strokeRect(x + @BLACK_NOTE_OFFSET_F, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)


  # Calculate the offset of a key for a given pitch in absolute terms.
  # i.e. no keyboard offset. This is used to calculate the keyboard offset.
  keyOffset : (contextualDegree) =>
    octaveOffset = (contextualDegree.octave * 7  * @WHITE_NOTE_WIDTH)
    
    if contextualDegree.diatonicAccidental == ACCIDENTAL.NATURAL 
      octaveOffset + contextualDegree.diatonicDegree * @WHITE_NOTE_WIDTH
    else if contextualDegree.diatonicAccidental == ACCIDENTAL.SHARP
      octaveOffset + contextualDegree.diatonicDegree * @WHITE_NOTE_WIDTH
    else if contextualDegree.diatonicAccidental == ACCIDENTAL.FLAT 
      octaveOffset + (contextualDegree.diatonicDegree - 1) * @WHITE_NOTE_WIDTH


# A keyboard
class Keyboard
  constructor: (@LOWEST_PITCH, @HIGHEST_PITCH) ->

# Overall context for tune tree.
class TuneTreeContext
  constructor: (@manager, @state, @drawer) ->
    window.addEventListener("redraw", @redraw)

  run: () -> 
    # Start the render loop in motion.

    @manager.renderLoop()

  redraw : () =>
    # Draw top row with style 0.
    @drawer.setDrawStyle(0)
    @drawer.draw(@manager.graphicsContext, 0)
    
    # Draw the rest with style 1.
    @drawer.setDrawStyle(1)  
    for dep in [1...@state.depth]
      @drawer.draw(@manager.graphicsContext, dep)
   
# The current state of the tune tree.
class TuneTreeState
  constructor : () ->
    @state = []
    @depth = 20

  # Depth of deepest node.
  depth : () ->
    @depth

class CanvasManager
  constructor: (@canvas) ->
    @redrawEvent = new CustomEvent("redraw")

    @canvasSize()

    @requestFrame = (() -> 
      return window.requestAnimationFrame       ||
      window.webkitRequestAnimationFrame ||
      window.mozRequestAnimationFrame    ||
      () -> window.setTimeout(callback, 1000 / 60))()

  canvasSize: () -> 
    @canvas.width = window.innerWidth
    @canvas.height = window.innerHeight
    @graphicsContext = @canvas.getContext("2d")
    window.addEventListener('resize', @canvasSize, false)
  
  render: () -> 
    # Clear canvas prior to drawing.
    @graphicsContext.save()
    @graphicsContext.setTransform(1, 0, 0, 1, 0, 0)
    @graphicsContext.clearRect(0, 0, @canvas.width, @canvas.height)
    @graphicsContext.restore()

    window.dispatchEvent(@redrawEvent)    

  renderLoop: =>
    @render()
    @requestFrame.call(window, @renderLoop)






constructContext = () ->
  KEYBOARD_HEIGHT = 35
  KEY_WIDTH = 15

  # Keyboard content logic.
  keyboard = new Keyboard(60 - (12*3), 60 + (12*3))

  # For drawing on!
  canvas = document.getElementById("canvas")

  # Current state.
  @state = new TuneTreeState()

  # For drawing!
  keyboardDrawer = new CanvasKeyboardDrawer(keyboard, KEY_WIDTH, KEYBOARD_HEIGHT)
  
  # For keeping the canvas filled.
  manager = new CanvasManager(canvas, context)

  # To bind it all together.
  context = new TuneTreeContext(manager, state, keyboardDrawer)
  
  context

context = constructContext()
context.run()
