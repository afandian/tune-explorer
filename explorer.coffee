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

# Observes a keyboard, draws on a drawing adaptor.
class KeyboardDrawer
  constructor : (@keyboard) ->
    
  # Draw on the adaptor.
  draw : (adaptor) ->
    adaptor.range(@keyboard.LOWEST_PITCH, @keyboard.HIGHEST_PITCH)

    for pitch in [@keyboard.LOWEST_PITCH..@keyboard.HIGHEST_PITCH]
      adaptor.key(pitch)

# An adaptor that draws the keyboard.
class KeyboardAdaptor


# A keyboard adaptor that draws on a canvas.
class CanvasKeyboardAdaptor extends KeyboardAdaptor
  constructor : (@keyboardDrawer, @WHITE_NOTE_WIDTH, height) -> 
    
    @WHITE_NOTE_HEIGHT = height
    @BLACK_NOTE_HEIGHT = height * 0.5

    @BLACK_NOTE_WIDTH = @WHITE_NOTE_WIDTH / 2

    # Marker for Middle X
    @MIDDLE_C_MARKER_RADIUS = @WHITE_NOTE_WIDTH / 4

    # Black note offset from corresponding white note, sharp and flat.
    @BLACK_NOTE_OFFSET_S = @WHITE_NOTE_WIDTH - @BLACK_NOTE_WIDTH / 2
    @BLACK_NOTE_OFFSET_F = @WHITE_NOTE_WIDTH - @BLACK_NOTE_WIDTH / 2

  # Set the keyboard range.
  range: (lowestPitch, highestPitch) ->
    @lowestPitch = lowestPitch
    @highestPitch = highestPitch

    # Offset in pixels of the keyboard.
    # Used to shift they keyboard left when lowest note isn't zero.
    @keyboardOffset = -@keyOffset(lowestPitch)

  draw : (graphicsContext) ->
    # Draw the keyboard. As the code is single-threaded, no need to create a context object,
    # context represented as properties on `this`.

    # TODO This assumes that the context may change. Depending on how I clear the canvas, 
    # we may have a persistent context object removing the need to store it each draw call.
    # Make the context available (may be different for each call).
    @graphicsContext = graphicsContext
    
    # Ask to be drawn twice. First time draw the white notes, second. 
    
    # White colour keys.
    @drawCallbackmode = 0
    @graphicsContext.fillStyle = "rgba(240, 240, 240, 1)"
    @graphicsContext.strokeStyle = "rgba(10, 10, 10, 1)"
    @graphicsContext.lineWidth = 1
    @keyboardDrawer.draw(this)

    # Black colour keys.
    @drawCallbackmode = 1
    @graphicsContext.fillStyle = "rgba(10, 10, 10, 1)"
    @graphicsContext.strokeStyle = "rgba(40, 40, 40, 1)"
    @graphicsContext.lineWidth = 1
    @keyboardDrawer.draw(this)

    # Extras.

    # Middle C marker.
    if @lowestPitch <= 60 <= @highestPitch
      middleCX = @keyOffset(60) + @keyboardOffset 
      graphicsContext.fillStyle = "rgba(0,0,0,0.25)"
      graphicsContext.lineWidth = 1
      graphicsContext.strokeStyle = "rgba(0,0,0,0,0.125)";

      graphicsContext.beginPath();
      graphicsContext.arc(middleCX + @WHITE_NOTE_WIDTH / 2, @WHITE_NOTE_HEIGHT * 0.75, @MIDDLE_C_MARKER_RADIUS, 0, 2 * Math.PI, false);
      graphicsContext.fill();
      graphicsContext.stroke();

  # Callback.
  key : (pitch) -> 
    # @graphicsContext set by draw()

    # TODO: contextualDegree is called by keyOffset(). Optimise?
    contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C)

    # Called twice. First time, drawCallbackmode == 0, draw white notes.
    # Next time draw black notes, on top.
    x = @keyOffset(pitch) + @keyboardOffset 
    if @drawCallbackmode == 0 
      if contextualDegree.diatonicAccidental == ACCIDENTAL.NATURAL 
        # White note.
        @graphicsContext.fillRect(x, 0, @WHITE_NOTE_WIDTH, @WHITE_NOTE_HEIGHT)
        @graphicsContext.strokeRect(x, 0, @WHITE_NOTE_WIDTH, @WHITE_NOTE_HEIGHT)
    else
      if contextualDegree.diatonicAccidental == ACCIDENTAL.SHARP
        # Black note, sharp.
        @graphicsContext.fillRect(x + @BLACK_NOTE_OFFSET_S, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)
        @graphicsContext.strokeRect(x + @BLACK_NOTE_OFFSET_S, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)

      else if contextualDegree.diatonicAccidental == ACCIDENTAL.FLAT
        # Black note, flat.
        @graphicsContext.fillRect(x + @BLACK_NOTE_OFFSET_F, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)
        @graphicsContext.strokeRect(x + @BLACK_NOTE_OFFSET_F, 0, @BLACK_NOTE_WIDTH, @BLACK_NOTE_HEIGHT)


  # Calculate the offset of a key for a given pitch in absolute terms.
  # i.e. no keyboard offset. This is used to calculate the keyboard offset.
  keyOffset : (pitch) =>
    contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C)
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
  constructor: (@renderer, @state, @adaptor) ->
    window.addEventListener("redraw", @redraw)

  run: () -> 
    # Start the render loop in motion.
    @renderer.renderLoop()

  redraw : () =>
    # TODO add stuff here. Maybe pass in something different to @adaptor.draw().
    @adaptor.draw(@renderer.graphicsContext)
   

# The current state of the tune tree.
class TuneTreeState
  constructor : () ->
    @state = []

  maxDepth : () ->
    10

class CanvasRenderer
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
  

  # A bit of dependency injection crud.
  setDrawCallback : (@drawCallback) ->

  render: () -> 
    # Clear canvas prior to drawing.
    # Unclear about efficiency of this vs width = width.
    @graphicsContext.save()
    @graphicsContext.setTransform(1, 0, 0, 1, 0, 0)
    @graphicsContext.clearRect(0, 0, @canvas.width, @canvas.height)
    @graphicsContext.restore()

    #@canvas.width = @canvas.width
    
    if @drawCallback
      @drawCallback()

    window.dispatchEvent(@redrawEvent)    

  renderLoop: =>
    @render()
    @requestFrame.call(window, @renderLoop)






constructContext = () ->
  KEYBOARD_HEIGHT = 30
  KEY_WIDTH = 10

  # Keyboard content logic.
  keyboard = new Keyboard(60 - (12*2), 60 + (12*2))

  # For mediating between the keyboard and the canvas adaptor.
  keyboardDrawer = new KeyboardDrawer(keyboard)

  # For drawing on!
  canvas = document.getElementById("canvas")

  # Current state.
  @state = new TuneTreeState()

  # For drawing!
  adaptor = new CanvasKeyboardAdaptor(keyboardDrawer, KEY_WIDTH, KEYBOARD_HEIGHT)
  
  # For keeping the canvas filled.
  renderer = new CanvasRenderer(canvas, context)

  # To bind it all together.
  context = new TuneTreeContext(renderer, state, adaptor)
  
  context

context = constructContext()
context.run()
