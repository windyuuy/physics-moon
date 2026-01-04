///|
test "World2D::update" {
  let world = World2D::new()
  let collider1 = Collider::new(
    Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0),
    1,
  )
  let collider2 = Collider::new(
    Circle::new(Vector3::new(1.0, 0.0, 0.0), 1.5),
    2,
  )
  world.add_collider(collider1)
  world.add_collider(collider2)
  world.register_trigger_flag_batch(Map2::from_array([(1, 1)]))
  world.add_update(collider1)
  world.add_update(collider2)
  assert_true(world.intersect(collider1, collider2, true).is_yes())
  // case 1
  collider1.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y1
  })
  collider2.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y1
  })
  let mut count = 0
  // world.set_on_collision(fn(collider, contact) { count += 1 })
  collider1.onCollision = fn(collider, contact) {
    ignore(collider)
    ignore(contact)
    count += 1
  }
  collider2.onCollision = fn(collider, contact) {
    ignore(collider)
    ignore(contact)
    count += 1
  }
  world.update()
  assert_eq(count, 2)
  // case 2
  world.reset_contact_status()
  count = 0
  collider1.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Both
  })
  collider2.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Both
  })
  world.update()
  assert_eq(count, 2)
  // case 3
  world.reset_contact_status()
  count = 0
  collider1.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y2
  })
  collider2.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Both
  })
  world.update()
  assert_eq(count, 1)
  // case 4
  world.reset_contact_status()
  count = 0
  collider1.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y2
  })
  collider2.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y1
  })
  world.update()
  assert_eq(count, 1)
  // case 5
  world.reset_contact_status()
  count = 0
  collider1.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y2
  })
  collider2.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::No
  })
  world.update()
  assert_eq(count, 0)
  // case 6
  world.reset_contact_status()
  count = 0
  collider1.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::No
  })
  collider2.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y2
  })
  world.update()
  assert_eq(count, 0)
  // case 7
  world.reset_contact_status()
  count = 0
  collider1.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::No
  })
  collider2.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y1
  })
  world.update()
  assert_eq(count, 1)
  // case 8
  world.reset_contact_status()
  count = 0
  collider1.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Both
  })
  collider2.set_test_intersective(fn(collider1, collider2) {
    ignore(collider1)
    ignore(collider2)
    ColliderIntersective::Y2
  })
  world.update()
  assert_eq(count, 1)
}
