///|
pub struct Vector2I {
  mut x : Int
  mut y : Int
}

///|
pub fn Vector2I::new(x : Int, y : Int) -> Vector2I {
  Vector2I::{ x, y }
}

///|
pub fn Vector2I::zero() -> Vector2I {
  Vector2I::{ x: 0, y: 0 }
}

///|
pub fn Vector2I::merge(self : Vector2I, other : Vector2I) -> Unit {
  self.x = other.x
  self.y = other.y
}

///|
pub fn Vector2I::equal(self : Vector2I, other : Vector2I) -> Bool {
  self.x == other.x && self.y == other.y
}

///|
pub fn Vector2I::not_equal(self : Vector2I, other : Vector2I) -> Bool {
  self.x != other.x || self.y != other.y
}

///|
pub fn Vector2I::not_equal2(self : Vector2I, ix : Int, iy : Int) -> Bool {
  self.x != ix && self.y != iy
}

///|
pub struct AABBI {
  mut isDirty : Bool
  mut xMin : Int
  mut xMax : Int
  mut yMin : Int
  mut yMax : Int
} derive(Show)

///|
impl Default for AABBI with default() -> AABBI {
  return AABBI::{ isDirty: true, xMin: 0, xMax: 0, yMin: 0, yMax: 0 }
}

///|
pub fn AABBI::new(xMin : Int, xMax : Int, yMin : Int, yMax : Int) -> AABBI {
  AABBI::{ isDirty: false, xMin, xMax, yMin, yMax }
}

///|
pub struct BoxScanner {
  // map[n*m][index]
  marks : Array[Array[&ICollider]]
  collisions : Array[Int]
  // TODO: 迁移到单独的模块中
  rect : AABBI
  opended : Array[Int]
  opendedIndexes : Array[Int]
  sharedMark : Array[&ICollider]
  halfWidth : Int
  halfHeight : Int
  vec2I : Vector2I
  scale : Double
  sharedAabb : AABBI
  unit : Double
}

///|
pub fn BoxScanner::new(
  sceneSize : Vector3,
  unit : Double,
  colliderOidMax : Int,
) -> BoxScanner {
  let scale = 1.0 / unit
  let halfWidth = @math.floor(sceneSize.x * scale * 0.5).to_int() + 1
  let halfHeight = @math.floor(sceneSize.y * scale * 0.5).to_int() + 1
  let size = 4 * halfWidth * halfHeight
  let marks : Array[Array[&ICollider]] = Array::makei(size, fn(_) {
    Array::new()
  })
  let size : Int = colliderOidMax
  let opended : Array[Int] = Array::make(size, 0)
  let vec2I = Vector2I::zero()
  BoxScanner::{
    marks,
    rect: AABBI::default(),
    collisions: Array::new(),
    opended,
    opendedIndexes: [],
    sharedMark: [],
    halfWidth,
    halfHeight,
    vec2I,
    scale,
    unit,
    sharedAabb: AABBI::default(),
  }
}

///|
pub fn BoxScanner::clear(self : BoxScanner) -> Unit {
  let marks = self.marks
  let collisions = self.collisions
  for index in collisions {
    let mark = marks[index]
    if mark.length() > 0 {
      mark.clear()
    }
  }
  collisions.clear()
}

///|
pub fn BoxScanner::scan_marks(
  self : BoxScanner,
  colliders : Array[&ICollider],
) -> Unit {
  // 在每级方阵中记录每个碰撞体的位置
  // 每个碰撞体和aabb内碰撞体判断碰撞
  let halfWidth = self.halfWidth
  let width = halfWidth * 2
  let halfHeight = self.halfHeight
  let scale = self.scale
  let marks = self.marks
  let collisions = self.collisions
  let vec2I = self.vec2I
  for collider in colliders {
    collider.get_ipos(scale, vec2I)
    let index = vec2I.x + halfWidth + (vec2I.y + halfHeight) * width
    let mark = marks[index]
    mark.push(collider)
    if mark.length() == 1 {
      collisions.push(index)
    }
  }
}

