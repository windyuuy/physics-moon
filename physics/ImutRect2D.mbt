///| immutable Rect2D
pub struct ImutRect2D {
  ///|xMin
  x1 : Double
  ///|xMax
  x2 : Double
  ///|yMin
  y1 : Double
  ///|yMax
  y2 : Double
}

///|
pub fn ImutRect2D::new(
  x1 : Double,
  x2 : Double,
  y1 : Double,
  y2 : Double
) -> ImutRect2D {
  return ImutRect2D::{
    x1: @cmp.minimum(x1, x2),
    x2: @cmp.maximum(x1, x2),
    y1: @cmp.minimum(y1, y2),
    y2: @cmp.maximum(y1, y2),
  }
}

///|
pub fn ImutRect2D::contains(self : ImutRect2D, rect : ImutRect2D) -> Bool {
  return self.x1 <= rect.x1 &&
    self.x2 >= rect.x2 &&
    self.y1 <= rect.y1 &&
    self.y2 >= rect.y2
}

///|
pub fn ImutRect2D::is_intersect(self : ImutRect2D, rect : ImutRect2D) -> Bool {
  return self.x1 <= rect.x2 &&
    self.x2 >= rect.x1 &&
    self.y1 <= rect.y2 &&
    self.y2 >= rect.y1
}

///|
pub fn ImutRect2D::combine(self : ImutRect2D, rect : ImutRect2D) -> ImutRect2D {
  return ImutRect2D::new(
    @cmp.minimum(self.x1, rect.x1),
    @cmp.maximum(self.x2, rect.x2),
    @cmp.minimum(self.y1, rect.y1),
    @cmp.maximum(self.y2, rect.y2),
  )
}

///|
pub fn ImutRect2D::width(self : ImutRect2D) -> Double {
  return self.x2 - self.x1
}

///|
pub fn ImutRect2D::height(self : ImutRect2D) -> Double {
  return self.y2 - self.y1
}
