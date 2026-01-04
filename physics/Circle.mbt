///|
pub(all) struct Circle {
  priv center : Vector3
  priv mut radius : Double
  priv diameter : Double
}

///|
pub fn Circle::new(center : Vector3, radius : Double) -> Circle {
  Circle::{ center, radius, diameter: radius + radius }
}

///|
pub fn Circle::get_center(self : Circle) -> Vector3 {
  self.center
}

///|
pub impl IShape for Circle with get_position(self : Circle) -> Vector3 {
  return self.center
}

///|
pub impl IShape for Circle with update_transform(
  self : Circle,
  position : Vector3,
  _ : Vector3
) -> Unit {
  self.center.set(position)
}

///|
pub impl IShape for Circle with as_circle(self : Circle) -> Circle {
  self
}

///|
pub impl IShape for Circle with get_shape_type(self : Circle) -> ShapeType {
  ignore(self)
  shapeTypeValues.circle
}

///|
pub fn Circle::get_radius(self : Circle) -> Double {
  self.radius
}

// 是否包含包括在边界上某一点

///|
pub fn Circle::contains_pt(self : Circle, pos : Vector3) -> Bool {
  let dist2 = pos.sqr_distance(self.get_position())
  let radius = self.get_radius()
  let yes = radius * radius >= dist2
  return yes
}

///|
pub fn Circle::project(self : Circle, normal : Vector3) -> (Double, Double) {
  let distance = self.center.dot(normal)
  let radius = self.radius
  (distance - radius, distance + radius)
}

///|
pub impl IShape for Circle with to_string(self : Circle) -> String {
  "{p1:\{self.center}, p2:\{self.radius},"
}

///|
pub impl IShape for Circle with get_aabbi(
  self : Circle,
  sizeScale : Double,
  aabb : AABBI
) -> Unit {
  let { x: centerX, y: centerY, z: _ } = self.center
  if sizeScale == 1 {
    let radius = self.radius
    aabb.xMin = @math.floor(centerX - radius).to_int()
    aabb.xMax = @math.ceil(centerX + radius).to_int()
    aabb.yMin = @math.floor(centerY - radius).to_int()
    aabb.yMax = @math.ceil(centerY + radius).to_int()
  } else {
    let centerX = centerX * sizeScale
    let centerY = centerY * sizeScale
    let radius = self.radius * sizeScale
    aabb.xMin = @math.floor(centerX - radius).to_int()
    aabb.xMax = @math.ceil(centerX + radius).to_int()
    aabb.yMin = @math.floor(centerY - radius).to_int()
    aabb.yMax = @math.ceil(centerY + radius).to_int()
  }
  aabb.isDirty = true
}

///|
pub impl IShape for Circle with get_size(self : Circle) -> Double {
  self.diameter
}

///|
pub impl IShape for Circle with set_size1(self, radius) -> Unit {
  self.radius = radius
}
