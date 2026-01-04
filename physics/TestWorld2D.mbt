///|
test "World2D" {
  let world = World2D::new()
  let collider1 = Collider::new(
    Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0),
    1,
  )
  let collider2 = Collider::new(
    Circle::new(Vector3::new(1.0, 0.0, 0.0), 1.0),
    1,
  )
  let collider3 = Collider::new(
    Circle::new(Vector3::new(3.0, 0.0, 0.0), 1.0),
    1,
  )
  let collider4 = Collider::new(
    Circle::new(Vector3::new(3.001, 0.0, 0.0), 1.0),
    1,
  )
  world.add_collider(collider1)
  world.add_collider(collider2)
  world.add_collider(collider3)
  world.add_collider(collider4)
  assert_true(false == world.intersect(collider1, collider2, true).is_yes())
  world.register_trigger_flag_batch(Map2::from_array([(1, 1)]))
  assert_true(world.intersect(collider1, collider2, true).is_yes())
  assert_true(world.intersect(collider2, collider3, true).is_yes())
  assert_true(false == world.intersect(collider2, collider4, true).is_yes())
  let intersects2 = world.find_intersects(collider2).to_array()
  assert_true(intersects2.contains(collider1))
  assert_true(intersects2.contains(collider3))
  assert_true(false == intersects2.contains(collider4))
  let collider5 = Collider::new(
    Circle::new(Vector3::new(1.1, 0.0, 0.0), 1.0),
    2,
  )
  world.add_collider(collider5)
  let intersects5 = world.find_intersects(collider5).to_array()
  assert_true(intersects5.length() == 0)
}

///|
test "World2D::new" {
  let world = World2D::new()
  assert_true(world.colliders.length() == 0)
}

///|
test "World2D::add_collider" {
  let world = World2D::new()
  let collider = Collider::new(Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0), 1)
  world.add_collider(collider)
  assert_true(world.colliders.length() == 1)
  assert_true(world.colliders.contains(collider))
}

///|
test "World2D::register_trigger_flag_batch" {
  let world = World2D::new()
  world.register_trigger_flag_batch(Map2::from_array([(1, 1), (2, 2)]))
  let collider1 = Collider::new(
    Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0),
    1,
  )
  let collider2 = Collider::new(
    Circle::new(Vector3::new(0.5, 0.0, 0.0), 1.0),
    2,
  )
  world.add_collider(collider1)
  world.add_collider(collider2)
  assert_true(not(world.intersect(collider1, collider2, true).is_yes()))
}

///|
test "World2D::register_trigger_flag_batch" {
  let world = World2D::new()
  world.register_trigger_flag_batch(Map2::from_array([(1, 1), (1, 2)]))
  let collider1 = Collider::new(
    Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0),
    1,
  )
  let collider2 = Collider::new(
    Circle::new(Vector3::new(0.5, 0.0, 0.0), 1.0),
    2,
  )
  world.add_collider(collider1)
  world.add_collider(collider2)
  assert_true(world.intersect(collider1, collider2, true).is_yes())
}

///|
test "World2D::find_intersects_empty" {
  let world = World2D::new()
  let collider = Collider::new(Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0), 1)
  world.add_collider(collider)
  let intersects = world.find_intersects(collider).to_array()
  assert_true(intersects.length() == 0)
}

///|
test "World2D::find_intersects_multiple" {
  let world = World2D::new()
  world.register_trigger_flag_batch(Map2::from_array([(1, 1)]))
  let collider1 = Collider::new(
    Circle::new(Vector3::new(0.0, 0.0, 0.0), 2.0),
    1,
  )
  let collider2 = Collider::new(
    Circle::new(Vector3::new(1.0, 0.0, 0.0), 2.0),
    1,
  )
  let collider3 = Collider::new(
    Circle::new(Vector3::new(2.0, 0.0, 0.0), 2.0),
    1,
  )
  world.add_collider(collider1)
  world.add_collider(collider2)
  world.add_collider(collider3)
  let intersects = world.find_intersects(collider2).to_array()
  assert_true(intersects.length() == 2)
  assert_true(intersects.contains(collider1))
  assert_true(intersects.contains(collider3))
}

