///|
/// immutable Rect2D
pub struct Rect2D {
  ///xMin
  mut x1 : Double
  ///xMax
  mut x2 : Double
  ///yMin
  mut y1 : Double
  ///yMax
  mut y2 : Double
}

///|
pub fn Rect2D::new(
  x1 : Double,
  x2 : Double,
  y1 : Double,
  y2 : Double,
) -> Rect2D {
  return Rect2D::{
    x1: @cmp.minimum(x1, x2),
    x2: @cmp.maximum(x1, x2),
    y1: @cmp.minimum(y1, y2),
    y2: @cmp.maximum(y1, y2),
  }
}

///|
pub fn Rect2D::new_from_rect2d(rect : Rect2D) -> Rect2D {
  return Rect2D::{ x1: rect.x1, x2: rect.x2, y1: rect.y1, y2: rect.y2 }
}

///|
pub fn Rect2D::set(
  self : Rect2D,
  x1 : Double,
  x2 : Double,
  y1 : Double,
  y2 : Double,
) -> Unit {
  self.x1 = @cmp.minimum(x1, x2)
  self.x2 = @cmp.maximum(x1, x2)
  self.y1 = @cmp.minimum(y1, y2)
  self.y2 = @cmp.maximum(y1, y2)
}

///|
pub fn Rect2D::contains(self : Rect2D, rect : Rect2D) -> Bool {
  return self.x1 <= rect.x1 &&
    self.x2 >= rect.x2 &&
    self.y1 <= rect.y1 &&
    self.y2 >= rect.y2
}

///|
pub fn Rect2D::is_intersect(self : Rect2D, rect : Rect2D) -> Bool {
  return self.x1 <= rect.x2 &&
    self.x2 >= rect.x1 &&
    self.y1 <= rect.y2 &&
    self.y2 >= rect.y1
}

///|
pub fn Rect2D::combine(self : Rect2D, rect : Rect2D) -> Rect2D {
  return Rect2D::new(
    @cmp.minimum(self.x1, rect.x1),
    @cmp.maximum(self.x2, rect.x2),
    @cmp.minimum(self.y1, rect.y1),
    @cmp.maximum(self.y2, rect.y2),
  )
}

///|
pub fn Rect2D::width(self : Rect2D) -> Double {
  return self.x2 - self.x1
}

///|
pub fn Rect2D::height(self : Rect2D) -> Double {
  return self.y2 - self.y1
}

///|
pub fn Rect2D::contains_pt(self : Rect2D, pt : Vector3) -> Bool {
  return self.x1 <= pt.x &&
    self.x2 >= pt.x &&
    self.y1 <= pt.y &&
    self.y2 >= pt.y
}

///|
pub fn Rect2D::contains_circle(
  self : Rect2D,
  pt : Vector3,
  radius~ : Double = 0,
) -> Bool {
  return self.x1 + radius <= pt.x &&
    self.x2 - radius >= pt.x &&
    self.y1 + radius <= pt.y &&
    self.y2 - radius >= pt.y
}

///|
pub fn Rect2D::intersect_circle(
  self : Rect2D,
  pt : Vector3,
  radius~ : Double = 0,
) -> Bool {
  let px = pt.x
  let py = pt.y
  return self.x1 - radius <= px &&
    self.x2 + radius >= px &&
    self.y1 - radius <= py &&
    self.y2 + radius >= py
}

///|
pub fn Rect2D::intersectCircle2(
  self : Rect2D,
  x : Double,
  y : Double,
  radius~ : Double = 0,
) -> Bool {
  return self.x1 - radius <= x &&
    self.x2 + radius >= x &&
    self.y1 - radius <= y &&
    self.y2 + radius >= y
}

///|
pub fn Rect2D::clamp_x(
  self : Rect2D,
  x : Double,
  radius~ : Double = 0,
) -> Double {
  return @cmp.maximum(self.x1 + radius, @cmp.minimum(self.x2 - radius, x))
}

///|
pub fn Rect2D::clamp_y(
  self : Rect2D,
  y : Double,
  radius~ : Double = 0,
) -> Double {
  return @cmp.maximum(self.y1 + radius, @cmp.minimum(self.y2 - radius, y))
}

///|
pub fn Rect2D::clamp_pt(
  self : Rect2D,
  pt : Vector3,
  radius~ : Double = 0,
  out~ : Vector3 = Vector3::zero(),
) -> Vector3 {
  out.set3(self.clamp_x(pt.x, radius~), self.clamp_y(pt.y, radius~), pt.z)
  out
}

///|
pub fn Rect2D::clamp_and_keep_speed(
  self : Rect2D,
  p1 : Vector3,
  pt : Vector3,
  radius~ : Double = 0,
  out~ : Vector3 = Vector3::zero(),
) -> Vector3 {
  let ptx = pt.x
  let pty = pt.y
  let p1x = p1.x
  let p1y = p1.y
  self.clamp_pt(pt, radius~, out~) |> ignore
  if out.x != ptx && out.y != pty {
    // pass
  } else if out.x != ptx {
    let distanceSqr = (p1x - ptx) * (p1x - ptx) + (p1y - pty) * (p1y - pty)
    let dx = out.x - p1x
    let dy = (distanceSqr - dx * dx).sqrt() * (pty - p1y).signum()
    out.y = self.clamp_y(p1y + dy)
  } else if out.y != pty {
    let distanceSqr = (p1x - ptx) * (p1x - ptx) + (p1y - pty) * (p1y - pty)
    let dy = out.y - p1y
    let dx = (distanceSqr - dy * dy).sqrt() * (ptx - p1x).signum()
    out.x = self.clamp_x(p1x + dx)
  }
  out
}

