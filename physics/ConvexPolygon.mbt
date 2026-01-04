///| 凸多边形
pub(all) struct ConvexPolygon {
  // 相对中心点顺时针排列相对坐标
  center : Vector3
  vertices : Array[Vector3]
}

///|
pub fn ConvexPolygon::new(
  center : Vector3,
  vertices : Array[Vector3]
) -> ConvexPolygon {
  return ConvexPolygon::{ center, vertices }
}

///|
pub fn ConvexPolygon::project(
  self : ConvexPolygon,
  normal : Vector3
) -> (Double, Double) {
  // TODO: 优化性能, 不需要遍历全部
  let mut min : Double = 0.0
  let mut max : Double = 0.0
  let vertices = self.vertices
  let len = vertices.length()
  let distance0 = self.center.dot(normal)
  for index = 0; index < len; index = index + 1 {
    let vertex = vertices[index]
    let value = vertex.dot(normal)
    if index == 0 {
      min = value
      max = value
    } else {
      max = @cmp.maximum(max, value)
      min = @cmp.minimum(min, value)
    }
  }
  (distance0 + min, distance0 + max)
}

///|
fn ConvexPolygon::distance_part(
  polygon1 : ConvexPolygon,
  polygon2 : ConvexPolygon,
  iter : ConvexPolygon,
  accurate : Bool
) -> Double {
  let vertices = iter.vertices
  let len1 = vertices.length()
  let mut lastVertex = vertices[len1 - 1]
  let mut distance = @double.neg_infinity
  for i = 0; i < len1; i = i + 1 {
    let vertex = vertices[i]
    let dir = vertex - lastVertex
    lastVertex = vertex
    let normal = Vector3::new(dir.y, -dir.x, vertex.z)
    if normal.is_zero() {
      continue
    }
    let (min1, max1) = ConvexPolygon::project(polygon1, normal)
    let (min2, max2) = ConvexPolygon::project(polygon2, normal)
    let scaledDistance = @cmp.maximum(min1 - max2, min2 - max1)
    if scaledDistance > 0.0 {
      return scaledDistance / normal.magnitude()
    }
    if accurate {
      distance = @cmp.maximum(distance, scaledDistance / normal.magnitude())
    } else {
      distance = scaledDistance
    }
  }
  distance
}

///| 不重合点数多于三个
pub fn ConvexPolygon::distance(
  polygon1 : ConvexPolygon,
  polygon2 : ConvexPolygon,
  accurate~ : Bool = true
) -> Double {
  let distance1 = ConvexPolygon::distance_part(
    polygon1, polygon2, polygon1, accurate,
  )
  if not(accurate) && distance1 > 0.0 {
    return distance1
  }
  let distance2 = ConvexPolygon::distance_part(
    polygon1, polygon2, polygon2, accurate,
  )
  return @cmp.maximum(distance2, distance1)
}

///|
pub fn ConvexPolygon::intersect(
  polygon1 : ConvexPolygon,
  polygon2 : ConvexPolygon
) -> Bool {
  let distance = ConvexPolygon::distance(polygon1, polygon2, accurate=false)
  distance <= 0.0
}
