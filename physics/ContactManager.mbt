///|
pub(all) struct ContactManager {
  priv collisions : Array[Collision]
  priv newContacts : Array[Contact]
  priv newContactIndexes : Array[Int]
  // 0: 未碰撞, 1: 离开, 2: 新增
  priv newCollisions : Array[Int]
  priv newCollisionIndexes : Array[Int]
  priv collisionsPool : Array[Collision]
  priv contactPool : Array[Contact]
  priv invalidCollisions : Map2[Int, Collision]
  priv invalidContacts : @hashset2.T[Contact]
  mut isUpdating : Bool
  priv mut recycleContactFn : (Contact) -> Unit
  priv mut recycleCollisionFn : (Int, Collision) -> Unit
  // priv addContactSingleFn : (&ICollider, &ICollider, Bool) -> Unit
}

///|
pub fn ContactManager::dispose(self : ContactManager) -> Unit {
  self.reset()
  self.newCollisions.clear()
  self.newContactIndexes.clear()
  self.recycleContactFn = @func.nothing1
  self.recycleCollisionFn = @func.nothing2
}

///|
pub fn ContactManager::new(colliderOidMax : Int) -> ContactManager {
  let size : Int = colliderOidMax
  let collisions : Array[Collision] = Array::make(size, invalidCollision)
  let contactPool : Array[Contact] = []
  let newCollisions : Array[Int] = Array::make(size, 0)
  let newContacts : Array[Contact] = Array::make(size, invalidContact)
  // fn addContactSingleFn(
  //   collider1 : &ICollider,
  //   collider2 : &ICollider,
  //   intersect : Bool
  // ) {

  // }

  let temp = ContactManager::{
    collisions,
    collisionsPool: [],
    newContacts,
    newContactIndexes: [],
    newCollisions,
    newCollisionIndexes: [],
    contactPool,
    invalidCollisions: Map2::new(),
    invalidContacts: @hashset2.new(),
    isUpdating: false,
    recycleContactFn: fn(_) {  },
    recycleCollisionFn: fn(_, _) {  },
    // addContactSingleFn,
  }
  temp..init()
  temp
}

///|
pub fn ContactManager::init(self : ContactManager) -> Unit {
  self.recycleContactFn = fn(contact : Contact) {
    contact.recycle(self.contactPool)
  }
  self.recycleCollisionFn = fn(_key : Int, collision : Collision) {
    collision.recycle(self.collisionsPool, self.contactPool)
  }
}

///|
pub fn ContactManager::reset(self : ContactManager) -> Unit {
  self.collisions.clear()
  self.collisionsPool.clear()
  self.newContacts.clear()
  // self.newCollisions.clear()
  self.newCollisionIndexes.clear()
  self.contactPool.clear()
  self.invalidCollisions.clear()
  self.invalidContacts.clear()
  self.isUpdating = false
}

///|
pub fn ContactManager::reset_contact_status(self : ContactManager) -> Unit {
  let collisions = self.collisions
  let collisionsPool = self.collisionsPool
  let contactPool = self.contactPool
  for _, collision in collisions {
    collision.recycle(collisionsPool, contactPool)
  }
  self.reset()
  // self.collisionsPool.clear()
  // self.newContacts.clear()
  // self.newCollisions.clear()
  // self.contactPool.clear()
  // self.invalidCollisions.clear()
  // self.invalidContacts.clear()
  // self.isUpdating = false
}

///|
// pub fn ContactManager::resort_collisions_id(
//   self : ContactManager,
//   colliders : Array[&ICollider]
// ) -> Unit {
//   let collisions = self.collisions
//   let newCollisions = self.newCollisions
//   newCollisions.clear()
//   let capacity = collisions.length()
//   if capacity <= colliders.length() {
//     println_error("colliders too much, overflow")
//   }
//   for collider in colliders {
//     newCollisions.push(collisions[collider.get_index()])
//     collisions[collider.get_index()] = invalidCollision
//   }
//   oidAcc.colliderIndexAcc = 0
//   for collision in newCollisions {
//     let index = oidAcc.alloc_collider_index()
//     collision.target.set_index(index)
//     collisions[index] = collision
//   }
//   newCollisions.clear()
// }

// ///|
// pub fn ContactManager::resort_new_collisions_id(self : ContactManager) -> Unit {
//   let newCollisions = self.newCollisions

// }

// ///|
// pub fn ContactManager::resort_id(
//   self : ContactManager,
//   colliders : Array[&ICollider]
// ) -> Unit {
//   if oidAcc.colliderIndexAcc >= self.collisions.length() {
//     self.resort_collisions_id(colliders)
//     self.resort_new_collisions_id()
//   }
// }

