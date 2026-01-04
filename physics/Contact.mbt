///|物理接触状态
pub(all) enum ContactState {
  /// 未碰撞
  None
  /// 进入碰撞
  Enter
  /// 保持碰撞
  Stay
  /// 离开碰撞
  Exit
  Pending
} derive(Eq)

///|
pub let invalidContact : Contact = Contact::new(
  invalidCollider, invalidCollider, false,
)

///|
pub(all) struct Contact {
  oid : Int
  /// 触发碰撞的碰撞体
  mut collider1 : &ICollider
  /// 被动碰撞体
  mut collider2 : &ICollider
  mut state : ContactState
  mut collider2Oid : Int
}

///|
pub fn Contact::new(
  collider1 : &ICollider,
  collider2 : &ICollider,
  intersect : Bool
) -> Contact {
  Contact::{
    oid: oidAcc.alloc_contact_oid(),
    collider1,
    collider2,
    collider2Oid: collider2.oid(),
    state: if intersect {
      ContactState::Enter
    } else {
      ContactState::None
    },
  }
}

///|
pub fn Contact::reset(
  self : Contact,
  collider1 : &ICollider,
  collider2 : &ICollider,
  intersect : Bool
) -> Unit {
  self.collider1 = collider1
  self.collider2 = collider2
  self.collider2Oid = collider2.oid()
  self.state = if intersect { ContactState::Enter } else { ContactState::None }
}

///|
pub fn Contact::recycle(self : Contact, contactPool : Array[Contact]) -> Unit {
  self.reset(invalidCollider, invalidCollider, false)
  contactPool.push(self)
}

///|
pub fn Contact::update_state(self : Contact, intersect : Bool) -> Unit {
  match self.state {
    ContactState::None => if intersect { self.state = ContactState::Enter }
    ContactState::Stay => if not(intersect) { self.state = ContactState::Exit }
    ContactState::Pending =>
      if intersect {
        self.state = ContactState::Stay
      } else {
        self.state = ContactState::Exit
      }
    ContactState::Exit => if intersect { thrown("invalid state") }
    _ => ()
  }
}

///|
pub fn Contact::drive_state(self : Contact) -> Unit {
  match self.state {
    ContactState::Pending => self.state = ContactState::Exit
    _ => ()
  }
}

///|
pub fn Contact::pend_state(self : Contact) -> Unit {
  match self.state {
    ContactState::Enter => self.state = ContactState::Pending
    ContactState::Stay => self.state = ContactState::Pending
    ContactState::Exit => self.state = ContactState::None
    _ => ()
  }
}

///|
pub fn Contact::is_enter(self : Contact) -> Bool {
  return self.state == ContactState::Enter
}

///|
pub fn Contact::is_exit(self : Contact) -> Bool {
  return self.state == ContactState::Exit
}

///|
pub fn Contact::get_another(
  self : Contact,
  collider : &ICollider
) -> &ICollider {
  let collider1 = self.collider1
  let collider2 = self.collider2
  if physical_equal(collider1, collider) {
    collider2
  } else if physical_equal(collider2, collider) {
    collider1
  } else {
    thrown("invalid collider")
  }
}

///|
pub fn Contact::get_relative(self : Contact) -> &ICollider {
  self.collider2
}

///|
pub fn Contact::is_valid(self : Contact) -> Bool {
  return not(physical_equal(invalidCollider, self.collider1))
}

///|
pub impl Eq for Contact with op_equal(self : Contact, target : Contact) -> Bool {
  self.oid == target.oid
}

///|
pub impl Hash for Contact with hash_combine(self : Contact, hasher : Hasher) -> Unit {
  hasher.combine_int(self.oid)
}

///|
pub impl Hash for Contact with hash(self : Contact) -> Int {
  self.oid
}
