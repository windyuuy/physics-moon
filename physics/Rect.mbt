///|
pub(all) struct Rect {
  p0 : Vector3
  size : Vector3
}

///|
pub fn Rect::new(p0 : Vector3, size : Vector3) -> Rect {
  Rect::{ p0, size }
}
