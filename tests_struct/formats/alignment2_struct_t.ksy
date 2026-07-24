meta:
  id: alignment2_struct_t
  application:
    - Sysmac Studio
  license: MIT
  imports:
    - ../../nj
  encoding: UTF-8
  endian: le
  bit-endian: le

types:
  # Defined in `types` to make it a non-root element.
  alignment2_struct:
    seq:
      - id: struct_begin
        type: nj::struct_begin('alignment2_struct', 2)

      - id: a_bool
        type: nj::bool
      - id: a_uint
        type: nj::uint
      - id: a_int
        type: nj::int
      - id: bools
        type: nj::bool_array_1d(4)

      - id: struct_end
        type: nj::struct_end(struct_begin)
    instances:
      block_info:
        value: struct_end.struct_block_info

  alignment2_struct_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: alignment2_struct
    instances:
      alignment:
        value: v[0].struct_end.alignment
      padding:
        value: v[0].struct_end.padding
      size:
        value: padding + v[0].block_info.len_data * x
      cardinalities:
        value: '[x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, x)

  alignment2_struct_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: alignment2_struct_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + v[0].block_info.len_data * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  alignment2_struct_array_3d:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: z + 0
        type: alignment2_struct_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + v[0].block_info.len_data * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  alignment1_struct_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: alignment2_struct
    instances:
      alignment:
        value: v[0].struct_end.alignment
      padding:
        value: v[0].struct_end.padding
      size:
        value: padding + v[0].block_info.len_data * x
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)

  alignment2_struct_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y * x 
        type: alignment2_struct
    instances:
      alignment:
        value: v[0].struct_end.alignment
      padding:
        value: v[0].struct_end.padding
      size:
        value: padding + v[0].block_info.len_data * x * y
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)

  alignment2_struct_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: z * y * x 
        type: alignment2_struct
    instances:
      alignment:
        value: v[0].struct_end.alignment
      padding:
        value: v[0].struct_end.padding
      size:
        value: padding + v[0].block_info.len_data * x * y * z
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)
