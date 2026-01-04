///| 2D 物理世界
/// 
/// TODO: 优化碰撞检测性能
pub(all) struct World2D {
  /// 碰撞体
  colliders : Array[&ICollider]
  // updaters : Array[&ICollider]
  /// 触发标志
  priv triggerFlags : Map2[Int, Bool]
  priv updatings : Map2[Int, Int]
  contactManager : ContactManager
  // priv mut onCollision : ((&ICollider, Collision) -> Unit)?
  // priv mut newCollisionsIterFn : (&ICollider) -> Unit
  priv scanner : MultiBoxScanner
  priv mut foreachCollider : (&ICollider, &ICollider) -> Unit
}

///|
pub fn World2D::new(
  sceneSize~ : Vector3 = Vector3::new(5000, 5000, 1),
) -> World2D {
  let colliderOidMax = 1024 * 512
  let contactManager = ContactManager::new(colliderOidMax)
  let scanner = MultiBoxScanner::new(sceneSize, 160.0, colliderOidMax)
  let world = World2D::{
    colliders: Array::new(),
    // updaters: Array::new(),
    triggerFlags: Map2::new(),
    updatings: Map2::new(),
    contactManager,
    // onCollision: None,
    // newCollisionsIterFn: @func.nothing1,
    scanner,
    foreachCollider: @func.nothing2,
  }
  world.init()
  world
}

///|
pub fn World2D::init(self : World2D) -> Unit {
  let contactManager = self.contactManager
  self.foreachCollider = fn(collider1, collider2) {
    let intersect = self.intersect(collider1, collider2, false)
    contactManager.add_contact(collider1, collider2, intersect)
  }
  // self.newCollisionsIterFn = fn(collider : &ICollider) {
  //   // ignore(k)
  //   if self.contactManager.contains_the_updater(collider) {
  //     let collision = self.contactManager.get_collision(collider)
  //     if physical_equal(collision, invalidCollision) == false {
  //       collider.update(collision)
  //       match self.onCollision {
  //         None => ()
  //         Some(onCollision) => onCollision(collider, collision)
  //       }
  //     }
  //   }
  // }
}

///|
pub fn World2D::reset(self : World2D) -> Unit {
  self.colliders.clear()
  self.triggerFlags.clear()
  self.updatings.clear()
  self.contactManager.reset()
  // self.onCollision = None
}

///|
pub fn World2D::dispose(self : World2D) -> Unit {
  self.reset()
  // self.newCollisionsIterFn = @func.nothing1
  self.contactManager.dispose()
}

///|
pub fn World2D::set_on_collision(
  _self : World2D,
  _onCollision : (&ICollider, Collision) -> Unit,
) -> Unit {
  // self.onCollision = Some(onCollision)
}

///|
pub fn World2D::register_trigger_flag(
  self : World2D,
  tag1 : Int,
  tag2 : Int,
) -> Unit {
  let composeTag1 = collider_compose(tag1, tag2)
  // println("composeTag1: \{composeTag1}")
  Map2::set(self.triggerFlags, composeTag1, true)
  // println("Map::set done")
}

///|
pub fn World2D::unregister_trigger_flag(
  self : World2D,
  tag1 : Int,
  tag2 : Int,
) -> Unit {
  let composeTag1 = collider_compose(tag1, tag2)
  Map2::remove(self.triggerFlags, composeTag1)
}

///|
pub fn World2D::register_trigger_flag_batch(
  self : World2D,
  tags : Map2[Int, Int],
) -> Unit {
  for item in tags {
    self.register_trigger_flag(item.0, item.1)
  }
}

///|
pub fn World2D::get_scanner(self : World2D) -> BoxScanner {
  self.scanner.scanner1
}

///| impl add ICollider
pub fn World2D::add_collider(self : World2D, collider : &ICollider) -> Unit {
  // TODO: 将大的排前有利于优化性能
  self.colliders.push(collider)
}

///| impl remove ICollider
pub fn World2D::remove_collider(self : World2D, collider : &ICollider) -> Unit {
  @iter.remove_by_oid(self.colliders, collider)
}

