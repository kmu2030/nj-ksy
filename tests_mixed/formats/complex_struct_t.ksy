meta:
  id: complex_struct_t
  application:
    - Sysmac Studio
  license: MIT
  imports:
    - ../../nj
    # alignment2_struct_t
    # - ../../tests_struct/formats/alignment2_struct_t
    - alignment2_struct_t
    - alignment4_union_t
  encoding: UTF-8
  endian: le
  bit-endian: le

types:
  # Defined in `types` to make it a non-root element.
  complex_struct:
    seq:
      - id: struct_begin
        type: nj::struct_begin('complex_struct', 8)

      - id: a_usint
        type: nj::usint
      - id: alignment2_structs
        type: alignment2_struct_t::alignment2_struct_array_1d(2)
      - id: a_alignment4_union
        type: alignment4_union_t::alignment4_union
      - id: a_bool
        type: nj::bool
      - id: lints
        type: nj::lint_array_1d(2)
      - id: a_enum
        type: nj::enum_t

      - id: struct_end
        type: nj::struct_end(struct_begin)
    instances:
      block_info:
        value: struct_end.struct_block_info

  complex_struct_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: complex_struct
    instances:
      alignment:
        value: v[0].struct_end.alignment
      padding:
        value: v[0].struct_end.struct_padding
      size:
        value: padding + v[0].block_info.len_data * x
      cardinalities:
        value: '[x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, x)

  complex_struct_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: complex_struct_array_1d(x)
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

  complex_struct_array_3d:
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
        type: complex_struct_array_2d(y, x)
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

  complex_struct_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: complex_struct
    instances:
      alignment:
        value: v[0].struct_end.alignment
      padding:
        value: v[0].struct_end.struct_padding
      size:
        value: padding + v[0].block_info.len_data * x
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)

  complex_struct_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y * x 
        type: complex_struct
    instances:
      alignment:
        value: v[0].struct_end.alignment
      padding:
        value: v[0].struct_end.struct_padding
      size:
        value: padding + v[0].block_info.len_data * x * y
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)

  complex_struct_array_3df:
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
        type: complex_struct
    instances:
      alignment:
        value: v[0].struct_end.alignment
      padding:
        value: v[0].struct_end.struct_padding
      size:
        value: padding + v[0].block_info.len_data * x * y * z
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)
