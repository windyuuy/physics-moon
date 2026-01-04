///|
struct InvalidCollider {}

///|
pub fn InvalidCollider::new() -> InvalidCollider {
  InvalidCollider::{  }
}

///|
impl IOid for InvalidCollider with oid(_ : InvalidCollider) {
  // ignore(self)
  // thrown("not implement")
  -1
}

///|
impl ICollider for InvalidCollider with get_flag(self : InvalidCollider) -> Int {
  ignore(self)
  thrown("not implement")
}

///|
impl ICollider for InvalidCollider with get_shape(_ : InvalidCollider) -> &IShape {
  thrown("not implement")
}

///|
impl ICollider for InvalidCollider with get_position(_ : InvalidCollider) -> Vector3 {
  thrown("not implement")
}

///|
impl ICollider for InvalidCollider with is_active(_ : InvalidCollider) -> Bool {
  thrown("not implement")
}

///|
impl ICollider for InvalidCollider with update(
  _ : InvalidCollider,
  _ : Collision
) -> Unit {
  thrown("not implement")
}

///|
impl ICollider for InvalidCollider with add_updater(
  _ : InvalidCollider,
  _ : (Collision) -> Unit
) -> Unit {
  thrown("not implement")
}

///|
impl ICollider for InvalidCollider with remove_updater(
  _ : InvalidCollider,
  _ : (Collision) -> Unit
) -> Unit {
  thrown("not implement")
}

///|
impl Hash for InvalidCollider with hash(self : InvalidCollider) -> Int {
  self.oid()
}

///|
impl Hash for InvalidCollider with hash_combine(self : InvalidCollider, hasher : Hasher) -> Unit {
  hasher.combine_int(self.oid())
}

///|
impl ICollider for InvalidCollider with update_bind(_ : InvalidCollider) -> Unit {
}

///|
pub let invalidCollider : &ICollider = InvalidCollider::new()
