///|
pub(all) struct ColliderTag {
  default : Int
}

///|
pub let colliderTag : ColliderTag = ColliderTag::{ default: 0x00000001 }

///|
pub(open) trait ICollider: IOid + Hash {
  get_flag(Self) -> Int = _
  get_shape(Self) -> &IShape = _
  get_position(Self) -> Vector3 = _
  //| 是否可被碰撞
  is_active(Self) -> Bool
  //| 是否可主动碰撞(需要先active)
  is_positive(Self)->Bool = _
  update(Self, Collision) -> Unit = _
  add_updater(Self, (Collision) -> Unit) -> Unit = _
  remove_updater(Self, (Collision) -> Unit) -> Unit = _
  update_bind(Self) -> Unit = _
  test_intersective(Self, &ICollider) -> ColliderIntersective = _
  get_aabb(Self, Double, AABBI) -> Unit = _
  get_ipos(Self, Double, Vector2I) -> Unit = _
  get_shapes_flag(Self, &ICollider) -> Int = _
  intersect(Self, &ICollider) -> Bool = _
  get_circle(Self) -> Circle = _
  get_index(Self) -> Int = _
  set_index(Self, Int) -> Unit = _
}

///|
impl ICollider with get_flag(_ : Self) -> Int {
  return colliderTag.default
}

///|
impl ICollider with is_positive(_ : Self) -> Bool {
  return true
}

///|
impl ICollider with get_index(_ : Self) -> Int {
  thrown("not implement")
}

///|
impl ICollider with set_index(_ : Self, _index : Int) -> Unit {
  thrown("not implement")
}

///|
impl ICollider with get_shape(_ : Self) -> &IShape {
  panic()
}

///|
impl ICollider with get_position(self : Self) -> Vector3 {
  self.get_shape().get_position()
}

///|
impl ITransform for &ICollider with get_position(self : &ICollider) -> Vector3 {
  self.get_position()
}

///|
impl Eq for &ICollider with op_equal(self : &ICollider, other : &ICollider) -> Bool {
  self.oid() == other.oid()
}

///|
impl ICollider with update(_ : Self, _ : Collision) -> Unit {

}

///|
impl ICollider with get_shapes_flag(self : Self, other : &ICollider) -> Int {
  self.get_shape().get_shapes_flag(other.get_shape())
}

///|
pub fn &ICollider::get_distance(self : &ICollider, other : &ICollider) -> FP {
  self.get_shape().get_distance(other.get_shape())
}

///|
impl ICollider with get_circle(self : Self) -> Circle {
  self.get_shape().as_circle()
}

///| 两个碰撞体相交
pub fn &ICollider::intersect1(self : &ICollider, other : &ICollider) -> Bool {
  let typeFlagX = self.get_shapes_flag(other)
  let typeFlag = typeFlagX & 0x7FFFFFFF
  let colliderA = if typeFlag == typeFlagX { self } else { other }
  let colliderB = if typeFlag == typeFlagX { other } else { self }
  let shapeA = colliderA.get_shape()
  let shapeB = colliderB.get_shape()
  if typeFlag == shapeTypeValues.circle_circle.get_x() {
    Math2D::intersect_circle_circle(shapeA.as_circle(), shapeB.as_circle())
  } else if typeFlag == shapeTypeValues.circle_lineSeg.get_x() {
    Math2D::intersect_circle_lineSeg(shapeA.as_circle(), shapeB.as_lineSeg())
  } else {
    false
  }
}

///| 两个碰撞体相交
impl ICollider with intersect(self : Self, other : &ICollider) -> Bool {
  &ICollider::intersect1(self, other)
}

///|
pub fn collider_compose(tag1 : Int, tag2 : Int) -> Int {
  if tag1 > tag2 {
    (tag2 << 16) + tag1
  } else {
    (tag1 << 16) + tag2
  }
}

///|
impl ICollider with add_updater(_ : Self, _ : (Collision) -> Unit) -> Unit {

}

///|
impl ICollider with remove_updater(_ : Self, _ : (Collision) -> Unit) -> Unit {

}

///|
impl ICollider with update_bind(_ : Self) -> Unit {

}

///|
impl ICollider with test_intersective(_ : Self, _ : &ICollider) -> ColliderIntersective {
  ColliderIntersective::Unset
}

///|
impl ICollider with get_aabb(self : Self, scale : Double, aabb : AABBI) -> Unit {
  self.get_shape().get_aabbi(scale, aabb)
}

///|
impl ICollider with get_ipos(self : Self, scale : Double, posI : Vector2I) -> Unit {
  let pos = self.get_position()
  posI.x = @math.floor(pos.x * scale).to_int()
  posI.y = @math.floor(pos.y * scale).to_int()
}