///| impl intersect
/// 返回 Y1: collider1 与 collider2 相交
/// 返回 Y2: collider2 与 collider1 相交
/// 返回 Both: 两边相交
/// 返回 No: 两边不相交
/// 返回 Unset: 默认相交设置
/// 不会检查是否在世界中
pub fn World2D::intersect(
  self : World2D,
  collider1 : &ICollider,
  collider2 : &ICollider,
  single : Bool,
) -> ColliderIntersective {
  if not(collider1.is_active() && collider2.is_active()) {
    return ColliderIntersective::No
  }
  if false == collider1.intersect(collider2) {
    return ColliderIntersective::No
  }
  let intersective1 = collider1.test_intersective(collider2).to_int() & 0b101
  let intersective2 = collider2.test_intersective(collider1).to_int() & 0b101
  let intersectiveI = intersective1 | intersective2
  let intersective = if intersectiveI < 4 {
    ColliderIntersective::from_int(
      intersective1 |
      (match intersective2 {
        0 => 0
        1 => 2
        _ => thrown("invalid intersective2-1: \{intersective2}")
      }),
    )
  } else {
    let composeTag = collider_compose(
      collider1.get_flag(),
      collider2.get_flag(),
    )
    let isTrigger = self.triggerFlags.get(composeTag)
    let v1 = if intersective1 == 4 {
      match isTrigger {
        None => 0
        Some(false) => 0
        Some(true) => 1
      }
    } else {
      intersective1
    }
    let v2 = if intersective2 == 4 {
      match isTrigger {
        None => 0
        Some(false) => 0
        Some(true) => 2
      }
    } else if intersective2 == 1 {
      ColliderIntersective::Y2.to_int()
    } else {
      intersective2
    }
    ColliderIntersective::from_int(v1 | v2)
  }
  if (single && intersective.is_y1()) ||
    intersective != ColliderIntersective::No {
    // match collider1.intersect(collider2) {
    //   true => intersective
    //   false => ColliderIntersective::No
    // }
    intersective
  } else {
    ColliderIntersective::No
  }
}

///|
pub fn World2D::find_intersects(
  self : World2D,
  collider : &ICollider,
) -> Iter[&ICollider] {
  self.colliders
  .iter()
  .filter(fn(collider1) {
    collider != collider1 &&
    self.intersect(collider, collider1, true) == ColliderIntersective::Y1
  })
}

///|
pub fn World2D::find_nearest_intersect(
  self : World2D,
  collider : &ICollider,
) -> &ICollider? {
  let collider = @iter.min_by(self.find_intersects(collider), fn(collider1) {
    collider.get_distance(collider1)
  })
  collider
}

///|
pub fn World2D::update(self : World2D) -> Unit {
  let contactManager = self.contactManager
  contactManager.isUpdating = true
  let updatings = self.updatings
  if updatings.size() > 0 {
    // let colliders = self.colliders
    // let len = colliders.length()
    // for i in 0..<len {
    //   let collider1 = colliders[i]
    //   if not(updatings.contains(collider1.oid())) {
    //     continue
    //   }
    //   for j in (i + 1)..<len {
    //     let collider2 = colliders[j]
    //     if contactManager.contains_the_updater(collider1) ||
    //       contactManager.contains_the_updater(collider2) {
    //       let intersect = self.intersect(collider1, collider2, false)
    //       contactManager.add_contact(collider1, collider2, intersect)
    //     }
    //   }
    // }
    // self.scanner.scan_marks(self.updaters)
    self.scanner.foreach_collisions(self.colliders, self.foreachCollider)
    // println("collidercount: \{self.i}")
    // self.scanner.clear()
    contactManager.update_leaved_contact()
    self.emit_collider_updates()
    contactManager.update_contact()
  }
  contactManager.isUpdating = false
}

///|
pub fn World2D::emit_collider_updates(self : World2D) -> Unit {
  let contactManager = self.contactManager
  let collisionIndexes = contactManager.newCollisionIndexes
  if collisionIndexes.length() > 0 {
    let newCollisions = contactManager.collisions
    for index in collisionIndexes {
      let collision = newCollisions[index]
      // if physical_equal(collision, invalidCollision) == false {
      let collider = collision.target
      if false == physical_equal(collider, invalidCollider) {
        collider.update(collision)
      } else {
        println_error("emit_collider_updates: invalid collider")
      }
      // match self.onCollision {
      //   None => ()
      //   Some(onCollision) => onCollision(collider, collision)
      // }
      // }
    }
  }
}

///|
pub fn World2D::reset_contact_status(self : World2D) -> Unit {
  self.contactManager.reset_contact_status()
}

///|
pub fn World2D::add_update(self : World2D, collider : &ICollider) -> Unit {
  let updatings = self.updatings
  let colliderOid = collider.oid()
  match updatings.get(colliderOid) {
    Some(count) => updatings[colliderOid] = count + 1
    None => {
      // println("add updating")
      updatings[colliderOid] = 1
      self.contactManager.add_collider(collider)
    }
  }
}

///|
pub fn World2D::remove_update(self : World2D, collider : &ICollider) -> Unit {
  let updatings = self.updatings
  let colliderOid = collider.oid()
  match updatings.get(colliderOid) {
    Some(count) =>
      if count <= 1 {
        updatings.remove(colliderOid)
        self.contactManager.remove_collider(collider)
        // println("remove updating: \{colliderOid}, \{count}, \{c1}->\{c2}")
      } else {
        updatings[colliderOid] = count - 1
      }
    None => ()
  }
}

///|
pub fn World2D::check_mm(self : World2D) -> Unit {
  // ignore(self)
  let count = 10
  if self.colliders.length() >= count {
    println("skills length invalid: \{self.colliders.length()}>count")
  }
  if self.updatings.size() >= count {
    println("updatings length invalid: \{self.updatings.size()}>count")
  }
  self.contactManager.check_mm()
}

///|
pub fn World2D::update_collider(
  _self : World2D,
  _collider : &ICollider,
) -> Unit {
  // 调整碰撞体排序, 有利于性能优化
}
