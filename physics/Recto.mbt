///|
pub(all) struct Recto {
  p0 : Vector3
  offsetA : Vector3
  offsetB : Vector3
}

///|
pub fn Recto::new(p0 : Vector3, offsetA : Vector3, offsetB : Vector3) -> Recto {
  Recto::{ p0, offsetA, offsetB }
}
