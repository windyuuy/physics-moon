///|
pub(all) struct OidAcc {
  priv mut colliderOidAcc : Int
  mut colliderIndexAcc : Int
  priv mut contactOidAcc : Int
  mut collisionOidAcc : Int
}

///|
let oidAcc : OidAcc = OidAcc::{
  colliderOidAcc: 0,
  colliderIndexAcc: 0,
  contactOidAcc: 0,
  collisionOidAcc: 0,
}

///|
pub fn OidAcc::alloc_collider_oid(self : OidAcc) -> Int {
  let id = self.colliderOidAcc
  self.colliderOidAcc = id + 1
  id
}

///|
pub fn OidAcc::alloc_collider_index(self : OidAcc) -> Int {
  let id = self.colliderOidAcc
  self.colliderOidAcc = id + 1
  id
}

///|
pub fn OidAcc::alloc_contact_oid(self : OidAcc) -> Int {
  let id = self.contactOidAcc
  self.contactOidAcc = id + 1
  id
}

///|
pub fn OidAcc::alloc_collision_oid(self : OidAcc) -> Int {
  let id = self.collisionOidAcc
  self.collisionOidAcc = id + 1
  id
}
