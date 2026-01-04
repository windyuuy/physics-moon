///|
pub typealias Int as TCellValue

///|
pub const CellValueDefault : TCellValue = 0

///|
pub struct AStar {
  halfWidth : Int
  halfHeight : Int
  scale : Double
  unit : Double
  grid : Array[TCellValue]
  sharedCurIPos : Vector2I
  sharedNextIPos : Vector2I
}

///|
pub fn AStar::new(sceneSize : Vector3, unit : Double) -> AStar {
  let scale = 1.0 / unit
  let halfWidth = @math.floor(sceneSize.x * scale * 0.5).to_int() + 1
  let halfHeight = @math.floor(sceneSize.y * scale * 0.5).to_int() + 1
  let size = 4 * halfWidth * halfHeight
  let grid : Array[TCellValue] = Array::makei(size, fn(_) { CellValueDefault })
  let astar = AStar::{
    grid,
    scale,
    unit,
    halfWidth,
    halfHeight,
    sharedCurIPos: Vector2I::zero(),
    sharedNextIPos: Vector2I::zero(),
  }
  astar.init_sqrt_map()
  astar
}

///|
pub fn AStar::to_ipos(self : AStar, pos : Vector3, posI : Vector2I) -> Unit {
  let scale = self.scale
  posI.x = @math.floor(pos.x * scale).to_int()
  posI.y = @math.floor(pos.y * scale).to_int()
}

///|
pub fn AStar::to_pos(self : AStar, posI : Vector2I, pos : Vector3) -> Unit {
  let unit = self.unit
  pos.x = (posI.x.to_double() + 0.5) * unit
  pos.y = (posI.y.to_double() + 0.5) * unit
}

///|
pub fn AStar::to_pos2(self : AStar, ix : Int, iy : Int, pos : Vector3) -> Unit {
  let unit = self.unit
  pos.x = (ix.to_double() + 0.5) * unit
  pos.y = (iy.to_double() + 0.5) * unit
}

///|
pub fn AStar::ipos_to_index(self : AStar, posI : Vector2I) -> Int {
  let halfWidth = self.halfWidth
  let halfHeight = self.halfHeight
  let width = halfWidth * 2
  let index2 = posI.x + halfWidth + (posI.y + halfHeight) * width
  index2
}

///|
pub fn AStar::ipos2_to_index(self : AStar, ix : Int, iy : Int) -> Int {
  let halfWidth = self.halfWidth
  let halfHeight = self.halfHeight
  let width = halfWidth * 2
  let index2 = ix + halfWidth + (iy + halfHeight) * width
  index2
}

///|
pub fn AStar::exist2(self : AStar, ix : Int, iy : Int) -> Bool {
  let index = self.ipos2_to_index(ix, iy)
  let mark = self.grid[index]
  mark != CellValueDefault
}

///|
pub fn AStar::exist1(self : AStar, index : Int) -> Bool {
  let grid = self.grid
  if grid.length() > index && index >= 0 {
    let mark = grid[index]
    mark != CellValueDefault
  } else {
    // println_error("wefew: \{self.grid.length()}, \{index}")
    true
  }
}

///|
pub fn AStar::remove_lock(self : AStar, index : Int) -> Unit {
  self.grid[index] = CellValueDefault
}

///|
pub fn AStar::try_remove_lock(
  self : AStar,
  index : Int,
  icollider : TCellValue,
) -> Unit {
  let grid = self.grid
  if grid[index] == icollider {
    grid[index] = CellValueDefault
  }
}

///|
pub fn AStar::add_lock(
  self : AStar,
  index : Int,
  icollider : TCellValue,
) -> Unit {
  self.grid[index] = icollider
}

///|
pub fn AStar::try_add_lock(
  self : AStar,
  index : Int,
  icollider : TCellValue,
) -> Unit {
  let grid = self.grid
  if grid[index] == CellValueDefault {
    grid[index] = icollider
  }
}

///|
const SQRT_MAP_SIZE : Int = 10000

///|
let sqrtMap : Array[Float] = []

