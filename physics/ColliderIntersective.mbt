///|
pub(all) enum ColliderIntersective {
  No
  Y1
  Y2
  Both
  Unset
} derive(Eq, Show, Compare, Hash)

///|
pub fn ColliderIntersective::empty() -> ColliderIntersective {
  return ColliderIntersective::No
}

///|
pub fn ColliderIntersective::default() -> ColliderIntersective {
  return ColliderIntersective::No
}

///|
pub fn ColliderIntersective::to_int(self : ColliderIntersective) -> Int {
  match self {
    No => 0
    Y1 => 1
    Y2 => 2
    Both => 3
    Unset => 4
  }
}

///|
pub fn ColliderIntersective::from_int(value : Int) -> ColliderIntersective {
  match value {
    0 => No
    1 => Y1
    2 => Y2
    3 => Both
    4 => Unset
    _ => No
  }
}

///|
pub fn ColliderIntersective::serialize(
  self : ColliderIntersective,
  bytes : FixedArray[Byte],
  offset : Int
) -> Int {
  @ic.from_int(bytes, offset, self.to_int())
}

///|
pub fn ColliderIntersective::deserialize(
  bytes : FixedArray[Byte],
  offset : Int
) -> (Int, ColliderIntersective) {
  let (size, value) = @ic.to_int(bytes, offset)
  (size, ColliderIntersective::from_int(value))
}

///|
pub fn ColliderIntersective::is_y1(self : ColliderIntersective) -> Bool {
  (self.to_int() & 1) > 0
}

///|
pub fn ColliderIntersective::is_y2(self : ColliderIntersective) -> Bool {
  (self.to_int() & 2) > 0
}

///|
pub fn ColliderIntersective::is_yes(self : ColliderIntersective) -> Bool {
  self.to_int() > 0
}

///|
pub fn ColliderIntersective::is_no(self : ColliderIntersective) -> Bool {
  self.to_int() == 0
}
