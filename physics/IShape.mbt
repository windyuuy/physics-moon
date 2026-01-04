///|
pub(all) enum ShapeType {
  Value(Int)
} derive(Eq)

///|
pub fn ShapeType::get_x(self : ShapeType) -> Int {
  match self {
    Value(x) => x
  }
}

///|
pub(all) struct ShapeTypeValues {
  circle : ShapeType
  circle_circle : ShapeType
  lineSeg : ShapeType
  circle_lineSeg : ShapeType
  lineSeg_lineSeg : ShapeType
}

///|
pub let shapeTypeValues : ShapeTypeValues = ShapeTypeValues::{
  circle: ShapeType::Value(1),
  circle_circle: ShapeType::Value(1),
  lineSeg: ShapeType::Value(2),
  circle_lineSeg: ShapeType::Value(3),
  lineSeg_lineSeg: ShapeType::Value(2),
}

///|
pub(open) trait IShape {
  get_shape_type(Self) -> ShapeType
  // center world position
  get_position(Self) -> Vector3
  update_transform(Self, Vector3, Vector3) -> Unit
  as_circle(Self) -> Circle = _
  as_lineSeg(Self) -> LineSeg = _
  to_string(Self) -> String
  get_aabbi(Self, Double, AABBI) -> Unit = _
  // get unit size
  get_size(Self) -> Double = _
  set_size1(Self, Double) -> Unit = _
}

///|
impl IShape with get_aabbi(_ : Self, _ : Double, _ : AABBI) -> Unit {
  thrown("not implemented")
}

///|
impl IShape with get_size(_ : Self) -> Double {
  thrown("not implemented")
}

///|
impl IShape with as_circle(self : Self) -> Circle {
  ignore(self)
  panic()
}

///|
impl IShape with as_lineSeg(self : Self) -> LineSeg {
  ignore(self)
  panic()
}

// pub struct GetShapesFlagResult{
//   typeFlag: Int
//   shapeA: &IShape
//   shapeB: &IShape
// }

///|
pub fn &IShape::get_shapes_flag(self : &IShape, other : &IShape) -> Int {
  let typeA = self.get_shape_type().get_x()
  let typeB = other.get_shape_type().get_x()
  let isInOrder = typeA < typeB
  // let (shapeA, shapeB) = if isInOrder { (self, other) } else { (other, self) }
  let typeFlag = typeA | typeB
  // (typeFlag, shapeA, shapeB)
  if isInOrder {
    typeFlag
  } else {
    typeFlag | 0x80000000
  }
}

///|
pub fn &IShape::get_distance(self : &IShape, other : &IShape) -> Double {
  let typeFlagX = self.get_shapes_flag(other)
  let typeFlag = typeFlagX & 0x7FFFFFFF
  let shapeA = if typeFlag == typeFlagX { self } else { other }
  let shapeB = if typeFlag == typeFlagX { other } else { self }
  let baseDistance = shapeA.get_position().distance(shapeB.get_position())
  if typeFlag == shapeTypeValues.circle_circle.get_x() {
    @cmp.maximum(
      0,
      baseDistance -
      (shapeA.as_circle().get_radius() + shapeB.as_circle().get_radius()),
    )
  } else {
    baseDistance
  }
}

///|
test "IShape::get_shapes_flag" {
  let circle1 = Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0)
  let circle2 = Circle::new(Vector3::new(1.0, 0.0, 0.0), 1.0)
  let typeFlagX = &IShape::get_shapes_flag(circle1, circle2)
  let typeFlag = typeFlagX & 0x7FFFFFFF
  let shapeA = if typeFlag == typeFlagX { circle1 } else { circle2 }
  let shapeB = if typeFlag == typeFlagX { circle2 } else { circle1 }
  assert_true(typeFlag == shapeTypeValues.circle_circle.get_x())
  assert_true(shapeB.get_position() == circle1.get_position())
  assert_true(shapeA.get_position() == circle2.get_position())
}

///|
test "IShape::get_distance" {
  let circle1 = Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0)
  let circle2 = Circle::new(Vector3::new(3.0, 0.0, 0.0), 1.0)
  let distance = &IShape::get_distance(circle1, circle2)
  assert_true(distance == 1.0) // 3.0 - (1.0 + 1.0)
  let circle3 = Circle::new(Vector3::new(1.0, 0.0, 0.0), 1.0)
  let distance2 = &IShape::get_distance(circle1, circle3)
  assert_true(distance2 == 0.0) // 相交时距离为0
}

///|
impl IShape with set_size1(_ : Self, _ : Double) -> Unit {
  thrown("not implemented")
}