///|
fn AStar::init_sqrt_map(_self : AStar) -> Unit {
  if sqrtMap.length() == 0 {
    for i in 0..<SQRT_MAP_SIZE {
      sqrtMap.push(i.to_float().sqrt())
    }
  }
}

///|
fn fastIFSqrt(v : Int) -> Float {
  if v < SQRT_MAP_SIZE {
    sqrtMap[v]
  } else {
    v.to_float().sqrt()
  }
}

///|
fn calc_gh(x : Int, y : Int) -> Float {
  // let min = @cmp.minimum(x, y).to_float()
  // let max = @cmp.maximum(x, y).to_float()
  // let dis = min * (0.707 : Float) + (max - min)
  // dis
  if x == 0 {
    y.to_float()
  } else if y == 0 {
    x.to_float()
  } else if x == y {
    x.to_float() * (1.414 : Float)
  } else {
    // return (fx * fx + fy * fy).to_float().sqrt()
    return fastIFSqrt(x * x + y * y)
  }
}

///|
fn compare1(
  v : Float,
  vt1 : Float,
  vt2 : Float,
  vt8 : Float,
  vt3 : Float,
  vt7 : Float,
  vt4 : Float,
  vt6 : Float,
  vt5 : Float,
) -> Int {
  if v >= vt1 {
    return 1
  }
  if v >= vt2 {
    return 2
  }
  if v >= vt8 {
    return 8
  }
  if v >= vt3 {
    return 3
  }
  if v >= vt7 {
    return 7
  }
  if v >= vt4 {
    return 4
  }
  if v >= vt6 {
    return 6
  }
  if v >= vt5 {
    return 5
  }
  thrown("invalid")
}

///|
fn compare2(
  v : Float,
  vt5 : Float,
  vt6 : Float,
  vt4 : Float,
  vt7 : Float,
  vt3 : Float,
  vt8 : Float,
  vt2 : Float,
  vt1 : Float,
) -> Int {
  if v >= vt5 {
    return 5
  }
  if v >= vt6 {
    return 6
  }
  if v >= vt4 {
    return 4
  }
  if v >= vt7 {
    return 7
  }
  if v >= vt3 {
    return 3
  }
  if v >= vt8 {
    return 8
  }
  if v >= vt2 {
    return 2
  }
  if v >= vt1 {
    return 1
  }
  thrown("invalid")
}

///|
fn compare3(
  v : Float,
  vt3 : Float,
  vt4 : Float,
  vt2 : Float,
  vt5 : Float,
  vt1 : Float,
  vt6 : Float,
  vt8 : Float,
  vt7 : Float,
) -> Int {
  if v >= vt3 {
    return 3
  }
  if v >= vt4 {
    return 4
  }
  if v >= vt2 {
    return 2
  }
  if v >= vt5 {
    return 5
  }
  if v >= vt1 {
    return 1
  }
  if v >= vt6 {
    return 6
  }
  if v >= vt8 {
    return 8
  }
  if v >= vt7 {
    return 7
  }
  thrown("invalid")
}

///|
fn compare4(
  v : Float,
  vt7 : Float,
  vt8 : Float,
  vt6 : Float,
  vt1 : Float,
  vt5 : Float,
  vt2 : Float,
  vt4 : Float,
  vt3 : Float,
) -> Int {
  if v >= vt7 {
    return 7
  }
  if v >= vt8 {
    return 8
  }
  if v >= vt6 {
    return 6
  }
  if v >= vt1 {
    return 1
  }
  if v >= vt5 {
    return 5
  }
  if v >= vt2 {
    return 2
  }
  if v >= vt4 {
    return 4
  }
  if v >= vt3 {
    return 3
  }
  thrown("invalid")
}

