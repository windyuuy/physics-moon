///| 2D线性空间计算
pub(all) struct Math2D {}

///| 一个点到一个线段的距离
pub fn Math2D::distance_pt_lineSeg_raw(
  x : Double,
  y : Double,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double
) -> Double {
  let cross : Double = (x2 - x1) * (x - x1) + (y2 - y1) * (y - y1)
  if cross <= 0 {
    return ((x - x1) * (x - x1) + (y - y1) * (y - y1)).sqrt()
  }
  let d2 : Double = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
  if cross >= d2 {
    return ((x - x2) * (x - x2) + (y - y2) * (y - y2)).sqrt()
  }
  let r : Double = cross / d2
  let px : Double = x1 + (x2 - x1) * r
  let py : Double = y1 + (y2 - y1) * r
  return ((x - px) * (x - px) + (y - py) * (y - py)).sqrt()
}

///| 两个 Circle 是否相交
pub fn Math2D::intersect_circle_circle(
  circle1 : Circle,
  circle2 : Circle
) -> Bool {
  let dist2 = circle1.get_position().sqr_distance(circle2.get_position())
  let radius2 = circle1.get_radius() + circle2.get_radius()
  let yes = radius2 * radius2 >= dist2
  return yes
}

///| 一个 Circle 和一个 LineSeg 距离
pub fn Math2D::distance_pt_lineSeg(
  pt : Vector3,
  p1 : Vector3,
  p2 : Vector3
) -> Double {
  Math2D::distance_pt_lineSeg_raw(pt.x, pt.y, p1.x, p1.y, p2.x, p2.y)
}

///| 一个 Circle 和一个 LineSeg 是否相交
pub fn Math2D::intersect_circle_lineSeg(
  circle : Circle,
  line : LineSeg
) -> Bool {
  let distance = Math2D::distance_pt_lineSeg(
    circle.get_position(),
    line.get_pt1(),
    line.get_pt2(),
  )
  distance <= circle.get_radius()
}

///| 两个 LineSeg 距离
pub fn Math2D::distance_lineSeg_lineSeg(
  line1 : LineSeg,
  line2 : LineSeg
) -> Double {
  let pt1_1 = line1.get_pt1()
  let pt1_2 = line1.get_pt2()
  let pt2_1 = line2.get_pt1()
  let pt2_2 = line2.get_pt2()
  @cmp.minimum(
    @cmp.minimum(
      Math2D::distance_pt_lineSeg(pt1_1, pt2_1, pt2_2),
      Math2D::distance_pt_lineSeg(pt1_2, pt2_1, pt2_2),
    ),
    @cmp.minimum(
      Math2D::distance_pt_lineSeg(pt2_1, pt1_1, pt1_2),
      Math2D::distance_pt_lineSeg(pt2_2, pt1_1, pt1_2),
    ),
  )
}

///| 两个 LineSeg 是否相交
pub fn Math2D::intersect_lineSeg_lineSeg(
  line1 : LineSeg,
  line2 : LineSeg
) -> Bool {
  let a = line1.get_pt1()
  let b = line1.get_pt2()
  let c = line2.get_pt1()
  let d = line2.get_pt2()
  //快速排斥实验
  if @cmp.maximum(c.x, d.x) < @cmp.minimum(a.x, b.x) ||
    @cmp.maximum(a.x, b.x) < @cmp.minimum(c.x, d.x) ||
    @cmp.maximum(c.y, d.y) < @cmp.minimum(a.y, b.y) ||
    @cmp.maximum(a.y, b.y) < @cmp.minimum(c.y, d.y) {
    return false
  }
  //跨立实验
  if Vector3::dot(Vector3::cross(a - d, c - d), Vector3::cross(b - d, c - d)) >
    0.0 ||
    Vector3::dot(Vector3::cross(d - b, a - b), Vector3::cross(c - b, a - b)) >
    0.0 {
    return false
  }
  return true
}