///|
test "World2D::find_nearest_intersect" {
  let world = World2D::new()
  world.register_trigger_flag_batch(Map2::from_array([(1, 1)]))
  let collider1 = Collider::new(
    Circle::new(Vector3::new(0.0, 0.0, 0.0), 1.0),
    1,
  )
  let collider2 = Collider::new(
    Circle::new(Vector3::new(1.0, 0.0, 0.0), 1.0),
    1,
  )
  let collider3 = Collider::new(
    Circle::new(Vector3::new(2.0, 0.0, 0.0), 1.0),
    1,
  )
  world.add_collider(collider1)
  world.add_collider(collider2)
  world.add_collider(collider3)
  let nearest = world.find_nearest_intersect(collider2)
  assert_true(nearest == Some(collider1))
}

///|
test "World2D::test_circle_lineseg_intersect1" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(2.0, 0.0, 0.0), 1.01)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(intersect)
}

///|
test "World2D::test_circle_lineseg_intersect2" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(2.0, 0.0, 0.0), 1.0)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(intersect)
}

///|
test "World2D::test_circle_lineseg_intersect3" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(2.0, 0.0, 0.0), 0.99)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(not(intersect))
}

///|
test "World2D::test_circle_lineseg_intersect4" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(0.5, 0.5, 0.0), 0.5)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(intersect)
}

///|
test "World2D::test_circle_lineseg_intersect5" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(0.5, 0.5, 0.0), 0.49)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(not(intersect))
}

///|
test "World2D::test_circle_lineseg_intersect6" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(-1, 0, 0.0), 1)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(intersect)
}

///|
test "World2D::test_circle_lineseg_intersect7" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(-1, 0, 0.0), 0.9)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(not(intersect))
}

///|
test "World2D::test_circle_lineseg_intersect8" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(-1, 1, 0.0), 1.42)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(intersect)
}

///|
test "World2D::test_circle_lineseg_intersect9" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(-1, -1, 0.0), 1.42)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(intersect)
}

///|
test "World2D::test_circle_lineseg_intersect10" {
  let lineSeg : LineSeg = LineSeg::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
  )
  let circle : Circle = Circle::new(Vector3::new(-1, 0, 0.0), 10)
  let intersect = Math2D::intersect_circle_lineSeg(
    circle.as_circle(),
    lineSeg.as_lineSeg(),
  )
  assert_true(intersect)
}

///|
test "World2D::test_circle_recto" {
  // TR
  let circle : Circle = Circle::new(Vector3::new(2.0, 2.0, 0.0), 1.42)
  let rect = Recto::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  )
  let intersect = Math2D::intersect_circle_recto(circle.as_circle(), rect)
  assert_true(intersect)

  // TR
  let circle : Circle = Circle::new(Vector3::new(3.0, 3.0, 0.0), 1.41)
  let rect = Recto::new(
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(1.0, 0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  )
  let intersect = Math2D::intersect_circle_recto(circle.as_circle(), rect)
  assert_true(not(intersect))

  // T
  let circle : Circle = Circle::new(Vector3::new(1.0, 2.0, 0.0), 1.01)
  let rect = Recto::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  )
  let intersect = Math2D::intersect_circle_recto(circle.as_circle(), rect)
  assert_true(intersect)

  // T
  let circle : Circle = Circle::new(Vector3::new(1.0, 2.0, 0.0), 0.99)
  let rect = Recto::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  )
  let intersect = Math2D::intersect_circle_recto(circle.as_circle(), rect)
  assert_true(not(intersect))

  // BL
  let circle : Circle = Circle::new(Vector3::new(-1.0, -1.0, 0.0), 1.42)
  let rect = Recto::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  )
  let intersect = Math2D::intersect_circle_recto(circle.as_circle(), rect)
  assert_true(intersect)

  // BL
  let circle : Circle = Circle::new(Vector3::new(-1.0, -1.0, 0.0), 1.42)
  let rect = Recto::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  )
  let intersect = Math2D::distance_pt_recto(circle.center, rect)
  assert_true(1.41 < intersect && intersect < 1.42)

  // BL
  let circle : Circle = Circle::new(
    Vector3::new(1000.0 - 1.0, 1000.0 - 1.0, 0.0),
    1.42,
  )
  let rect = Recto::new(
    Vector3::new(1000.0, 1000.0, 0.0),
    Vector3::new(2.0, 0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  )
  let intersect = Math2D::distance_pt_recto(circle.center, rect)
  assert_true(1.41 < intersect && intersect < 1.42)

  // L
  let circle : Circle = Circle::new(Vector3::new(-4.0, 5.0, 0.0), 1.01)
  let rect = Recto::new(
    Vector3::new(-3.0, -1.0, 0.0),
    Vector3::new(2.0, 0, 0.0),
    Vector3::new(0.0, 10.0, 0.0),
  )
  let distance = Math2D::distance_pt_recto(circle.center, rect)
  assert_eq(distance, 1.0)

  // center
  let circle : Circle = Circle::new(Vector3::new(50, 50, 0.0), 1)
  let rect = Recto::new(
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(100.0, 0, 0.0),
    Vector3::new(0.0, 100.0, 0.0),
  )
  let distance = Math2D::distance_pt_recto(circle.center, rect)
  assert_eq(distance, 0.0)
}

