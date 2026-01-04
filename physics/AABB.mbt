///|
pub(open) trait ITransform {
  get_position(Self) -> Vector3
}

///|
pub(all) struct AABB {
  mut min_x : Double
  mut min_y : Double
  mut max_x : Double
  mut max_y : Double
}

///|
pub fn AABB::contains(self : AABB, pos : Vector3) -> Bool {
  pos.x >= self.min_x &&
  pos.x <= self.max_x &&
  pos.y >= self.min_y &&
  pos.y <= self.max_y
}

///|
pub fn AABB::intersects(self : AABB, other : AABB) -> Bool {
  other.max_x >= self.min_x &&
  other.min_x <= self.max_x &&
  other.max_y >= self.min_y &&
  other.min_y <= self.max_y
}
