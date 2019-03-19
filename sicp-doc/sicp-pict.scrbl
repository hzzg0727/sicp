#lang scribble/doc

@(require scribble/manual scribble/eval
          (for-label sicp-pict
                     (only-in racket/contract any/c and/c <=/c natural-number/c)
                     racket/base))

@title{SICP Picture Language}
@defmodule[sicp-pict]

@index["painter"]{}
@index["geometry"]{}
@index["picture"]{}
@index["Escher"]{}

@section{Introduction to the SICP Picture Language}

The SICP Picture Language is a small language for drawing pictures.
It shows the power of data abstraction and closure. The picture language
stems from Peter Henderson's 1982 paper "Functional Geometry" and was
included by Hal Abelson in "Structure and Interpretation of Computer
Programs".

The basic concept of the picture language is a @emph{painter}, which draws
its image (shifted and scaled) within a frame given by a parallelogram.
Painters can be combined to construct new painters.

Before using this package, read
@link["https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-15.html#%_sec_2.2.4"]{section 2.2.4 of SICP},
which is an excellent introduction to the ideas of the picture language.
This manual is meant as a reference guide.

Peter Henderson has written an updated version of
@link["http://eprints.ecs.soton.ac.uk/7577/01/funcgeo2.pdf"]{Functional Geometry},
which explains how to construct the Escher fish image.

@section{Example}