///|
test "World2D::test_rect_rect" {
  let rect1 = Rect::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(1.0, 1, 0.0))
  let rect2 = Rect::new(Vector3::new(1.0, 1.0, 0.0), Vector3::new(1.0, 1, 0.0))
  let intersect = Math2D::intersect_rect_rect(rect1, rect2)
  assert_true(intersect)
  let rect1 = Rect::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(1.0, 1, 0.0))
  let rect2 = Rect::new(Vector3::new(1.1, 1.1, 0.0), Vector3::new(1.0, 1, 0.0))
  let intersect = Math2D::intersect_rect_rect(rect1, rect2)
  assert_true(not(intersect))
}

///|
test "World2D::test_pt_rect" {
  let pt = Vector3::new(0.0, 0.0, 0.0)
  let rect = Rect::new(Vector3::new(1.0, 0.0, 0.0), Vector3::new(1.0, 1, 0.0))
  let distance = Math2D::distance_pt_rect(pt, rect)
  assert_eq(distance, 1.0)

  // center
  let pt = Vector3::new(1.0, 1.0, 0.0)
  let rect = Rect::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(2.0, 2, 0.0))
  let distance = Math2D::distance_pt_rect(pt, rect)
  assert_eq(distance, 0.0)
}

///|
test "World2D::test_convexpolygon_convexpolygon" {
  // distance 1
  let polygon1 = ConvexPolygon::new(Vector3::new(0, 0, 0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  ])
  let polygon2 = ConvexPolygon::new(Vector3::new(2, 1, 0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  ])
  let distance = polygon1.distance(polygon2)
  assert_eq(distance, 1.0)

  // distance 0
  let polygon1 = ConvexPolygon::new(Vector3::new(0, 0, 0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  ])
  let polygon2 = ConvexPolygon::new(Vector3::new(1, 1, 0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  ])
  let distance = polygon1.distance(polygon2)
  assert_eq(distance, 0.0)

  // distance -0.5
  let polygon1 = ConvexPolygon::new(Vector3::new(0, 0, 0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  ])
  let polygon2 = ConvexPolygon::new(Vector3::new(0.5, 0.5, 0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  ])
  let distance = polygon1.distance(polygon2)
  assert_eq(distance, -0.5)

  // distance inside
  let polygon1 = ConvexPolygon::new(Vector3::new(0, 0, 0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(4.0, 0.0, 0.0),
    Vector3::new(4.0, 4.0, 0.0),
    Vector3::new(0.0, 4.0, 0.0),
  ])
  let polygon2 = ConvexPolygon::new(Vector3::new(1.0, 1.0, 0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  ])
  let distance = polygon1.distance(polygon2)
  // max-min, 而不是最小值min-min, 所以是-2而不是-1
  assert_eq(distance, -2.0)
}