///|
pub fn BoxScanner::foreach_collisions(
  self : BoxScanner,
  colliders : Array[&ICollider],
  callback : (&ICollider, &ICollider) -> Unit,
) -> Unit {
  let marks = self.marks
  let collisions = self.collisions
  let scale = self.scale
  let halfWidth = self.halfWidth
  let width = halfWidth * 2
  let halfHeight = self.halfHeight
  // let vec2I = self.vec2I
  let lenMax = marks.length()
  let opened = self.opended

  // clear
  if collisions.length() > 0 {
    for index in collisions {
      let mark = marks[index]
      mark.clear()
    }
    collisions.clear()
  }
  for collider in colliders {
    let colliderOid = collider.oid()
    opened[colliderOid] = 0
  }

  // scan marks
  let aabb = self.sharedAabb
  let vec2I = self.vec2I
  for collider in colliders {

    // update grid
    {
      collider.get_ipos(scale, vec2I)
      let index2 = vec2I.x + halfWidth + (vec2I.y + halfHeight) * width
      if index2 < 0 || index2 >= lenMax {
        println_error("scanner index2 overflow")
        continue
      }
    }

    // collider.get_indexi(scale, vec2I)
    // let index = vec2I.x + halfWidth + (vec2I.y + halfHeight) * width
    collider.get_aabb(scale, aabb)
    let { xMin, xMax, yMin, yMax, .. } = aabb
    // println("aabb: \{index},\{i}, \{aabb}")
    if xMin < -halfWidth {
      // println_error("xMin < -halfWidth: \{xMin} < \{-halfWidth}")
      continue
    }
    if xMax >= halfWidth {
      // println_error("xMax >= halfWidth: \{xMax} >= \{halfWidth}")
      continue
    }
    if yMin < -halfHeight {
      // println_error("yMin < -halfHeight: \{yMin} < \{-halfHeight}")
      continue
    }
    if yMax >= halfHeight {
      // println_error("yMax >= halfHeight: \{yMax} >= \{halfHeight}")
      continue
    }
    if false == collider.is_positive() {
      for x in xMin..<xMax {
        for y in yMin..<yMax {
          let index2 = x + halfWidth + (y + halfHeight) * width
          if index2 < 0 || index2 >= lenMax {
            println_error("scanner index2 overflow")
            continue
          }
          let mark = marks[index2]
          let markLen1 = mark.length()
          mark.push(collider)
          if markLen1 == 0 {
            // 仅一次
            collisions.push(index2)
          }
        }
      }
    } else {
      for x in xMin..<xMax {
        for y in yMin..<yMax {
          let index2 = x + halfWidth + (y + halfHeight) * width
          if index2 < 0 || index2 >= lenMax {
            println_error("scanner index3 overflow")
            continue
          }
          let mark = marks[index2]
          let markLen1 = mark.length()
          mark.push(collider)
          if markLen1 == 0 {
            // 仅一次
            collisions.push(index2)
          } else {
            let collider1Oid = collider.oid()
            for i in 0..<markLen1 {
              let collider2 = mark[i]
              let collider2Oid = collider2.oid()
              if opened[collider2Oid] != collider1Oid {
                opened[collider2Oid] = collider1Oid
                callback(collider, collider2)
              }
            }
          }
        }
      }
    }
  }
}

///|
pub struct MultiBoxScanner {
  unit : Double
  scanner1 : BoxScanner
  larges : Array[&ICollider]
}

///|
pub fn MultiBoxScanner::new(
  sceneSize : Vector3,
  unit : Double,
  colliderOidMax : Int,
) -> MultiBoxScanner {
  MultiBoxScanner::{
    scanner1: BoxScanner::new(sceneSize, unit, colliderOidMax),
    larges: Array::new(),
    unit,
  }
}

///|
pub fn MultiBoxScanner::add_collider(
  self : MultiBoxScanner,
  collider : &ICollider,
) -> Unit {
  if self.unit < collider.get_shape().get_size() {
    self.larges.push(collider)
  }
}

///|
pub fn MultiBoxScanner::remove_collider(
  self : MultiBoxScanner,
  collider : &ICollider,
) -> Unit {
  if self.unit < collider.get_shape().get_size() {
    @iter.remove_item(self.larges, collider)
  }
}

///|
pub fn MultiBoxScanner::scan_marks(
  self : MultiBoxScanner,
  colliders : Array[&ICollider],
) -> Unit {
  self.scanner1.scan_marks(colliders)
}

///|
pub fn MultiBoxScanner::clear(self : MultiBoxScanner) -> Unit {
  self.scanner1.clear()
}

///|
pub fn MultiBoxScanner::foreach_larges(
  self : MultiBoxScanner,
  callback : (&ICollider, &ICollider) -> Unit,
) -> Unit {
  let larges = self.larges
  let len = larges.length()
  if len > 0 {
    for i in 0..<len {
      for j in (i + 1)..<len {
        let collider1 = larges[i]
        let collider2 = larges[j]
        if collider1.is_positive() || collider2.is_positive() {
          callback(collider1, collider2)
        }
      }
    }
  }
}

///|
pub fn MultiBoxScanner::foreach_collisions(
  self : MultiBoxScanner,
  colliders : Array[&ICollider],
  callback : (&ICollider, &ICollider) -> Unit,
) -> Unit {
  self.scanner1.foreach_collisions(colliders, callback)
  // self.foreach_larges(callback)
}
