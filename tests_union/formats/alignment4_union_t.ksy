meta:
  id: alignment4_union_t
  imports:
    # - ../../nju
    - ../../nj
  encoding: UTF-8
  endian: le
  bit-endian: le

types:
  alignment4_union:
    seq:
      - id: union_begin
        type: nj::union_begin('alignment4_union', 4)
        
      - id: bytes
        type: nj::u_byte_array_1d(4)
      - id: dwords 
        type: nj::u_dword_array_1d(2)

      - id: union_end
        type: nj::union_end(union_begin, [bytes.block_info, dwords.block_info])
    instances:
      block_info:
        value: union_end.union_block_info

  alignment4_union_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: alignment4_union
    instances:
      alignment:
        value: v[0].union_end.alignment
      padding:
        value: v[0].union_end.union_padding
      size:
        value: padding + v[0].block_info.len_data * x
      cardinalities:
        value: '[x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, x)

  alignment4_union_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: alignment4_union_array_1d(x)
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

  alignment4_union_array_3d:
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
        type: alignment4_union_array_2d(y, x)
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

  alignment4_union_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: alignment4_union
    instances:
      alignment:
        value: v[0].union_end.alignment
      padding:
        value: v[0].union_end.union_padding
      size:
        value: padding + v[0].block_info.len_data * x
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)

  alignment4_union_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y * x 
        type: alignment4_union
    instances:
      alignment:
        value: v[0].union_end.alignment
      padding:
        value: v[0].union_end.union_padding
      size:
        value: padding + v[0].block_info.len_data * x * y
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)

  alignment4_union_array_3df:
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
        type: alignment4_union
    instances:
      alignment:
        value: v[0].union_end.alignment
      padding:
        value: v[0].union_end.union_padding
      size:
        value: padding + v[0].block_info.len_data * x * y * z
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)
