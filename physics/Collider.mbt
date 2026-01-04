///|
pub(all) struct Collider {
  priv oid : Int
  priv mut flag : Int
  priv shape : &IShape
  priv mut isActive : Bool
  priv mut test_intersective_func : ((Collider, &ICollider) -> ColliderIntersective)?
  mut onCollision : (Collider, Collision) -> Unit
}

///|
pub fn Collider::new(shape : &IShape, tag : Int) -> Collider {
  Collider::{
    flag: tag,
    shape,
    oid: oidAcc.alloc_collider_oid(),
    isActive: true,
    test_intersective_func: None,
    onCollision: @func.nothing2,
  }
}

///|
pub fn Collider::set_flag(self : Collider, flag : Int) -> Unit {
  self.flag = flag
}

///|
impl ICollider for Collider with get_flag(self : Collider) -> Int {
  self.flag
}

///|
impl ICollider for Collider with get_shape(self : Collider) -> &IShape {
  self.shape
}

///|
impl IOid for Collider with oid(self : Collider) -> Int {
  self.oid
}

///|
impl ICollider for Collider with is_active(self : Collider) -> Bool {
  self.isActive
}

///|
pub fn Collider::set_active(self : Collider, active : Bool) -> Unit {
  self.isActive = active
}

///|
impl ICollider for Collider with test_intersective(
  self : Collider,
  target : &ICollider
) -> ColliderIntersective {
  match self.test_intersective_func {
    None => ColliderIntersective::Unset
    Some(call) => call(self, target)
  }
}

///|
pub fn Collider::set_test_intersective(
  self : Collider,
  test_intersective_func : (Collider, &ICollider) -> ColliderIntersective
) -> Unit {
  self.test_intersective_func = Some(test_intersective_func)
}

///|
impl ICollider for Collider with update(self : Collider, collisions : Collision) -> Unit {
  (self.onCollision)(self, collisions)
}

///|
impl Hash for Collider with hash(self : Collider) -> Int {
  self.oid()
}

///|
impl Hash for Collider with hash_combine(self : Collider, hasher : Hasher) -> Unit {
  hasher.combine_int(self.oid())
}
