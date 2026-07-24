meta:
  id: uint_array
  imports:
    - ../nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: array_1d
    type: nj::uint_array_1d(3)

  - id: array_2d
    type: nj::uint_array_2d(3, 3)

  - id: array_3d
    type: nj::uint_array_3d(3, 3, 3)