Using @racket[sicp-pict] from a @tt{#lang sicp} program:

@codeblock{
  #lang sicp
  (#%require sicp-pict)
  (paint einstein)
}

Using @racket[sicp-pict] from a @tt{#lang racket} program:

@codeblock{
  #lang racket
  (require sicp-pict)
  (paint einstein)
}

From the REPL:

@schemeblock[
> (require sicp-pict)
> (paint (number->painter 0))
> (paint diagonal-shading)
> (paint (below (beside diagonal-shading
                (rotate90 diagonal-shading))
         (beside (rotate270 diagonal-shading)
                 (rotate180 diagonal-shading))))
> (paint einstein)
]

@section{Vectors}

A mathematical vector is called a @emph{vect} here, in order
to avoid confusion with the builtin vectors of Scheme.

@defproc[(vect? [v any/c]) boolean?]{
Returns @racket[#t] if @racket[v] is a vect, @racket[#f] otherwise.
}

@defproc[(make-vect [x real?] [y real?]) vect?]{
Constructs a vect with the given coordinates.
}

@defproc[(vector-xcor [v vect?]) real?]{
Returns the x-coordinate.
}

@defproc[(vector-ycor [v vect?]) real?]{
Returns the y-coordinate.
}

@defproc[(vector-add [v vect?] [w vect?]) vect?]{
Adds the two vects by adding their coordinates pairwise.
}

@defproc[(vector-sub [v vect?] [w vect?]) vect?]{
Subtracts the two vects by subtracting their coordinates pairwise.
}

@defproc[(vector-scale [s real?] [v vect?]) vect?]{
Scales the vect by multiplying each coordinate of @racket[v] with
the number @racket[s].
}

@section{Frames}

A @emph{frame} is descibed by three vectors.
@verbatim{
      ^
      | frame edge2 vector
      |
     _|__________>
     /|         frame edge1 vector
    /
   /
  / frame origin pointer
}

@defproc[(frame? [f any/c]) boolean?]{
  Returns @racket[#t] is @racket[f] is a frame, @racket[#f] otherwise.
}

@defproc[(make-frame [origin vect?] [edge1 vect?] [edge2 vect?]) frame?]{
  Constructs a frame from a frame origin vector and two frame edge vectors.
}

@deftogether[(@defproc[(frame-origin [f frame?]) vect?]
              @defproc[(frame-edge1 [f frame?]) vect?]
              @defproc[(frame-edge2 [f frame?]) vect?])]{
  Extracts the origin, first edge or second edge from a frame.
}

@defproc[(make-relative-frame [origin vect?]
                              [corner1 vect?]
                              [corner2 vect?]) (frame? . -> . frame?)]{
  The function @scheme[make-relative-frame] provides a convenient way to
  transform frames. Given a frame and three points: @racket[origin],
  @racket[corner1], and @racket[corner2] (expressed in frame coordinates),
  it returns a new frame with those corners.
}

@defproc[(frame-coord-map [f frame?]) (vect? . -> . vect?)]{
  Each frame determines a system of "frame coordinates" (x,y) where
  (0,0) is the origin of the frame, x represents the displacement
  along the first edge (as a fraction of the length of the edge) and
  y is the displacement along the second edge.

  The frame coordinate map is returned by @racket[frame-coord-map]. E.g.
  these expression return the same value:

  @itemlist[
    @item{@scheme[((frame-coord-map a-frame) (make-vect 0 0))]}
    @item{@scheme[(frame-origin a-frame)]}
  ]
}

@section{Segments}

A pair of vectors determines a @emph{directed line segment} which
runs from the endpoint of the first vect to the endpoint of the
second vect.

@defproc[(segment? [s any/c]) boolean?]{
  Returns @racket[#t] if @racket[s] is a segment, @racket[#f] otherwise.
}

@defproc[(make-segment [from vect?] [to vect?]) segment?]{
  Constructs a segment from @racket[from] to @racket[to].
}

@deftogether[(@defproc[(segment-start [s segment?]) vect?]
              @defproc[(segment-end [s segment?]) vect?])]{
  Returns the start and the end of a segment @racket[s] respectively.
}

@section{Primitive Painters}

Painters take a frame and draw an image, transformed to fit inside the frame.

There are four ways to create painters:
@itemize[@item{from a constant:               @scheme[number->painter]}
         @item{from a list of line segments:  @scheme[segments->painter]}
         @item{form a procedure:              @scheme[procedure->painter]}
         @item{from a picture:                @scheme[picture->painter]}]

@defproc[(number->painter [color (and/c natural-number/c (<=/c 255))]) painter?]{
Constructs a painter that fills the frame with a gray color indicated
by the number. 0 is black and 255 is white.
}

@defproc[(segments->painter [los list-of-segment?]) painter?]{
Constructs a painter that draws a stick figure given by the
segments (w.r.t. the unit square).}


@defproc[(procedure->painter [f procedure?]) painter?]{

Creates painters from procedures.  We assume that the procedure
@racket[f] is defined on the unit square.

Then to plot a point p in the target frame, we find the inverse image
T^-1(p) of p under the transformation that maps the unit square to the
target, and find the value of @racket[f] at T-1(p).
}

@defproc[(picture->painter [p picture?]) painter?]{
The picture @racket[p] is defined on some frame.

Given a point @racket[p] in the target frame, we compute T^-1(p) where T
is the transformation that takes the picture frame to the
target frame, and find the picture value at the closest
integer point.
}

@defproc[(load-painter [filename path?]) painter?]{
Uses the image file given by @racket[filename] to create a painter.}

@section{Higher Order Painters}

@defproc[(transform-painter [origin vect?]
                            [corner1 vect?]
                            [corner2 vect?]) (painter? . -> . painter?)]{
A painter can be transformed to produce a new painter which, when
given a frame, calls the original painter on the transformed frame.

Transform-painter will given an origin and two corners, return
a function that takes a painter as argument and returns
a transformed painter.
}

@defproc[(flip-horiz [p painter?]) painter?]{
Returns a painter that flips the image horizontally.}

@defproc[(flip-vert [p painter?]) painter?]{
Returns a painter that flips the image vertically.}

@deftogether[(@defproc[(rotate90 [p painter?]) painter?]
              @defproc[(rotate180 [p painter?]) painter?]
              @defproc[(rotate270 [p painter?]) painter?])]{
Returns a painter that rotates the image.}

@defproc[(beside [p1 painter?] [p2 painter?]) painter?]{
Constructs a painter that paints the images side-by-side.}

@defproc[(below [p1 painter?] [p2 painter?]) painter?]{
Constructs a painter that paints the second image
below the first.}

@defproc[(superpose [p1 painter?] [p2 painter?]) painter?]{
Constructs a painter that paints the two images
on top of each other.}

@section{Simple Builtin Painters}

The following painter values are built-in:

@deftogether[(@defthing[black painter?]
              @defthing[white painter?]
              @defthing[gray painter?])]{
  Fills the frame with black (0), white (255) or gray (150).
}

@defthing[diagonal-shading painter?]{
  Fills the frame with a shades of gray. The color transition
  goes from black in the upper left corner is black, to gray
  in the bottom right corner.
}

@defthing[einstein painter?]{
  Draws an image of Einstein.
}

@section{Painting}

@defproc[(paint [p painter?]) snip?]{
  Returns a snip, an image that DrRacket can display automatically, containing the painter's image.
}

@deftogether[(@defproc[(paint-hi-res [p painter?]) snip?]
              @defproc[(paint-hires [p painter?]) snip?])]{
  The same as @racket[paint]. They are provided for compatibility with old texts.
}