///|
fn compare5(
  v : Float,
  vt2 : Float,
  vt3 : Float,
  vt1 : Float,
  vt4 : Float,
  vt8 : Float,
  vt5 : Float,
  vt7 : Float,
  vt6 : Float,
) -> Int {
  if v >= vt2 {
    return 2
  }
  if v >= vt3 {
    return 3
  }
  if v >= vt1 {
    return 1
  }
  if v >= vt4 {
    return 4
  }
  if v >= vt8 {
    return 8
  }
  if v >= vt5 {
    return 5
  }
  if v >= vt7 {
    return 7
  }
  if v >= vt6 {
    return 6
  }
  thrown("invalid")
}

///|
fn compare6(
  v : Float,
  vt6 : Float,
  vt7 : Float,
  vt5 : Float,
  vt8 : Float,
  vt4 : Float,
  vt1 : Float,
  vt3 : Float,
  vt2 : Float,
) -> Int {
  if v >= vt6 {
    return 6
  }
  if v >= vt7 {
    return 7
  }
  if v >= vt5 {
    return 5
  }
  if v >= vt8 {
    return 8
  }
  if v >= vt4 {
    return 4
  }
  if v >= vt1 {
    return 1
  }
  if v >= vt3 {
    return 3
  }
  if v >= vt2 {
    return 2
  }
  thrown("invalid")
}

///|
fn compare7(
  v : Float,
  vt4 : Float,
  vt5 : Float,
  vt3 : Float,
  vt6 : Float,
  vt2 : Float,
  vt7 : Float,
  vt1 : Float,
  vt8 : Float,
) -> Int {
  if v >= vt4 {
    return 4
  }
  if v >= vt5 {
    return 5
  }
  if v >= vt3 {
    return 3
  }
  if v >= vt6 {
    return 6
  }
  if v >= vt2 {
    return 2
  }
  if v >= vt7 {
    return 7
  }
  if v >= vt1 {
    return 1
  }
  if v >= vt8 {
    return 8
  }
  thrown("invalid")
}

///|
fn compare8(
  v : Float,
  vt8 : Float,
  vt1 : Float,
  vt7 : Float,
  vt2 : Float,
  vt6 : Float,
  vt3 : Float,
  vt5 : Float,
  vt4 : Float,
) -> Int {
  if v >= vt8 {
    return 8
  }
  if v >= vt1 {
    return 1
  }
  if v >= vt7 {
    return 7
  }
  if v >= vt2 {
    return 2
  }
  if v >= vt6 {
    return 6
  }
  if v >= vt3 {
    return 3
  }
  if v >= vt5 {
    return 5
  }
  if v >= vt4 {
    return 4
  }
  thrown("invalid")
}

///|
pub fn AStar::apply_move_step(
  self : AStar,
  icollider : TCellValue,
  nextPos : Vector3,
  lastIPos : Vector2I,
  lastClosed : Vector2I,
) -> Int {
  let nextIPos = Vector2I::zero()
  self.to_ipos(nextPos, nextIPos)
  if false == nextIPos.equal(lastIPos) {
    let nextIndex = self.ipos_to_index(nextIPos)
    let lastIndex = self.ipos_to_index(lastIPos)
    // let lastClosedIndex = self.ipos_to_index(lastClosed)
    lastClosed.merge(lastIPos)
    lastIPos.merge(nextIPos)
    // self.try_remove_lock(lastClosedIndex, icollider)
    self.try_remove_lock(lastIndex, icollider)
    // self.try_add_lock(lastIndex, icollider)
    self.try_add_lock(nextIndex, icollider)
    nextIndex
  } else {
    let lastIndex = self.ipos_to_index(lastIPos)
    lastIndex
  }
}

