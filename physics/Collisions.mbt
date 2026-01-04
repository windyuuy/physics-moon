///|
pub(all) struct Collision {
  oid : Int
  mut target : &ICollider
  //触发碰撞的碰撞体, 被动碰撞体
  contacts : Array[Contact]
  priv excludeExitContactsIter : Iter[Contact]
  priv getEnterContactsIter : Iter[Contact]
}

///|
pub fn Collision::new(target : &ICollider) -> Collision {
  let contacts = Array::new()
  let contactValues = contacts.iter()
  Collision::{
    oid: oidAcc.alloc_collision_oid(),
    target,
    contacts,
    excludeExitContactsIter: contactValues.filter(fn(coll) {
      coll.is_exit() == false
    }),
    getEnterContactsIter: contactValues.filter(fn(coll) { coll.is_enter() }),
  }
}

///|
pub let invalidCollision : Collision = Collision::new(invalidCollider)

///|
pub fn Collision::reset(self : Collision, target : &ICollider) -> Unit {
  self.target = target
  self.contacts.clear()
}

///|
pub fn Collision::recycle(
  self : Collision,
  collisionsPool : Array[Collision],
  contactPool : Array[Contact]
) -> Unit {
  for contact in self.contacts {
    contact.recycle(contactPool)
  }
  // self.contacts.each(fn(_, contact) { contact.recycle(contactPool) })
  // remove target
  self.reset(invalidCollider)
  // recycle
  collisionsPool.push(self)
}

///|
pub fn Collision::get_enter_contacts(self : Collision) -> Iter[Contact] {
  self.getEnterContactsIter
}

///|
pub fn Collision::exclude_exit_contacts(self : Collision) -> Iter[Contact] {
  self.excludeExitContactsIter
}

///|
pub fn Collision::check_mm(self : Collision) -> Unit {
  // ignore(self)
  let count = 4
  if self.contacts.length() > count {
    println("invalid contacts size: \{self.contacts.length()}>\{count}")
  }
}

///|
pub fn Collision::add_contact(self : Collision, contact : Contact) -> Unit {
  self.contacts.push(contact)
}

///|
pub fn Collision::find_contact(self : Collision, colliderOid : Int) -> Contact {
  let contacts = self.contacts
  for contact in contacts {
    if contact.collider2Oid == colliderOid {
      return contact
    }
  }
  return invalidContact
}

///|
pub fn Collision::remove_contact(self : Collision, oid : Int) -> Unit {
  let contacts = self.contacts
  let len = contacts.length()
  for i in 0..<len {
    if contacts[i].collider2.oid() == oid {
      contacts.remove(i) |> ignore
      break
    }
  }
}

///|
pub fn Collision::contains_contact(self : Collision, oid : Int) -> Bool {
  let contacts = self.contacts
  let len = contacts.length()
  for i in 0..<len {
    if contacts[i].collider2.oid() == oid {
      return true
    }
  }
  return false
}
