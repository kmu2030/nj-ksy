meta:
  id: fixed_align
  imports:
    - ../../nj
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  - type: u1 # Set the stream position to a non-zero value.
  - id: block
    type: nj::single_block(16, true)
instances:
  align2_p0:
    io: block.io_block
    pos: 0
    type: nj::align2(0)
  align2_p1:
    io: block.io_block
    pos: 1
    type: nj::align2(1)
  align2_p2:
    io: block.io_block
    pos: 2
    type: nj::align2(2)

  align4_p0:
    io: block.io_block
    pos: 0
    type: nj::align4(0)
  align4_p1:
    io: block.io_block
    pos: 3
    type: nj::align4(1)
  align4_p2:
    io: block.io_block
    pos: 2
    type: nj::align4(2)
  align4_p3:
    io: block.io_block
    pos: 3
    type: nj::align4(3)
  align4_p4:
    io: block.io_block
    pos: 4
    type: nj::align4(4)

  align8_p0:
    io: block.io_block
    pos: 0
    type: nj::align8(0)
  align8_p1:
    io: block.io_block
    pos: 1
    type: nj::align8(1)
  align8_p2:
    io: block.io_block
    pos: 2
    type: nj::align8(2)
  align8_p3:
    io: block.io_block
    pos: 3
    type: nj::align8(3)
  align8_p4:
    io: block.io_block
    pos: 4
    type: nj::align8(4)
  align8_p5:
    io: block.io_block
    pos: 5
    type: nj::align8(5)
  align8_p6:
    io: block.io_block
    pos: 6
    type: nj::align8(6)
  align8_p7:
    io: block.io_block
    pos: 7
    type: nj::align8(7)
  align8_p8:
    io: block.io_block
    pos: 8
    type: nj::align8(8)