///|
fn ContactManager::add_contact_single(
  self : ContactManager,
  collider1 : &ICollider,
  collider2 : &ICollider,
  intersect : Bool
) -> Unit {
  let collider1Oid = collider1.oid()
  let collision = self.collisions[collider1Oid]
  if false == physical_equal(collision, invalidCollision) {
    let contact = collision.find_contact(collider2.oid())
    if false == physical_equal(contact, invalidContact) {
      contact.update_state(intersect)
      self.mark_new_collision(collider1Oid)
      self.mark_new_contact(contact)
    } else if intersect {
      let contactPool = self.contactPool
      let contact = if contactPool.length() > 0 {
        let contact = contactPool.unsafe_pop()
        contact.reset(collider1, collider2, intersect)
        contact
      } else {
        Contact::new(collider1, collider2, intersect)
      }
      collision.add_contact(contact)
      self.mark_new_collision(collider1Oid)
      self.mark_new_contact(contact)
    }
  }
}

///|
pub fn ContactManager::mark_new_collision(
  self : ContactManager,
  collider1Oid : Int
) -> Unit {
  // self.newCollisions.push(collision)
  let index = collider1Oid
  let newCollisions = self.newCollisions
  match newCollisions[index] {
    0 => {
      newCollisions[index] = 2
      self.newCollisionIndexes.push(index)
    }
    1 => newCollisions[index] = 2
    _ => ()
  }
}

///|
pub fn ContactManager::mark_new_contact(
  self : ContactManager,
  contact : Contact
) -> Unit {
  // self.newContacts.push(contact)
  if physical_equal(self.newContacts[contact.oid], invalidContact) {
    self.newContacts[contact.oid] = contact
    self.newContactIndexes.push(contact.oid)
  }
}

///|
pub fn ContactManager::unmark_new_collision(
  self : ContactManager,
  collider1Oid : Int
) -> Unit {
  self.newCollisions[collider1Oid] = 0
  @iter.remove_first(self.newCollisionIndexes, collider1Oid)
}

///|
pub fn ContactManager::unmark_new_contact(
  self : ContactManager,
  contact : Contact
) -> Unit {
  self.newContacts[contact.oid] = invalidContact
  @iter.remove_first(self.newContactIndexes, contact.oid)
}

///|
pub fn ContactManager::add_contact(
  self : ContactManager,
  collider1 : &ICollider,
  collider2 : &ICollider,
  intersect : ColliderIntersective
) -> Unit {
  self.add_contact_single(collider1, collider2, intersect.is_y1())
  self.add_contact_single(collider2, collider1, intersect.is_y2())
}

///|
pub fn ContactManager::update_leaved_contact(self : ContactManager) -> Unit {
  let newContactIndexes = self.newContactIndexes
  let len1 = newContactIndexes.length()
  if len1 > 0 {
    let newContacts = self.newContacts
    for i = len1 - 1; i >= 0; i = i - 1 {
      let index = newContactIndexes[i]
      let contact = newContacts[index]
      contact.drive_state()
    }
  }
}

///|
pub fn ContactManager::update_contact(self : ContactManager) -> Unit {
  self.invalidContacts.each(self.recycleContactFn)
  self.invalidContacts.clear()
  self.invalidCollisions.each(self.recycleCollisionFn)
  self.invalidCollisions.clear()
  let newContactIndexes = self.newContactIndexes
  let newContacts = self.newContacts
  {
    let len1 = newContactIndexes.length()
    for i = len1 - 1; i >= 0; i = i - 1 {
      let index = newContactIndexes[i]
      let contact = newContacts[index]
      // for contact in self.newContacts {
      if contact.is_valid() {
        contact.pend_state()
        if contact.state == ContactState::None {
          self.remove_contact(contact)
          newContacts[index] = invalidContact
          newContactIndexes.remove(i) |> ignore
        }
      }
    }
  }
  // self.newContacts.clear()
  // self.newCollisions.clear()
  let newCollisions = self.newCollisions
  let newCollisionIndexes = self.newCollisionIndexes
  let len2 = newCollisionIndexes.length()
  for i = len2 - 1; i >= 0; i = i - 1 {
    let index = newCollisionIndexes[i]
    match newCollisions[index] {
      1 => {
        newCollisions[index] = 0
        newCollisionIndexes.remove(i) |> ignore
      }
      2 => newCollisions[index] = 1
      _ => thrown("invalid collision state: \{newCollisions[index]}")
    }
  }
}

