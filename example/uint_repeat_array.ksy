meta:
  id: uint_repeat_array
  imports:
    - ../nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: array_1d
    type: nj::uint
    repeat: expr
    repeat-expr: 3
    
  - id: array_2d
    type: nj::uint
    repeat: expr
    repeat-expr: 3 * 3

  - id: array_3d
    type: nj::uint
    repeat: expr
    repeat-expr: 3 * 3 * 3