///|
pub fn Math2D::distance_pt_recto(pt : Vector3, rect1 : Recto) -> Double {
  let offsetC0 = pt - rect1.p0
  let p2 = Vector3::add3v(rect1.p0, rect1.offsetA, rect1.offsetB)
  let offsetC2 = {
    p2.sub_up(pt)
    p2
  }
  let dA0 = offsetC0.dot(rect1.offsetA)
  let dB0 = offsetC0.dot(rect1.offsetB)
  let nearestA = if dA0 <= 0.0 {
    Vector3::shared_zero()
  } else if 0.0 >= offsetC2.dot(rect1.offsetA) {
    rect1.offsetA
  } else {
    let m = rect1.offsetA.magnitude()
    rect1.offsetA.scale(dA0 / (m * m))
  }
  let nearestB = if dB0 <= 0.0 {
    Vector3::shared_zero()
  } else if 0.0 >= offsetC2.dot(rect1.offsetB) {
    rect1.offsetB
  } else {
    let m = rect1.offsetB.magnitude()
    rect1.offsetB.scale(dB0 / (m * m))
  }
  let nearestAB = Vector3::add3v(rect1.p0, nearestA, nearestB)
  let distance = Vector3::distance(nearestAB, pt)
  distance
}

///|
pub fn Math2D::distance_pt_rect(pt : Vector3, rect1 : Rect) -> Double {
  let x0 = rect1.p0.x
  let x1 = x0 + rect1.size.x
  let y0 = rect1.p0.y
  let y1 = y0 + rect1.size.y
  let x = @cmp.maximum(x0, @cmp.minimum(x1, pt.x))
  let y = @cmp.maximum(y0, @cmp.minimum(y1, pt.y))
  let distance = if x0 < x && x < x1 {
    (pt.x - x).abs()
  } else if y0 < y && y < y1 {
    (pt.y - y).abs()
  } else {
    Vector3::distance(pt, Vector3::new(x, y, pt.z))
  }
  distance
}

///|
pub fn Math2D::intersect_circle_recto(circle : Circle, rect1 : Recto) -> Bool {
  let distance = Math2D::distance_pt_recto(circle.center, rect1)
  distance <= circle.radius
}

///|
pub fn Math2D::intersect_rect_rect(rect1 : Rect, rect2 : Rect) -> Bool {
  guard rect1.size.is_natural() && rect2.size.is_natural() else {
    thrown("invalid rect size")
  }
  let intersectX = rect1.p0.x <= rect2.p0.x + rect2.size.x &&
    rect1.p0.x + rect1.size.x >= rect2.p0.x
  let intersectY = rect1.p0.y <= rect2.p0.y + rect2.size.y &&
    rect1.p0.y + rect1.size.y >= rect2.p0.y
  let intersect = intersectX && intersectY
  intersect
}

///|
pub fn Math2D::intersect_convexpolygon_convexpolygon(
  polygon1 : ConvexPolygon,
  polygon2 : ConvexPolygon
) -> Bool {
  polygon1.intersect(polygon2)
}

///|
fn Math2D::distance_part_circle_convexpolygon(
  circle1 : Circle,
  polygon2 : ConvexPolygon,
  iter : ConvexPolygon
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
    normal.normalize()
    let (min1, max1) = Circle::project(circle1, normal)
    let (min2, max2) = ConvexPolygon::project(polygon2, normal)
    let distance1 = @cmp.maximum(min1 - max2, min2 - max1)
    if distance1 > 0.0 {
      return distance1
    }
    distance = @cmp.maximum(distance, distance1)
  }
  distance
}

///|
fn Math2D::distance_part2_circle_convexpolygon(
  circle1 : Circle,
  polygon2 : ConvexPolygon
) -> Double {
  let mut nearest : Vector3 = polygon2.vertices[0]
  let mut distance = Vector3::distance(circle1.center, nearest)
  let len1 = polygon2.vertices.length()
  for i = 1; i < len1; i = i + 1 {
    let vertex = polygon2.vertices[i]
    let dist = Vector3::distance(circle1.center, vertex)
    if dist < distance {
      distance = dist
      nearest = vertex
    }
  }
  let normal = {
    let temp = circle1.center - nearest
    temp.normalize()
    temp
  }
  let (min1, max1) = circle1.project(normal)
  let (min2, max2) = polygon2.project(normal)
  let distance1 = @cmp.maximum(min1 - max2, min2 - max1)
  distance1
}