///|
test "World2D::test_circle_polygon1" {
  // distance 1
  let circle = Circle::new(Vector3::new(3.0, 0.0, 0.0), 1.0)
  let polygon = ConvexPolygon::new(Vector3::new(0.0, 0.0, 0.0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(1.0, 0.0, 0.0),
    Vector3::new(1.0, 1.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
  ])
  let distance = Math2D::distance_circle_convexpolygon(
    circle,
    polygon,
    accurate=true,
  )
  assert_eq(distance, 1.0)
}

///|
test "World2D::test_circle_polygon2" {
  // distance -1
  let circle = Circle::new(Vector3::new(3.0, 0.0, 0.0), 1.0)
  let polygon = ConvexPolygon::new(Vector3::new(0.0, 0.0, 0.0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0.0, 0.0),
    Vector3::new(2.0, 2.0, 0.0),
    Vector3::new(0.0, 2.0, 0.0),
  ])
  let distance = Math2D::distance_circle_convexpolygon(
    circle,
    polygon,
    accurate=true,
  )
  assert_eq(distance, 0.0)
}

///|
test "World2D::test_circle_polygon2" {
  // distance -1
  let circle = Circle::new(Vector3::new(2.0, 0.0, 0.0), 1.0)
  let polygon = ConvexPolygon::new(Vector3::new(0.0, 0.0, 0.0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0.0, 0.0),
    Vector3::new(2.0, 2.0, 0.0),
    Vector3::new(0.0, 2.0, 0.0),
  ])
  let distance = Math2D::distance_circle_convexpolygon(
    circle,
    polygon,
    accurate=true,
  )
  assert_eq(distance, -1.0)
}

///|
test "World2D::test_circle_polygon2" {
  // distance -1
  let circle = Circle::new(Vector3::new(2.0, 0.0, 0.0), 1.0)
  let polygon = ConvexPolygon::new(Vector3::new(0.0, 0.0, 0.0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0.0, 0.0),
    Vector3::new(2.0, 2.0, 0.0),
    Vector3::new(0.0, 2.0, 0.0),
  ])
  let distance = Math2D::distance_circle_convexpolygon(
    circle,
    polygon,
    accurate=true,
  )
  assert_eq(distance, -1.0)
}

///|
test "World2D::test_circle_polygon2" {
  // distance -1
  let circle = Circle::new(Vector3::new(2.5, 1.1, 0.0), 1.0)
  let polygon = ConvexPolygon::new(Vector3::new(0.0, 0.0, 0.0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0.0, 0.0),
    Vector3::new(2.0, 2.0, 0.0),
    Vector3::new(0.0, 2.0, 0.0),
  ])
  let distance = Math2D::distance_circle_convexpolygon(
    circle,
    polygon,
    accurate=true,
  )
  assert_eq(distance, -0.5)
}

///|
test "World2D::test_circle_polygon2" {
  // distance -1
  let circle = Circle::new(Vector3::new(1.5, 1.1, 0.0), 1.0)
  let polygon = ConvexPolygon::new(Vector3::new(0.0, 0.0, 0.0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 0.0, 0.0),
    Vector3::new(2.0, 2.0, 0.0),
    Vector3::new(0.0, 2.0, 0.0),
  ])
  let distance = Math2D::distance_circle_convexpolygon(
    circle,
    polygon,
    accurate=true,
  )
  assert_eq(distance, -1.5)
}

///|
test "World2D::test_circle_polygon2" {
  // distance -1
  let circle = Circle::new(Vector3::new(1.0, 1.0, 0.0), 1.0)
  let polygon = ConvexPolygon::new(Vector3::new(0.0, 0.0, 0.0), [
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(4.0, 0.0, 0.0),
    Vector3::new(4.0, 4.0, 0.0),
    Vector3::new(0.0, 4.0, 0.0),
  ])
  let distance = Math2D::distance_circle_convexpolygon(
    circle,
    polygon,
    accurate=true,
  )
  assert_eq(distance, -2.0)
}
