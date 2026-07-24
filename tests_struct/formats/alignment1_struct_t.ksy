meta:
  id: alignment1_struct_t
  application:
    - Sysmac Studio
  license: MIT
  imports:
    - ../../nj
  encoding: UTF-8
  endian: le
  bit-endian: le

# seq:
#   - id: struct_begin
#     type: nj::struct_begin('alignment1_struct', 1)

#   - id: a_usint
#     type: nj::usint
#   - id: a_sint
#     type: nj::sint
#   - id: bytes
#     type: nj::byte_array_1d(2)

#   - id: struct_end
#     type: nj::struct_end(struct_begin)
# instances:
#   block_info:
#     value: struct_end.struct_block_info

types:
  # Defined in `types` to make it a non-root element.
  alignment1_struct:
    seq:
      - id: struct_begin
        type: nj::struct_begin('alignment1_struct', 1)

      - id: a_usint
        type: nj::usint
      - id: a_sint
        type: nj::sint
      - id: bytes
        type: nj::byte_array_1d(2)

      - id: struct_end
        type: nj::struct_end(struct_begin)
    instances:
      block_info:
        value: struct_end.struct_block_info

  # To reduce the constraints on field declarations,
  # each element is isolated into an internal type.
  # internal:
  #   instances:
  #     alignment:
  #       value: _parent.struct_end.alignment
  #     padding:
  #       value: _parent.struct_end.struct_padding
  #     size:
  #       value: _parent.struct_end.struct_size
  #     block_info:
  #       value: _parent.struct_end.struct_block_info
  #     fields:
  #       type: fields
  #       parent: _parent
  #     struct_info:
  #       type: >-
  #         nj::struct_info(
  #           _parent.struct_end,
  #           ['a_usint', 'a_sint', 'bytes'],
  #           [_parent.a_usint.block_info, _parent.a_sint.block_info, _parent.bytes.block_info]
  #         )
  #     to_ksy:
  #       type: ksygen::to_ksy(struct_info, '_view', true)
  #     block_view_ksy:
  #       value: to_ksy.block_view_ksy.value
  #     seq_ksy:
  #       value: to_ksy.seq_ksy.value

  # fields:
  #   instances:
  #     a_usint:
  #       value: _parent.a_usint.v
  #     a_sint:
  #       value: _parent.a_sint.v
  #     bytes:
  #       value: _parent.bytes.v

  alignment1_struct_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: alignment1_struct
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

  alignment1_struct_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: alignment1_struct_array_1d(x)
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

  alignment1_struct_array_3d:
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
        type: alignment1_struct_array_2d(y, x)
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
        type: alignment1_struct
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

  alignment1_struct_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y * x 
        type: alignment1_struct
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

  alignment1_struct_array_3df:
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
        type: alignment1_struct
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