///|
pub fn AStar::get_move_step(
  self : AStar,
  icollider : TCellValue,
  lastIPos : Vector2I,
  lastClosed : Vector2I,
  nextOccupy : Vector2I,
  nextOccupyPos : Vector3,
  curPos : Vector3,
  nextPos : Vector3,
  tempPos : Vector3,
) -> Vector3 {
  let curIPos : Vector2I = self.sharedCurIPos
  let nextIPos : Vector2I = self.sharedNextIPos
  self.to_ipos(curPos, curIPos)
  self.to_ipos(nextPos, nextIPos)
  let grid = self.grid
  let curIndex = self.ipos_to_index(curIPos)
  // let cellValue0 = grid[curIndex]
  // if cellValue0 != CellValueDefault && cellValue0 != icollider {
  //   // 当前位置已经被其他怪物占据, 或者处于战场外, 那么无视地形先朝目标移动
  //   return nextPos
  // }
  let lastIndex = self.ipos_to_index(lastIPos)
  let nextOccupyIndex = self.ipos_to_index(nextOccupy)
  if curIndex == lastIndex {
    if nextOccupyIndex != curIndex && grid[nextOccupyIndex] == icollider {
      // 起点相同, 下一步不为起点, 且下一步落脚点已独占, 说明已经有下一步落脚点
      return nextOccupyPos
    }
  }
  if nextOccupyIndex != lastIndex {
    // 失效及时移除
    self.try_remove_lock(nextOccupyIndex, icollider)
  }
  let lastClosedIndex0 = self.ipos_to_index(lastClosed)
  let mut lastClosedIndex = lastClosedIndex0
  let nextIndex = self.ipos_to_index(nextIPos)
  let curIPosX = curIPos.x
  let curIPosY = curIPos.y
  // 如果位置变动, lastClosed 失效
  let lastClosedValid = if lastIndex == curIndex {
    // 没有移动, lastClosed 不变
    curIndex != lastClosedIndex
  } else if (curIPosX - lastIPos.x).abs() <= 1 ||
    (curIPosY - lastIPos.y).abs() <= 1 {
    // 移动了一格, lastClosed 变为 lastIPos
    lastClosed.merge(lastIPos)
    lastClosedIndex = lastIndex
    true
  } else {
    // 移动过多, lastClosed 失效, 重置为 curIPos
    lastClosed.merge(curIPos)
    lastClosedIndex = curIndex
    false
  }
  self.try_remove_lock(lastIndex, icollider)
  // self.try_remove_lock(lastClosedIndex0, icollider)
  self.try_add_lock(curIndex, icollider)
  // self.try_add_lock(lastClosedIndex, icollider)
  // let lastClosedValid = lastIndex == curIndex
  let nextIPosX = nextIPos.x
  let nextIPosY = nextIPos.y
  let dirX = nextIPosX - curIPosX
  let dirY = nextIPosY - curIPosY
  // let dirLenF = (dirX*dirX+dirY*dirY).to_float().sqrt()*(0.5:Float)
  let dirXAF = dirX.abs().to_float()
  let dirYAF = dirY.abs().to_float()
  let dirLenF = if dirXAF == dirYAF {
    dirXAF * (1.414 : Float)
  } else {
    fastIFSqrt(dirX * dirX + dirY * dirY) * (0.5 : Float)
    // @cmp.maximum(dirXAF, dirYAF)
  }
  let dirLenH = -dirLenF.to_int()
  let dirLen2qH = -(dirLenF * (1.414 : Float)).to_int()
  // (!exist) && (!lastvalid || closeindex!=predictIndex)
  // if(!exist){
  //   if(lastvalid){
  //    closeindex != predictIndex
  //   }else{
  //     true
  //   }
  // }else{
  //   false
  // }
  // vt1
  let predict1x = curIPosX + 1
  let predict1y = curIPosY
  let predict1Index = self.ipos2_to_index(predict1x, predict1y)
  // 右
  let vt1 = if (false == lastClosedValid || lastClosedIndex != predict1Index) &&
    dirX >= dirLenH &&
    false == self.exist1(predict1Index) {
    calc_gh((predict1x - curIPosX).abs(), (predict1y - curIPosY).abs()) +
    calc_gh((predict1x - nextIPosX).abs(), (predict1y - nextIPosY).abs())
  } else {
    @float.max_value
  }
  // vt3
  let predict3x = curIPosX
  let predict3y = curIPosY + 1
  let predict3Index = self.ipos2_to_index(predict3x, predict3y)
  // 上
  let vt3 = if (false == lastClosedValid || lastClosedIndex != predict3Index) &&
    dirY >= dirLenH &&
    false == self.exist1(predict3Index) {
    calc_gh((predict3x - curIPosX).abs(), (predict3y - curIPosY).abs()) +
    calc_gh((predict3x - nextIPosX).abs(), (predict3y - nextIPosY).abs())
  } else {
    @float.max_value
  }
  // vt5
  let predict5x = curIPosX - 1
  let predict5y = curIPosY
  let predict5Index = self.ipos2_to_index(predict5x, predict5y)
  // 左
  let vt5 = if (false == lastClosedValid || lastClosedIndex != predict5Index) &&
    -dirX >= dirLenH &&
    false == self.exist1(predict5Index) {
    calc_gh((predict5x - curIPosX).abs(), (predict5y - curIPosY).abs()) +
    calc_gh((predict5x - nextIPosX).abs(), (predict5y - nextIPosY).abs())
  } else {
    @float.max_value
  }
  // vt7
  let predict7x = curIPosX
  let predict7y = curIPosY - 1
  let predict7Index = self.ipos2_to_index(predict7x, predict7y)
  // 下
  let vt7 = if (false == lastClosedValid || lastClosedIndex != predict7Index) &&
    -dirY >= dirLenH &&
    false == self.exist1(predict7Index) {
    calc_gh((predict7x - curIPosX).abs(), (predict7y - curIPosY).abs()) +
    calc_gh((predict7x - nextIPosX).abs(), (predict7y - nextIPosY).abs())
  } else {
    @float.max_value
  }
  // vt2
  let predict2x = curIPosX + 1
  let predict2y = curIPosY + 1
  let predict2Index = self.ipos2_to_index(predict2x, predict2y)
  // 右上
  let vt2 = if (false == lastClosedValid || lastClosedIndex != predict2Index) &&
    (vt1 < @float.max_value && vt3 < @float.max_value) &&
    dirX + dirY >= dirLen2qH &&
    false == self.exist1(predict2Index) {
    calc_gh((predict2x - curIPosX).abs(), (predict2y - curIPosY).abs()) +
    calc_gh((predict2x - nextIPosX).abs(), (predict2y - nextIPosY).abs())
  } else {
    @float.max_value
  }
  // vt4
  let predict4x = curIPosX - 1
  let predict4y = curIPosY + 1
  let predict4Index = self.ipos2_to_index(predict4x, predict4y)
  // 左上
  let vt4 = if (false == lastClosedValid || lastClosedIndex != predict4Index) &&
    (vt3 < @float.max_value && vt5 < @float.max_value) &&
    -dirX + dirY >= dirLen2qH &&
    false == self.exist1(predict4Index) {
    calc_gh((predict4x - curIPosX).abs(), (predict4y - curIPosY).abs()) +
    calc_gh((predict4x - nextIPosX).abs(), (predict4y - nextIPosY).abs())
  } else {
    @float.max_value
  }
  // vt6
  let predict6x = curIPosX - 1
  let predict6y = curIPosY - 1
  let predict6Index = self.ipos2_to_index(predict6x, predict6y)
  // 左下
  let vt6 = if (false == lastClosedValid || lastClosedIndex != predict6Index) &&
    (vt5 < @float.max_value && vt7 < @float.max_value) &&
    -dirX - dirY >= dirLen2qH &&
    false == self.exist1(predict6Index) {
    calc_gh((predict6x - curIPosX).abs(), (predict6y - curIPosY).abs()) +
    calc_gh((predict6x - nextIPosX).abs(), (predict6y - nextIPosY).abs())
  } else {
    @float.max_value
  }
  // vt8
  let predict8x = curIPosX + 1
  let predict8y = curIPosY - 1
  let predict8Index = self.ipos2_to_index(predict8x, predict8y)
  // 右下
  let vt8 = if (false == lastClosedValid || lastClosedIndex != predict8Index) &&
    (vt1 < @float.max_value && vt7 < @float.max_value) &&
    dirX - dirY >= dirLen2qH &&
    false == self.exist1(predict8Index) {
    calc_gh((predict8x - curIPosX).abs(), (predict8y - curIPosY).abs()) +
    calc_gh((predict8x - nextIPosX).abs(), (predict8y - nextIPosY).abs())
  } else {
    @float.max_value
  }
  // 1右2上3左4下
  if vt1 == @float.max_value &&
    vt2 == @float.max_value &&
    vt3 == @float.max_value &&
    vt4 == @float.max_value &&
    vt5 == @float.max_value &&
    vt6 == @float.max_value &&
    vt7 == @float.max_value &&
    vt8 == @float.max_value {
    // 四个方向都被堵死, 停止移动
    // TODO: 优化成在格子内尽量靠近目的地
    return curPos
  }
  let minValue = @math2.min8f(vt1, vt2, vt3, vt4, vt5, vt6, vt7, vt8)
  let offsetX = nextIPosX - curIPos.x
  let offsetY = nextIPosY - curIPos.y
  let offsetXDH = offsetX.abs() / 2
  let offsetYDH = offsetY.abs() / 2
  let index = if offsetXDH > offsetYDH * 2 {
    if offsetX > 0 {
      compare1(minValue, vt1, vt2, vt8, vt3, vt7, vt4, vt6, vt5)
    } else {
      compare2(minValue, vt5, vt6, vt4, vt7, vt3, vt8, vt2, vt1)
    }
  } else if offsetXDH * 2 < offsetYDH {
    if offsetY > 0 {
      compare3(minValue, vt3, vt4, vt2, vt5, vt1, vt6, vt8, vt7)
    } else {
      compare4(minValue, vt7, vt8, vt6, vt1, vt5, vt2, vt4, vt3)
    }
  } else if offsetX > 0 {
    if offsetY > 0 {
      compare5(minValue, vt2, vt3, vt1, vt4, vt8, vt5, vt7, vt6)
    } else {
      compare6(minValue, vt6, vt7, vt5, vt8, vt4, vt1, vt3, vt2)
    }
  } else if offsetY > 0 {
    compare7(minValue, vt4, vt5, vt3, vt6, vt2, vt7, vt1, vt8)
  } else {
    compare8(minValue, vt8, vt1, vt7, vt2, vt6, vt3, vt5, vt4)
  }
  let nextStepIndex = match index {
    1 => predict1Index
    2 => predict2Index
    3 => predict3Index
    4 => predict4Index
    5 => predict5Index
    6 => predict6Index
    7 => predict7Index
    8 => predict8Index
    _ => thrown("invalid index: \{index}")
  }
  // if nextStepIndex != curIndex {
  //   // 移动到下一格
  //   lastClosed.merge(curIPos)
  //   lastIPos.merge(inextStep)
  //   self.remove_lock(curIndex)
  //   self.remove_lock(lastClosedIndex)
  //   self.add_lock(curIndex, icollider)
  //   self.add_lock(nextStepIndex, icollider)
  // }
  let nextStepPos = if nextStepIndex == nextIndex {
    // 目的地在下一步格子内, 直接前往目的地坐标
    nextPos
  } else {
    // 目的地不在下一步格子内, 先去下一步格子内
    // let tempPos = Vector3::zero()
    match index {
      1 => self.to_pos2(predict1x, predict1y, tempPos)
      2 => self.to_pos2(predict2x, predict2y, tempPos)
      3 => self.to_pos2(predict3x, predict3y, tempPos)
      4 => self.to_pos2(predict4x, predict4y, tempPos)
      5 => self.to_pos2(predict5x, predict5y, tempPos)
      6 => self.to_pos2(predict6x, predict6y, tempPos)
      7 => self.to_pos2(predict7x, predict7y, tempPos)
      8 => self.to_pos2(predict8x, predict8y, tempPos)
      _ => thrown("invalid index: \{index}")
    }
    if grid[nextStepIndex] == 0 {
      grid[nextStepIndex] = icollider
      nextOccupyPos.merge(tempPos)
      self.to_ipos(tempPos, nextOccupy)
    }
    tempPos
  }
  nextStepPos
}
