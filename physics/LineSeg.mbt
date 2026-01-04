///|
pub(all) struct LineSeg {
  priv p1 : Vector3
  priv offset : Vector3
  priv tempP2 : Vector3
  priv p1Offset : Vector3
  length : Double
}

///|
pub fn LineSeg::new(
  p1 : Vector3,
  offset : Vector3,
  p1Offset~ : Vector3 = Vector3::zero()
) -> LineSeg {
  LineSeg::{
    p1: p1 + p1Offset,
    offset,
    tempP2: Vector3::zero(),
    p1Offset,
    length: offset.magnitude(),
  }
}

///|
pub fn LineSeg::from_2pt(
  p1 : Vector3,
  p2 : Vector3,
  p1Offset~ : Vector3 = Vector3::zero()
) -> LineSeg {
  LineSeg::{
    p1,
    offset: p2 - p1,
    tempP2: p2,
    p1Offset,
    length: p2.distance(p1),
  }
}

///|
pub impl IShape for LineSeg with get_position(self : LineSeg) -> Vector3 {
  return self.p1
}

///|
pub impl IShape for LineSeg with update_transform(
  self : LineSeg,
  position : Vector3,
  forward : Vector3
) -> Unit {
  self.p1..set(position).add_up(self.p1Offset)
  self.offset..set(forward)..scale_up(self.length)
  // println("p1: \{self.p1}, p2: \{self.get_pt2()}, length: \{self.length}")
}

///|
pub fn LineSeg::get_pt1(self : LineSeg) -> Vector3 {
  self.p1
}

///|
pub fn LineSeg::get_pt2(self : LineSeg) -> Vector3 {
  self.p1.add(self.offset, out=self.tempP2)
}

///|
pub impl IShape for LineSeg with as_lineSeg(self : LineSeg) -> LineSeg {
  self
}

///|
pub impl IShape for LineSeg with get_shape_type(self : LineSeg) -> ShapeType {
  ignore(self)
  shapeTypeValues.lineSeg
}

///|
pub impl IShape for LineSeg with to_string(self : LineSeg) -> String {
  "{p1:\{self.p1}, p2:\{self.tempP2}, offset:\{self.offset},}"
}