///|
test "Rect2D::clamp_and_keep_speed" {
  // clamp x
  let rect = Rect2D::new(-500, 500, -500, 500)
  let p1 = Vector3::new(493, 0, 0)
  let p2 = Vector3::new(501, 5, 0)
  let p3 = rect.clamp_and_keep_speed(p1, p2, radius=5)
  assert_eq(p3.x, 500.0 - 5.0)
  assert_eq(p3.distance(p1), p2.distance(p1))

  // clamp y
  let rect = Rect2D::new(-500, 500, -500, 500)
  let p1 = Vector3::new(0, 493, 0)
  let p2 = Vector3::new(5, 501, 0)
  let p3 = rect.clamp_and_keep_speed(p1, p2, radius=5)
  assert_eq(p3.y, 500.0 - 5.0)
  assert_eq(p3.distance(p1), p2.distance(p1))

  // clamp xy
  let rect = Rect2D::new(-500, 500, -500, 500)
  let p1 = Vector3::new(493, 493, 0)
  let p2 = Vector3::new(501, 501, 0)
  let p3 = rect.clamp_and_keep_speed(p1, p2, radius=5)
  assert_eq(p3.x, 500.0 - 5.0)
  assert_eq(p3.y, 500.0 - 5.0)

  // clamp nothing
  let rect = Rect2D::new(-500, 500, -500, 500)
  let p1 = Vector3::new(400, 400, 0)
  let p2 = Vector3::new(450, 450, 0)
  let p3 = rect.clamp_and_keep_speed(p1, p2, radius=5)
  assert_eq(p3.x, 450)
  assert_eq(p3.y, 450)
}

///|
pub fn Rect2D::clamp_seg(
  self : Rect2D,
  p1 : Vector3,
  pt : Vector3,
  out~ : Vector3 = Vector3::zero(),
) -> Vector3 {
  let x = self.clamp_x(pt.x)
  let y = self.clamp_y(pt.y)
  let dx1 = x - p1.x
  let dy1 = y - p1.y
  let dx2 = pt.x - p1.x
  let dy2 = pt.y - p1.y
  let cross = @double.abs(dy1 * dx2) - @double.abs(dx1 * dy2)
  if cross > 0 {
    out.set3(x, self.clamp_y(p1.y + dx1 * dy2 / dx2), pt.z)
    out
  } else if cross < 0 {
    out.set3(self.clamp_x(p1.x + dy1 * dx2 / dy2), y, pt.z)
    out
  } else {
    out.set3(x, y, pt.z)
    out
  }
}

///|
test "Rect2D::clamp_seg" {
  // cross>0
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(7, 7, 0), Vector3::new(12, 10, 0))
    assert_eq(pt1, Vector3::new(10, 8.8, 0))
  }
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(7, 3, 0), Vector3::new(12, 0, 0))
    assert_eq(pt1, Vector3::new(10, 1.2, 0))
  }
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(3, 7, 0), Vector3::new(-2, 10, 0))
    assert_eq(pt1, Vector3::new(0, 8.8, 0))
  }
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(3, 3, 0), Vector3::new(-2, 0, 0))
    assert_eq(pt1, Vector3::new(0, 1.2, 0))
  }
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(10, 7, 0), Vector3::new(12, 10, 0))
    assert_eq(pt1, Vector3::new(10, 7, 0))
  }
  if true {
    let rect = Rect2D::new(-10, 10, -10, 10)
    let pt1 = rect.clamp_seg(Vector3::new(-7, 7, 0), Vector3::new(-12, 10, 0))
    assert_eq(pt1, Vector3::new(-10, 8.8, 0))
  }
  if true {
    let rect = Rect2D::new(-10, 10, -10, 10)
    let pt1 = rect.clamp_seg(Vector3::new(-7, -7, 0), Vector3::new(-12, -10, 0))
    assert_eq(pt1, Vector3::new(-10, -8.8, 0))
  }

  // cross<0
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt2 = rect.clamp_seg(Vector3::new(7, 7, 0), Vector3::new(10, 12, 0))
    assert_eq(pt2, Vector3::new(8.8, 10, 0))
  }
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(3, 7, 0), Vector3::new(0, 12, 0))
    assert_eq(pt1, Vector3::new(1.2, 10, 0))
  }
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(7, 3, 0), Vector3::new(10, -2, 0))
    assert_eq(pt1, Vector3::new(8.8, 0, 0))
  }
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(3, 3, 0), Vector3::new(0, -2, 0))
    assert_eq(pt1, Vector3::new(1.2, 0, 0))
  }
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt1 = rect.clamp_seg(Vector3::new(7, 10, 0), Vector3::new(10, 12, 0))
    assert_eq(pt1, Vector3::new(7, 10, 0))
  }

  // cross==0
  if true {
    let rect = Rect2D::new(0, 10, 0, 10)
    let pt2 = rect.clamp_seg(Vector3::new(7, 7, 0), Vector3::new(10, 10, 0))
    assert_eq(pt2, Vector3::new(10, 10, 0))
  }
}

///|
pub fn Rect2D::shrink(self : Rect2D, distance : Double) -> Unit {
  self.x1 += distance
  self.x2 -= distance
  self.y1 += distance
  self.y2 -= distance
}
