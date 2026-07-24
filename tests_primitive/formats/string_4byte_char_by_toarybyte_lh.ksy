meta:
  id: string_4byte_char_by_toarybyte_lh
  imports:
    - ../../nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: v
    type: nj::string(16)
instances:
  raw:
    io: _io
    pos: v.block_info.pos_data
    size: 4 * v.v.length