///|
pub fn Math2D::distance_circle_convexpolygon(
  circle1 : Circle,
  polygon2 : ConvexPolygon,
  accurate~ : Bool = true
) -> Double {
  ignore(accurate)
  let distance1 = Math2D::distance_part2_circle_convexpolygon(circle1, polygon2)
  if distance1 > 0.0 {
    return distance1
  }
  let distance2 = Math2D::distance_part_circle_convexpolygon(
    circle1, polygon2, polygon2,
  )
  return @cmp.maximum(distance2, distance1)
}

// ///| 近似解
// pub fn Math2D::distance_circle_polygon_nearly(
//   center : Vector3,
//   radius : Double,
//   vertices : Array[Vector3],
//   accurate : Bool
// ) -> Double {
//   let len = vertices.length()
//   let mut lastVec = vertices[len - 1] - center
//   let mut lastDist = lastVec.normalize_with_ret() - radius
//   if lastDist < 0 {
//     lastVec.scale_up(-1)
//   }
//   let mut distance = lastDist
//   let mut rads = 0.0
//   for i = 0; i < len; i = i + 1 {
//     let vec = vertices[i]
//     let dir = vec - center
//     let dist = dir.normalize_with_ret() - radius
//     if accurate {
//       distance = @cmp.minimum(distance, dist)
//     } else if dist < 0 {
//       return dist
//     }
//     let moveDir = dir.scale(dist) - lastVec.scale(lastDist)
//     let dot = lastVec.cross_z(moveDir)
//     if dot == 0 {
//       lastVec = dir
//       lastDist = dist
//     } else {
//       let rad = @math.acos(dir.dot(lastVec)) * dot.signum()
//       lastVec = dir
//       lastDist = dist
//       rads += rad
//     }
//   }
//   if rads.abs() < 0.00001 {
//     return distance
//   } else {
//     return -distance
//   }
// }

// pub fn Math2D::intersect_info_lineSeg_lineSeg( a:Vector3,  b:Vector3,  c:Vector3,  d:Vector3, intersectPos:Vector3)->Bool{
//         intersectPos.reset()

//         Vector3 ab = b - a;
//         Vector3 ca = a - c;
//         Vector3 cd = d - c;

//         Vector3 v1 = Vector3.Cross(ca, cd);

//         if (Mathf.Abs(Vector3.Dot(v1, ab)) > 1e-6)
//         {
//             // 不共面
//             return false;
//         }

//         if (Vector3.Cross(ab, cd).sqrMagnitude <= 1e-6)
//         {
//             // 平行
//             return false;
//         }

//         Vector3 ad = d - a;
//         Vector3 cb = b - c;
//         // 快速排斥
//         if (Mathf.Min(a.x, b.x) > Mathf.Max(c.x, d.x) || Mathf.Max(a.x, b.x) < Mathf.Min(c.x, d.x)
//            || Mathf.Min(a.y, b.y) > Mathf.Max(c.y, d.y) || Mathf.Max(a.y, b.y) < Mathf.Min(c.y, d.y)
//            || Mathf.Min(a.z, b.z) > Mathf.Max(c.z, d.z) || Mathf.Max(a.z, b.z) < Mathf.Min(c.z, d.z)
//         )
//             return false;

//         // 跨立试验
//         if (Vector3.Dot(Vector3.Cross(-ca, ab), Vector3.Cross(ab, ad)) > 0
//             && Vector3.Dot(Vector3.Cross(ca, cd), Vector3.Cross(cd, cb)) > 0)
//         {
//             Vector3 v2 = Vector3.Cross(cd, ab);
//             float ratio = Vector3.Dot(v1, v2) / v2.sqrMagnitude;
//             intersectPos = a + ab * ratio;
//             return true;
//         }

//         return false;
//     }