///|
pub fn ContactManager::get_collision(
  self : ContactManager,
  target : &ICollider
) -> Collision {
  self.collisions[target.oid()]
}

///|
pub fn ContactManager::add_collider(
  self : ContactManager,
  target : &ICollider
) -> Unit {
  let index = target.oid()
  let collisions = self.collisions
  if physical_equal(invalidCollision, collisions[index]) {
    let collision = match self.collisionsPool.pop() {
      Some(collision1) => {
        collision1.reset(target)
        collision1
      }
      None => Collision::new(target)
    }
    collisions[index] = collision
  }
}

///|
pub fn ContactManager::remove_contact(
  self : ContactManager,
  contact : Contact
) -> Unit {
  let collider1 = contact.collider1
  let collider2 = contact.collider2
  let collision = self.collisions[collider1.oid()]
  if false == physical_equal(collision, invalidCollision) {
    // contacts 存被动碰撞体
    // let contact = collision.find_contact(collider2.oid())
    if physical_equal(contact, invalidContact) == false {
      collision.remove_contact(collider2.oid())
      contact.recycle(self.contactPool)
    }
  }
}

///|
pub fn ContactManager::remove_collider(
  self : ContactManager,
  collider : &ICollider
) -> Unit {
  let colliderOid1 = collider.oid()
  let collisions = self.collisions
  let collision = collisions[colliderOid1]
  if false == physical_equal(collision, invalidCollision) {
    // remove relations
    let invalidContacts = self.invalidContacts
    let isUpdating = self.isUpdating
    for collider2 in collision.contacts {
      let collision2 = collisions[collider2.oid]
      if false == physical_equal(collision2, invalidCollision) {
        let contact = collision2.find_contact(colliderOid1)
        if physical_equal(contact, invalidContact) == false {
          collision2.remove_contact(colliderOid1)
          self.unmark_new_contact(contact)
          if isUpdating {
            invalidContacts.add(contact)
          } else {
            contact.recycle(self.contactPool)
          }
        }
      }
    }
    // println("remove collider: \{colliderOid0}, \{collisions.size()}")
    collisions[colliderOid1] = invalidCollision
    self.unmark_new_collision(colliderOid1)
    if isUpdating {
      self.invalidCollisions[colliderOid1] = collision
    } else {
      collision.recycle(self.collisionsPool, self.contactPool)
    }
  }
}

///|
pub fn ContactManager::contains_contact(
  self : ContactManager,
  collider1 : &ICollider,
  collider2 : &ICollider
) -> Bool {
  let collision = self.collisions[collider1.oid()]
  if physical_equal(collision, invalidCollision) {
    false
  } else {
    collision.contains_contact(collider2.oid())
  }
}

///|
pub fn ContactManager::contains_the_updater(
  self : ContactManager,
  collider : &ICollider
) -> Bool {
  return physical_equal(self.collisions[collider.oid()], invalidCollision) ==
    false
}

///|
pub fn ContactManager::check_mm(_self : ContactManager) -> Unit {
  // let count = 8
  // if self.collisions.size() > count {
  //   println("invalid collisions size: \{self.collisions.size()}>\{count}")
  // }
  // if self.collisionsPool.length() > count {
  //   println(
  //     "invalid collisionsPool size: \{self.collisionsPool.length()}>\{count}",
  //   )
  // }
  // if self.contactPool.length() > count {
  //   println("invalid contactPool size: \{self.contactPool.length()}>\{count}")
  // }
  // if self.newCollisions.size() > count {
  //   println("invalid newCollisions size: \{self.newCollisions.size()}>\{count}")
  // }
  // if self.newContacts.length() > count {
  //   println("invalid newContacts size: \{self.newContacts.length()}>\{count}")
  // }
  // let mut countA = 0
  // countA += self.collisions.size()
  // for collision in self.collisions.values() {
  //   countA += collision.contacts.size()
  //   collision.check_mm()
  // }
  // countA += self.collisionsPool.length()
  // for collision in self.collisionsPool {
  //   countA += collision.contacts.size()
  //   collision.check_mm()
  // }
  // countA += self.contactPool.length()
  // countA += self.newCollisions.size()
  // countA += self.newContacts.length()
  // countA += self.invalidContacts.size()
  // countA += self.invalidCollisions.size()
  // if countA > 20 {
  //   println(
  //     "countA: \{countA}, \{self.collisions.size()}, \{self.collisionsPool.length()} \{self.contactPool.length()}, \{self.newCollisions.size()}, \{self.newContacts.length()}, \{self.invalidContacts.size()}, \{self.invalidCollisions.size()}",
  //   )
  // }
}
