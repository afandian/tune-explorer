// Generated by CoffeeScript 1.6.1

/*
Folk Tune Finder tune explorer!

Code for drawing keyboards, melody trees, searching etc etc.

Copyright Joe Wass 2011 - 2013
joe@afandian.com
*/


(function() {
  var ACCIDENTAL, CanvasKeyboardDrawer, CanvasManager, InteractionState, Keyboard, MIDDLE_C, Theory, TuneTreeContext, TuneTreeState, constructContext, context, theory,
    _this = this;

  ACCIDENTAL = {
    SHARP: 's',
    FLAT: 'f',
    NATURAL: 'n'
  };

  MIDDLE_C = 60;

  Theory = (function() {

    function Theory() {
      this.DIATONIC_DEGREES = {
        0: [
          {
            degree: 0,
            accidental: ACCIDENTAL.NATURAL
          }
        ],
        1: [
          {
            degree: 0,
            accidental: ACCIDENTAL.SHARP
          }, {
            degree: 1,
            accidental: ACCIDENTAL.FLAT
          }
        ],
        2: [
          {
            degree: 1,
            accidental: ACCIDENTAL.NATURAL
          }
        ],
        3: [
          {
            degree: 2,
            accidental: ACCIDENTAL.FLAT
          }, {
            degree: 1,
            accidental: ACCIDENTAL.SHARP
          }
        ],
        4: [
          {
            degree: 2,
            accidental: ACCIDENTAL.NATURAL
          }
        ],
        5: [
          {
            degree: 3,
            accidental: ACCIDENTAL.NATURAL
          }
        ],
        6: [
          {
            degree: 3,
            accidental: ACCIDENTAL.SHARP
          }, {
            degree: 4,
            accidental: ACCIDENTAL.FLAT
          }
        ],
        7: [
          {
            degree: 4,
            accidental: ACCIDENTAL.NATURAL
          }
        ],
        8: [
          {
            degree: 4,
            accidental: ACCIDENTAL.SHARP
          }, {
            degree: 5,
            accidental: ACCIDENTAL.FLAT
          }
        ],
        9: [
          {
            degree: 5,
            accidental: ACCIDENTAL.NATURAL
          }
        ],
        10: [
          {
            degree: 6,
            accidental: ACCIDENTAL.FLAT
          }, {
            degree: 5,
            accidental: ACCIDENTAL.SHARP
          }
        ],
        11: [
          {
            degree: 6,
            accidental: ACCIDENTAL.NATURAL
          }
        ]
      };
      this.DIATONIC_NOTE_NAMES = ["C", "D", "E", "F", "G", "A", "B"];
    }

    Theory.prototype.positionRelativeToPitch = function(givenPitch, relativeTo) {
      var absPitch, degree, diatonicAccidental, diatonicDegree, diatonicRelative, octave, relativeOctave;
      absPitch = givenPitch;
      while (absPitch < relativeTo) {
        absPitch += 12;
      }
      degree = Math.abs((relativeTo - absPitch) % 12);
      diatonicDegree = this.DIATONIC_DEGREES[degree][0].degree;
      diatonicAccidental = this.DIATONIC_DEGREES[degree][0].accidental;
      relativeOctave = Math.floor((givenPitch - relativeTo) / 12);
      diatonicRelative = relativeOctave * 7 + diatonicDegree;
      octave = Math.floor(givenPitch / 12);
      return {
        chromaticDegree: degree,
        chromaticAbsolute: givenPitch,
        diatonicDegree: diatonicDegree,
        diatonicAccidental: diatonicAccidental,
        diatonicRelative: diatonicRelative,
        octave: octave
      };
    };

    Theory.prototype.noteName = function(pitch) {
      var contextualDegree, name;
      contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C);
      name = this.DIATONIC_NOTE_NAMES[contextualDegree.diatonicDegree];
      name = name + (contextualDegree.diatonicAccidental === ACCIDENTAL.SHARP ? "#" : contextualDegree.diatonicAccidental === ACCIDENTAL.FLAT ? "b" : "");
      return name;
    };

    return Theory;

  })();

  theory = new Theory;

  CanvasKeyboardDrawer = (function() {

    function CanvasKeyboardDrawer(keyboard, WHITE_NOTE_WIDTH, height) {
      var _this = this;
      this.keyboard = keyboard;
      this.WHITE_NOTE_WIDTH = WHITE_NOTE_WIDTH;
      this.keyOffset = function(contextualDegree, middle) {
        return CanvasKeyboardDrawer.prototype.keyOffset.apply(_this, arguments);
      };
      this.WHITE_NOTE_HEIGHT = height;
      this.CANONICAL_BLACK_NOTE_HEIGHT = this.WHITE_NOTE_HEIGHT * 0.5;
      this.BLACK_NOTE_WIDTH = this.WHITE_NOTE_WIDTH / 2;
      this.HOVER_FILL_STYLE = "rgba(200, 10, 10, 1)";
      this.SELECTED_PATH_FILL_STYLE = "rgba(10, 10, 10, 0.7)";
      this.SELECTED_KEY_FILL_STYLE = "rgba(100, 200, 100, 1)";
      this.SELECTED_STROKE_WIDTH = 3;
      this.MIDDLE_C_MARKER_RADIUS = this.WHITE_NOTE_WIDTH / 5;
      this.BLACK_NOTE_OFFSET = this.WHITE_NOTE_WIDTH - this.BLACK_NOTE_WIDTH / 2;
      this.keyboardOffset = -this.keyOffset(theory.positionRelativeToPitch(this.keyboard.LOWEST_PITCH, MIDDLE_C));
      this.calculateMouseRanges();
    }

    CanvasKeyboardDrawer.prototype.calculateMouseRanges = function() {
      var black, contextualDegree, lastPitch, lowerX, nextBlack, nextContextualDegree, pitch, prevBlack, prevContextualDegree, upperX, _i, _j, _ref, _ref1, _ref2, _ref3, _results;
      this.mixedMouseRanges = [];
      this.whiteMouseRanges = [];
      contextualDegree = theory.positionRelativeToPitch(this.keyboard.LOWEST_PITCH, MIDDLE_C);
      lowerX = this.keyOffset(contextualDegree) + this.keyboardOffset;
      lastPitch = this.keyboard.LOWEST_PITCH;
      for (pitch = _i = _ref = this.keyboard.LOWEST_PITCH + 1, _ref1 = this.keyboard.HIGHEST_PITCH + 2; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; pitch = _ref <= _ref1 ? ++_i : --_i) {
        contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C);
        if (contextualDegree.diatonicAccidental === ACCIDENTAL.NATURAL) {
          upperX = this.keyOffset(contextualDegree) + this.keyboardOffset;
          this.whiteMouseRanges.push(lowerX);
          this.whiteMouseRanges.push(upperX);
          this.whiteMouseRanges.push(lastPitch);
          lowerX = upperX;
          lastPitch = pitch;
        }
      }
      _results = [];
      for (pitch = _j = _ref2 = this.keyboard.LOWEST_PITCH, _ref3 = this.keyboard.HIGHEST_PITCH; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; pitch = _ref2 <= _ref3 ? ++_j : --_j) {
        contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C);
        nextContextualDegree = theory.positionRelativeToPitch(pitch + 1, MIDDLE_C);
        prevContextualDegree = theory.positionRelativeToPitch(pitch - 1, MIDDLE_C);
        black = contextualDegree.diatonicAccidental !== ACCIDENTAL.NATURAL;
        nextBlack = nextContextualDegree.diatonicAccidental !== ACCIDENTAL.NATURAL;
        prevBlack = prevContextualDegree.diatonicAccidental !== ACCIDENTAL.NATURAL;
        lowerX = this.keyOffset(contextualDegree) + this.keyboardOffset;
        upperX = lowerX + (black ? this.BLACK_NOTE_WIDTH : this.WHITE_NOTE_WIDTH);
        if (prevBlack) {
          lowerX += this.BLACK_NOTE_WIDTH / 2;
        }
        if (nextBlack) {
          upperX -= this.BLACK_NOTE_WIDTH / 2;
        }
        this.mixedMouseRanges.push(lowerX);
        this.mixedMouseRanges.push(upperX);
        _results.push(this.mixedMouseRanges.push(pitch));
      }
      return _results;
    };

    CanvasKeyboardDrawer.prototype.mousePitchForXY = function(x, y) {
      var i, row, _i, _j, _ref, _ref1;
      row = Math.floor(y / this.WHITE_NOTE_HEIGHT);
      if (row === 0 && y > this.CANONICAL_BLACK_NOTE_HEIGHT) {
        for (i = _i = 0, _ref = this.whiteMouseRanges.length / 3; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          if ((this.whiteMouseRanges[i * 3] <= x && x <= this.whiteMouseRanges[i * 3 + 1])) {
            return [this.whiteMouseRanges[i * 3 + 2], row];
          }
        }
      } else {
        for (i = _j = 0, _ref1 = this.mixedMouseRanges.length / 3; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          if ((this.mixedMouseRanges[i * 3] <= x && x <= this.mixedMouseRanges[i * 3 + 1])) {
            return [this.mixedMouseRanges[i * 3 + 2], row];
          }
        }
      }
      return null;
    };

    CanvasKeyboardDrawer.prototype.setDrawStyle = function(mode) {
      this.mode = mode;
      if (this.mode === 0) {
        this.BLACK_NOTE_HEIGHT = this.CANONICAL_BLACK_NOTE_HEIGHT;
        this.WHITE_NOTE_FILL_STYLE = "rgba(240, 240, 240, 1)";
        this.WHITE_NOTE_STROKE_STYLE = "rgba(10, 10, 10, 1)";
        this.BLACK_NOTE_FILL_STYLE = "rgba(10, 10, 10, 1)";
        return this.BLACK_NOTE_STROKE_STYLE = "rgba(40, 40, 40, 1)";
      } else {
        this.BLACK_NOTE_HEIGHT = this.WHITE_NOTE_HEIGHT;
        this.WHITE_NOTE_FILL_STYLE = "rgba(240, 240, 240, 1)";
        this.WHITE_NOTE_STROKE_STYLE = "rgba(10, 10, 10, 0.4)";
        this.BLACK_NOTE_FILL_STYLE = "rgba(100, 100, 100, 1)";
        return this.BLACK_NOTE_STROKE_STYLE = "rgba(100, 100, 100, 1)";
      }
    };

    CanvasKeyboardDrawer.prototype.draw = function(graphicsContext, vNumber, hoverPitch, selectedPitch) {
      var contextualDegree, middleCX, pitch, _i, _j, _ref, _ref1, _ref2, _ref3;
      vNumber |= 0;
      this.graphicsContext = graphicsContext;
      this.graphicsContext.save();
      this.graphicsContext.translate(0, vNumber * this.WHITE_NOTE_HEIGHT);
      this.graphicsContext.fillStyle = this.WHITE_NOTE_FILL_STYLE;
      this.graphicsContext.strokeStyle = this.WHITE_NOTE_STROKE_STYLE;
      this.graphicsContext.lineWidth = 1;
      for (pitch = _i = _ref = this.keyboard.LOWEST_PITCH, _ref1 = this.keyboard.HIGHEST_PITCH; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; pitch = _ref <= _ref1 ? ++_i : --_i) {
        contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C);
        if (contextualDegree.diatonicAccidental === ACCIDENTAL.NATURAL) {
          if (selectedPitch === pitch) {
            this.graphicsContext.fillStyle = this.SELECTED_KEY_FILL_STYLE;
          }
          if (hoverPitch === pitch) {
            this.graphicsContext.fillStyle = this.HOVER_FILL_STYLE;
          }
          this.drawKey(contextualDegree);
          if (hoverPitch === pitch || selectedPitch === pitch) {
            this.graphicsContext.fillStyle = this.WHITE_NOTE_FILL_STYLE;
          }
        }
      }
      this.graphicsContext.fillStyle = this.BLACK_NOTE_FILL_STYLE;
      this.graphicsContext.strokeStyle = this.BLACK_NOTE_STROKE_STYLE;
      this.graphicsContext.lineWidth = 1;
      for (pitch = _j = _ref2 = this.keyboard.LOWEST_PITCH, _ref3 = this.keyboard.HIGHEST_PITCH; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; pitch = _ref2 <= _ref3 ? ++_j : --_j) {
        contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C);
        if (contextualDegree.diatonicAccidental !== ACCIDENTAL.NATURAL) {
          if (selectedPitch === pitch) {
            this.graphicsContext.fillStyle = this.SELECTED_KEY_FILL_STYLE;
          }
          if (hoverPitch === pitch) {
            this.graphicsContext.fillStyle = this.HOVER_FILL_STYLE;
          }
          this.drawKey(contextualDegree);
          if (hoverPitch === pitch || selectedPitch === pitch) {
            this.graphicsContext.fillStyle = this.BLACK_NOTE_FILL_STYLE;
          }
        }
      }
      if ((this.keyboard.LOWEST_PITCH <= 60 && 60 <= this.keyboard.HIGHEST_PITCH)) {
        middleCX = this.keyOffset(theory.positionRelativeToPitch(60, MIDDLE_C)) + this.keyboardOffset;
        graphicsContext.fillStyle = "rgba(0,0,0,0.25)";
        graphicsContext.lineWidth = 1;
        graphicsContext.strokeStyle = "rgba(0,0,0,0.125)";
        graphicsContext.beginPath();
        graphicsContext.arc(middleCX + this.WHITE_NOTE_WIDTH / 2, this.WHITE_NOTE_HEIGHT * 0.75, this.MIDDLE_C_MARKER_RADIUS, 0, 2 * Math.PI, false);
        graphicsContext.fill();
        graphicsContext.stroke();
      }
      return this.graphicsContext.restore();
    };

    CanvasKeyboardDrawer.prototype.drawKey = function(contextualDegree) {
      var x;
      x = this.keyOffset(contextualDegree) + this.keyboardOffset;
      if (contextualDegree.diatonicAccidental === ACCIDENTAL.NATURAL) {
        this.graphicsContext.fillRect(x, 0, this.WHITE_NOTE_WIDTH, this.WHITE_NOTE_HEIGHT);
        return this.graphicsContext.strokeRect(x, 0, this.WHITE_NOTE_WIDTH, this.WHITE_NOTE_HEIGHT);
      } else if (contextualDegree.diatonicAccidental === ACCIDENTAL.SHARP) {
        this.graphicsContext.fillRect(x, 0, this.BLACK_NOTE_WIDTH, this.BLACK_NOTE_HEIGHT);
        return this.graphicsContext.strokeRect(x, 0, this.BLACK_NOTE_WIDTH, this.BLACK_NOTE_HEIGHT);
      } else if (contextualDegree.diatonicAccidental === ACCIDENTAL.FLAT) {
        this.graphicsContext.fillRect(x, 0, this.BLACK_NOTE_WIDTH, this.BLACK_NOTE_HEIGHT);
        return this.graphicsContext.strokeRect(x, 0, this.BLACK_NOTE_WIDTH, this.BLACK_NOTE_HEIGHT);
      }
    };

    CanvasKeyboardDrawer.prototype.drawSelectionPath = function(path) {
      var contextualDegree, oldX, oldY, pitch, vOffset, x, _i, _len, _ref;
      vOffset = this.WHITE_NOTE_WIDTH * 0.50;
      if (path.length === 0) {
        return;
      }
      this.graphicsContext.strokeStyle = this.SELECTED_PATH_FILL_STYLE;
      this.graphicsContext.lineWidth = this.SELECTED_STROKE_WIDTH;
      this.graphicsContext.beginPath();
      contextualDegree = theory.positionRelativeToPitch(path[0], MIDDLE_C);
      x = this.keyOffset(contextualDegree, true) + this.keyboardOffset;
      this.graphicsContext.moveTo(x, vOffset);
      oldX = x;
      oldY = vOffset;
      _ref = path.slice(1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pitch = _ref[_i];
        vOffset += this.WHITE_NOTE_HEIGHT;
        contextualDegree = theory.positionRelativeToPitch(pitch, MIDDLE_C);
        x = this.keyOffset(contextualDegree, true) + this.keyboardOffset;
        this.graphicsContext.bezierCurveTo(oldX, oldY + 10, x, vOffset - 10, x, vOffset);
        oldX = x;
        oldY = vOffset;
      }
      return this.graphicsContext.stroke();
    };

    CanvasKeyboardDrawer.prototype.keyOffset = function(contextualDegree, middle) {
      var octaveOffset;
      octaveOffset = contextualDegree.octave * 7 * this.WHITE_NOTE_WIDTH;
      if (contextualDegree.diatonicAccidental === ACCIDENTAL.NATURAL) {
        return octaveOffset + contextualDegree.diatonicDegree * this.WHITE_NOTE_WIDTH + (middle ? this.WHITE_NOTE_WIDTH / 2 : 0);
      } else if (contextualDegree.diatonicAccidental === ACCIDENTAL.SHARP) {
        return octaveOffset + this.BLACK_NOTE_OFFSET + contextualDegree.diatonicDegree * this.WHITE_NOTE_WIDTH + (middle ? this.BLACK_NOTE_WIDTH / 2 : 0);
      } else if (contextualDegree.diatonicAccidental === ACCIDENTAL.FLAT) {
        return octaveOffset + this.BLACK_NOTE_OFFSET + (contextualDegree.diatonicDegree - 1) * this.WHITE_NOTE_WIDTH + (middle ? this.BLACK_NOTE_WIDTH / 2 : 0);
      }
    };

    return CanvasKeyboardDrawer;

  })();

  Keyboard = (function() {

    function Keyboard(LOWEST_PITCH, HIGHEST_PITCH) {
      this.LOWEST_PITCH = LOWEST_PITCH;
      this.HIGHEST_PITCH = HIGHEST_PITCH;
    }

    return Keyboard;

  })();

  TuneTreeContext = (function() {

    function TuneTreeContext(manager, state, drawer, interactionState) {
      var _this = this;
      this.manager = manager;
      this.state = state;
      this.drawer = drawer;
      this.interactionState = interactionState;
      this.mouseclick = function(event) {
        return TuneTreeContext.prototype.mouseclick.apply(_this, arguments);
      };
      this.mousemove = function(event) {
        return TuneTreeContext.prototype.mousemove.apply(_this, arguments);
      };
      this.redraw = function() {
        return TuneTreeContext.prototype.redraw.apply(_this, arguments);
      };
      jQuery("body").bind("redraw", this.redraw);
      jQuery(this.manager.canvas).bind("mousemove", this.mousemove);
      jQuery(this.manager.canvas).bind("mouseup", this.mouseclick);
    }

    TuneTreeContext.prototype.run = function() {
      return this.manager.renderLoop();
    };

    TuneTreeContext.prototype.redraw = function() {
      var hoverPitch, numRowsToShow, row, selectedPitch, _i;
      hoverPitch = 0 === this.interactionState.hoverRow ? this.interactionState.hoverPitch : null;
      selectedPitch = this.state.path[0] || null;
      this.drawer.setDrawStyle(0);
      this.drawer.draw(this.manager.graphicsContext, 0, hoverPitch, selectedPitch);
      this.drawer.setDrawStyle(1);
      numRowsToShow = this.state.maxed() ? this.state.depth() + 1 : this.state.depth();
      for (row = _i = 1; 1 <= numRowsToShow ? _i < numRowsToShow : _i > numRowsToShow; row = 1 <= numRowsToShow ? ++_i : --_i) {
        hoverPitch = row === this.interactionState.hoverRow ? this.interactionState.hoverPitch : null;
        selectedPitch = this.state.path[row] || null;
        this.drawer.draw(this.manager.graphicsContext, row, hoverPitch, selectedPitch);
      }
      return this.drawer.drawSelectionPath(this.state.path);
    };

    TuneTreeContext.prototype.mousemove = function(event) {
      var pitchRow, x, y;
      if (event.offsetX) {
        x = event.offsetX;
        y = event.offsetY;
      } else if (event.layerX) {
        x = event.layerX;
        y = event.layerY;
      } else {
        x = 0;
        y = 0;
      }
      this.interactionState.mouseX = x;
      this.interactionState.mouseY = y;
      pitchRow = this.drawer.mousePitchForXY(x, y);
      if (pitchRow !== null) {
        return this.interactionState.hoverPitch = pitchRow[0], this.interactionState.hoverRow = pitchRow[1], pitchRow;
      }
    };

    TuneTreeContext.prototype.mouseclick = function(event) {
      var pitch, pitchRow, row, x, y;
      if (event.offsetX) {
        x = event.offsetX;
        y = event.offsetY;
      } else if (event.layerX) {
        x = event.layerX;
        y = event.layerY;
      } else {
        x = 0;
        y = 0;
      }
      pitchRow = this.drawer.mousePitchForXY(x, y);
      if (pitchRow !== null) {
        pitch = pitchRow[0], row = pitchRow[1];
        return this.state.select(pitch, row);
      }
    };

    return TuneTreeContext;

  })();

  InteractionState = (function() {

    function InteractionState() {
      this.mouseX = 0;
      this.mouseY = 0;
      this.hoverPitch = null;
    }

    return InteractionState;

  })();

  TuneTreeState = (function() {

    function TuneTreeState(path, max_depth) {
      var _this = this;
      this.path = path;
      this.max_depth = max_depth;
      this.path = this.path || [];
      setTimeout((function() {
        return jQuery("body").trigger("searchPathChanged", [_this.path]);
      }), 100);
    }

    TuneTreeState.prototype.depth = function() {
      return this.path.length;
    };

    TuneTreeState.prototype.maxed = function() {
      return this.depth() < this.max_depth;
    };

    TuneTreeState.prototype.select = function(pitch, row) {
      var change;
      change = false;
      if (row === this.depth() && row < this.max_depth) {
        this.path.push(pitch);
        change = true;
      } else if (row < this.depth()) {
        this.path[row] = pitch;
        this.path = this.path.slice(0, +row + 1 || 9e9);
        change = true;
      }
      if (change) {
        return jQuery("body").trigger("searchPathChanged", [this.path]);
      }
    };

    return TuneTreeState;

  })();

  CanvasManager = (function() {

    function CanvasManager(canvas, fillScreen) {
      var _this = this;
      this.canvas = canvas;
      this.fillScreen = fillScreen;
      this.renderLoop = function() {
        return CanvasManager.prototype.renderLoop.apply(_this, arguments);
      };
      this.jqBody = jQuery("body");
      this.graphicsContext = this.canvas.getContext("2d");
      if (this.fillScreen) {
        window.addEventListener('resize', this.canvasResize, false);
        this.canvasResize();
      }
      this.requestFrame = (function() {
        return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || function(callback) {
          return window.setTimeout(callback, 1000 / 60);
        };
      })();
    }

    CanvasManager.prototype.canvasResize = function() {
      this.canvas.width = window.innerWidth;
      return this.canvas.height = window.innerHeight;
    };

    CanvasManager.prototype.render = function() {
      this.graphicsContext.save();
      this.graphicsContext.setTransform(1, 0, 0, 1, 0, 0);
      this.graphicsContext.clearRect(0, 0, this.canvas.width, this.canvas.height);
      this.graphicsContext.restore();
      return this.jqBody.trigger("redraw");
    };

    CanvasManager.prototype.renderLoop = function() {
      this.render();
      return this.requestFrame.call(window, this.renderLoop);
    };

    return CanvasManager;

  })();

  constructContext = function() {
    var KEYBOARD_HEIGHT, KEY_WIDTH, MAX_DEPTH, canvas, context, interactionState, keyboard, keyboardDrawer, manager, pitch, pitches, pitchesStrings;
    KEYBOARD_HEIGHT = 30;
    KEY_WIDTH = 15;
    MAX_DEPTH = 20;
    if (window.location.hash) {
      pitchesStrings = window.location.hash.slice(1).split(":");
      pitches = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = pitchesStrings.length; _i < _len; _i++) {
          pitch = pitchesStrings[_i];
          _results.push(parseInt(pitch, 10));
        }
        return _results;
      })();
    }
    keyboard = new Keyboard(60 - (12 * 2), 60 + (12 * 2));
    canvas = document.getElementById("canvas");
    this.state = new TuneTreeState(pitches, MAX_DEPTH);
    keyboardDrawer = new CanvasKeyboardDrawer(keyboard, KEY_WIDTH, KEYBOARD_HEIGHT);
    manager = new CanvasManager(canvas, context);
    interactionState = new InteractionState();
    context = new TuneTreeContext(manager, state, keyboardDrawer, interactionState);
    return context;
  };

  context = constructContext();

  context.run();

}).call(this);
