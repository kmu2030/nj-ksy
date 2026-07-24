meta:
  id: uint_flat_array
  imports:
    - ../nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: array_1d
    type: nj::uint_array_1df(3)

  - id: array_2d
    type: nj::uint_array_2df(3, 3)

  - id: array_3d
    type: nj::uint_array_3df(3, 3, 3)
