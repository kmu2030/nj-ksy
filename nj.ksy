# Copyright (c) 2026 KITA Munemitsu
# This script is released under the GNU General Public License v3.0.
# SPDX-License-Identifier: GPL-3.0-or-later

meta:
  id: nj
  title: NJ Memory Layout Definition Framework
  application:
    - Sysmac Studio
  license: GPL-3.0-or-later
  ks-version: 0.11
  encoding: UTF-8
  endian: le
  bit-endian: le

doc: |
  Set of definitions representing NJ layout data types in Sysmac Studio.

  [ Struct Definition ]

  Type Mapping Table:
  +---------------+-----------+----------------------------------------------+------------------------------------+
  |     Type      | Alignment |              NJ ksy Definition               |             Value Type             |
  +---------------+-----------+----------------------------------------------+------------------------------------+
  | USINT         |         1 | nj::usint, nj::usint_array_*                 | u1                                 |
  | UINT          |         2 | nj::uint, nj::uint_array_*                   | u2                                 |
  | UDINT         |         4 | nj::udint, nj::udint_array_*                 | u4                                 |
  | ULINT         |         8 | nj::ulint, nj::ulint_array_*                 | u8                                 |
  | SINT          |         1 | nj::sint, nj::sint_array_*                   | s1                                 |
  | INT           |         2 | nj::int, nj::int_array_*                     | s2                                 |
  | DINT          |         4 | nj::dint, nj::dint_array_*                   | s4                                 |
  | LINT          |         8 | nj::lint, nj::lint_array_*                   | s8                                 |
  | BOOL          |         2 | nj::bool, nj::bool_array_*                   | b1  (2-byte unit frame)            |
  | BYTE          |         1 | nj::byte, nj::byte_array_*                   | u1                                 |
  | WORD          |         2 | nj::word, nj::word_array_*                   | u2                                 |
  | DWORD         |         4 | nj::dword, nj::dword_array_*                 | u4                                 |
  | LWORD         |         8 | nj::lword, nj::lword_array_*                 | u8                                 |
  | REAL          |         8 | nj::real, nj::real_array_*                   | f4                                 |
  | LREAL         |         8 | nj::lreal, nj::lreal_array_*                 | f8                                 |
  | STRING        |         1 | nj::string                                   | str (encoding=UTF-8, terminator=0) |
  | TIME          |         8 | nj::time, nj::time_array_*                   | s8  (nanosecond scale)             |
  | DATE          |         8 | nj::date, nj::date_array_*                   | u8  (Unix time in nanoseconds)     |
  | TIME_OF_DAY   |         8 | nj::time_of_day, nj::time_of_day_array_*     | u8  (Unix time in nanoseconds)     |
  | DATE_AND_TIME |         8 | nj::date_and_time, nj::date_and_time_array_* | u8  (Unix time in nanoseconds)     |
  | Enum          |         4 | nj::enum_t, nj::enum_t_array_*               | u4                                 |
  +---------------+-----------+----------------------------------------------+------------------------------------+

  Auxiliary types:
  nj::time_t       : Provides a representation of the TIME type.
  nj::time_of_day_t: Provides a representation of the TIME_OF_DAY type.

  e.g. example_struct:
  ```ksy
  meta:
    id: example_struct
    imports:
      - nj
    encoding: UTF-8
    endian: le
    bit-endian: le
  seq:
    # Be sure to define the fields between `nj::struct_begin` and `nj::struct_end`.

    # Start the struct definition.
    # The alignment matches the maximum alignment of the fields.
    - id: struct_begin
      type: nj::struct_begin('example_struct', 8) # Pass the type identifier and alignment.

    # Define fields.
    # Define them in the same order as the structure definition in Sysmac Studio.

    - id: vel
      type: nj::lreal
    - id: trq
      type: nj::lreal
    - id: acc
      type: nj::lreal
    - id: status_code
      type: nj::dword

    # Complete the struct definition.
    - id: struct_end
      type: nj::struct_end(struct_begin) # Please pass the defined `nj::struct_begin`.
  instances:
    # Specifying this allows it to be incorporated into other types.
    block_info:
      value: struct_end.struct_block_info
  ```

  Access the fields as follows:

  ```
  Instance.vel.v # Non-array primitive types are accessed via the `v` property.
  Instance.trq.v
  Instance.statusCode.v
  ```

  [ Union Definition ]

  Type Mapping Table:
  +---------------+-----------+----------------------------------------------+------------------------------------+
  |     Type      | Alignment |              NJ ksy Definition               |             Value Type             |
  +---------------+-----------+----------------------------------------------+------------------------------------+
  | BOOL          |         2 | nj::u_bool, nj::u_bool_array_*               | b1  (2-byte unit frame)            |
  | BYTE          |         1 | nj::u_byte, nj::u_byte_array_*               | u1                                 |
  | WORD          |         2 | nj::u_word, nj::u_word_array_*               | u2                                 |
  | DWORD         |         4 | nj::u_dword, nj::u_dword_array_*             | u4                                 |
  | LWORD         |         8 | nj::u_lword, nj::u_lword_array_*             | u8                                 |
  +---------------+-----------+----------------------------------------------+------------------------------------+

  e.g. example_union:
  ```ksy
  meta:
    id: example_union
    imports:
      - nj
    encoding: UTF-8
    endian: le
    bit-endian: le
  seq:
    # Be sure to define the fields between `nj::union_begin` and `nj::union_end`.

    # Start the union definition.
    # The alignment matches the maximum alignment of the fields.
    - id: union_begin
      type: nj::union_begin('example_union', 4) # Pass the type identifier and alignment.

    # Define fields.
    - id: status_flags
      type: nj::u_bool_array_1d(16)
    - id: segmented_status_codes
      type: nj::u_word_array_1d(2)
    - id: status_code
      type: nj::u_dword

    # Complete the union definition.
    # Please pass the defined `nj::union_begin` and the `block_info` array for the defined field.
    - id: union_end
      type: nj::union_end(union_begin, [status_flags.block_info, segmented_status_codes.block_info, status_code.block_info]) 
  instances:
    # Specifying this allows it to be incorporated into other types.
    block_info:
      value: union_end.union_block_info
  ```

  Access the fields as follows:

  ```
  Instance.statusFlags.v[0] # Array types reference the value directly.
  Instance.segmentedStatusCodes.v[1]
  Instance.statusCode.v
  ```

types:
  # Define util types.

  align2:
    seq:
      - id: pad
        type: u1
        repeat: expr
        repeat-expr: (2 - (_io.pos % 2)) % 2
    instances:
      size:
        value: pad.size

  align4:
    seq:
      - id: pad
        type: u1
        repeat: expr
        repeat-expr: (4 - (_io.pos % 4)) % 4
    instances:
      size:
        value: pad.size

  align8:
    seq:
      - id: pad
        type: u1
        repeat: expr
        repeat-expr: (8 - (_io.pos % 8)) % 8
    instances:
      size:
        value: pad.size

  align:
    params:
      - id: n
        type: u1
    seq:
      - id: pad
        type: u1
        repeat: expr
        repeat-expr: (n - (_io.pos % n)) % n
    instances:
      size:
        value: pad.size

  struct_begin:
    params:
      - id: struct_type
        type: str
      - id: alignment
        type: u1
    seq:
      - id: head
        type: pos_capturer(_io.pos)
      - id: pad
        type: u1
        repeat: expr
        repeat-expr: (alignment - (_io.pos % alignment)) % alignment
    instances:
      padding:
        value: pad.size

  struct_end:
    params:
      - id: s
        type: struct_begin
    seq:
      - id: head
        type: pos_capturer(_io.pos)
      - id: pad
        type: u1
        repeat: expr
        repeat-expr: (s.alignment - (_io.pos % s.alignment)) % s.alignment
    instances:
      alignment:
        value: s.alignment
      padding:
        value: pad.size
      struct_padding:
        value: s.padding
      struct_size:
        value: head.value + padding - s.head.value
      struct_type:
        value: s.struct_type
      struct_block_info:
        type: block_info(s.head.value, struct_size, s.head.value + s.padding, struct_type, 0)
      struct_data_size:
        value: struct_size - struct_padding - padding

  # NOTE: If there are many problems, split the file.
  union_begin:
    params:
      - id: union_type
        type: str
      - id: alignment
        type: u1
    seq:
      - id: p
        type: align(alignment)
      - id: h
        type: pos_capturer(_io.pos)
    instances:
      io:
        value: _io
      pos_data:
        value: h.value
      pos_block:
        value: h.value + padding
      padding:
        value: p.size

  union_end:
    params:
      - id: b
        type: union_begin
      - id: fields
        type: block_info[]
    seq:
      - id: block
        type: single_block(len_block, false)
    instances:
      alignment:
        value: b.alignment
      union_padding:
        value: b.padding
      union_type:
        value: b.union_type
      union_size:
        value: len_block + union_padding
      union_data_size:
        value: len_block
      union_block_info:
        type: block_info(b.pos_block, union_size, b.pos_data, b.union_type, 0)
      max_data_len_index:
        type: max_data_len_block_index(fields, 0)
      len_block:
        value: fields[max_data_len_index.value].len_data

  max_data_len_block_index:
    params:
      - id: blocks
        type: block_info[]
      - id: index
        type: u2
    instances:
      next_element:
        type: max_data_len_block_index(blocks, index + 1)
        if: blocks.size - index > 1
      value:
        value: >-
          (
          (blocks.size < 2 or blocks.size - index < 2) ? index :
          (blocks[next_element.value].len_data < blocks[index].len_data ? index : next_element.value)
          ).as<u2>

  array_context:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    instances:
      length:
        value: z * y * x

  struct_info:
    params:
      - id: ctx
        type: struct_end
      - id: field_ids
        type: str[]
      - id: field_infos
        type: block_info[]
    instances:
      alignment:
        value: ctx.alignment
      padding:
        value: ctx.struct_padding
      tail_padding:
        value: ctx.padding
      size:
        value: ctx.struct_size
      data_size:
        value: ctx.struct_data_size
      struct_type:
        value: ctx.struct_type
      as_container_info:
        type: >-
          container_info(field_ids,field_infos,alignment,padding,tail_padding,size,data_size,struct_type)

  union_info:
    params:
      - id: ctx
        type: union_end
      - id: field_ids
        type: str[]
      - id: field_infos
        type: block_info[]
    instances:
      alignment:
        value: ctx.alignment
      padding:
        value: ctx.union_padding
      tail_padding:
        value: 0
      size:
        value: ctx.union_size
      data_size:
        value: ctx.union_data_size
      struct_type:
        value: ctx.union_type
      as_container_info:
        type: >-
          container_info(field_ids,field_infos,alignment,padding,tail_padding,size,data_size,struct_type)

  container_info:
    params:
      - id: field_ids
        type: str[]
      - id: field_infos
        type: block_info[]
      - id: alignment
        type: u1
      - id: padding
        type: u1
      - id: tail_padding
        type: u1
      - id: size
        type: u4
      - id: data_size
        type: u4
      - id: struct_type
        type: str

  single_block:
    params:
      - id: len_block
        type: u2
      - id: as_stream
        type: b1
    seq:
      - id: stream_block
        type: block(len_block)
        size: len_block + 0
        if: as_stream
      - id: block
        type: block(len_block)
        if: not as_stream
    instances:
      io_block:
        value: 'as_stream ? stream_block._io : block._io'
  
  block:
    params:
      - id: len_mem
        type: u2
    seq:
      - id: mem
        size: len_mem

  # NOTE: switch-on version.
  # single_block:
  #   params:
  #     - id: len_block
  #       type: u2
  #     - id: as_stream
  #       type: b1
  #   seq:
  #     - id: block
  #       type:
  #         switch-on: as_stream
  #         cases:
  #           true: stream_block(len_block)
  #           false: block(len_block)
  #   instances:
  #     io_block:
  #       value: 'as_stream ? block.as<stream_block>.block._io : block._io'
  # block:
  #   params:
  #     - id: len_mem
  #       type: u2
  #   seq:
  #     - id: mem
  #       size: len_mem
  # stream_block:
  #   params:
  #     - id: len_block
  #       type: u2
  #   seq:
  #     - id: block
  #       type: block(len_block)
  #       size: len_block

  aligned_block:
    params:
      - id: len_block
        type: u2
      - id: alignment_block
        type: u1
      - id: independent_io
        type: b1
    seq:
      - id: pad
        type: align(alignment_block)
      - id: head
        type: pos_capturer(_io.pos)
      - id: block
        type: single_block(len_block, independent_io)
    instances:
      alignment:
        value: alignment_block
      padding:
        value: pad.size
      size:
        value: pad.size + len_block
      io_block:
        value: block.io_block
      block_info:
        type: block_info(head.value - padding, size, head.value, 'u1', len_block)

  pos_capturer:
    params:
      - id: value
        type: u8

  block_info:
    params:
      - id: pos_block
        type: u4
      - id: len_block
        type: u4
      - id: pos_data
        type: u4
      - id: ks_type
        type: str
      - id: num_repeat
        type: u4
    instances:
      space:
        value: pos_block - pos_data
      len_data:
        value: len_block - (pos_data - pos_block)

  # Define primitive types.

  # USINT
  usint:
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: 1
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', 0)

  usint_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', x)

  usint_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: usint_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  usint_array_3d:
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
        type: usint_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  usint_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', length)

  usint_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', length)

  usint_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', length)

  # UINT
  uint:
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', 0)

  uint_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', x)

  uint_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: uint_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  uint_array_3d:
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
        type: uint_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  uint_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', length)

  uint_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', length)

  uint_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', length)

  # UDINT
  udint:
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u4
    instances:
      alignment:
        value: 4
      size:
        value: padding + alignment
      padding:
        value: p.size
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', 0)

  udint_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', x)

  udint_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: udint_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  udint_array_3d:
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
        type: udint_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  udint_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  udint_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  udint_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  # ULINT
  ulint:
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', 0)

  ulint_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', x)

  ulint_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: ulint_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  ulint_array_3d:
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
        type: ulint_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  ulint_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  ulint_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  ulint_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  # SINT
  sint:
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: s1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: 1
      block_info:
        type: block_info(h.value - padding, size, h.value, 's1', 0)

  sint_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: s1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's1', x)

  sint_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: sint_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  sint_array_3d:
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
        type: sint_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  sint_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: s1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's1', length)

  sint_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: s1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's1', length)

  sint_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: s1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's1', length)

  # INT
  int:
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: s2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 's2', 0)

  int_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: s2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's2', x)

  int_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: int_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  int_array_3d:
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
        type: int_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  int_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: s2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's2', length)

  int_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: s2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's2', length)

  int_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: s2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's2', length)

  # DINT
  dint:
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: s4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 's4', 0)

  dint_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: s4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's4', x)

  dint_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: dint_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  dint_array_3d:
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
        type: dint_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  dint_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: s4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's4', length)

  dint_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: s4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's4', length)

  dint_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: s4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's4', length)

  # LINT
  lint:
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', 0)

  lint_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', x)

  lint_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: lint_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  lint_array_3d:
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
        type: lint_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  lint_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', length)

  lint_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', length)

  lint_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', length)

  # REAL
  real:
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: f4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f4', 0)

  real_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: f4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f4', x)

  real_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: real_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  real_array_3d:
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
        type: real_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  real_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: f4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f4', length)

  real_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: f4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f4', length)

  real_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: f4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f4', length)

  # LREAL
  lreal:
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: f8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f8', 0)

  lreal_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: f8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f8', x)

  lreal_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: lreal_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  lreal_array_3d:
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
        type: lreal_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  lreal_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: f8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f8', length)

  lreal_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: f8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f8', length)

  lreal_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: f8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'f8', length)

  # STRING
  string:
    params:
      - id: len
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: str
        terminator: 0
        size: len
        encoding: UTF-8
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: len * alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'str', len)

  # BOOL
  bool:
    seq:
      - id: block
        type: aligned_block(2, alignment, true)
    instances:
      v:
        io: block.io_block
        pos: 0
        type: b1
      alignment:
        value: 2
      padding:
        value: block.padding
      size:
        value: block.size
      block_info:
        type: block_info(block.block_info.pos_block, block.block_info.len_block, block.block_info.pos_data, 'b1', 0)

  bool_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: instance
        type: bool_array(1, 1, x)
    instances:
      v:
        value: instance.v.v[0].v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[x]'
      block_info:
        value: instance.block_info

  bool_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: bool_array(1, y, x)
    instances:
      v:
        value: instance.v.v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[y, x]'
      block_info:
        value: instance.block_info

  bool_array_3d:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: bool_array(z, y, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[z, y, x]'
      block_info:
        value: instance.block_info

  bool_array:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        size: (((z * y * x) + 15) / 16) * 2
        type: bool_array_internal_d1(z, y, x)
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + (((z * y * x) + 15) / 16) * 2
      block_info:
        type: block_info(h.value - padding, size, h.value, 'b1', z * y * x)

  bool_array_internal_d1:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        type: bool_array_internal_d2(y, x)
        repeat: expr
        repeat-expr: z + 0

  bool_array_internal_d2:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        type: bool_array_internal_d3(x)
        repeat: expr
        repeat-expr: y + 0

  bool_array_internal_d3:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        type: b1
        repeat: expr
        repeat-expr: x + 0

  bool_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: instance
        type: bool_array_flat(1, 1, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        value: instance.block_info

  bool_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: bool_array_flat(1, y, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        value: instance.block_info

  bool_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: bool_array_flat(z, y, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        value: instance.block_info

  bool_array_flat:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        size: (((z * y * x) + 15) / 16) * 2
        type: bool_array_flat_internal(z, y, x)
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + (((z * y * x) + 15) / 16) * 2
      block_info:
        type: block_info(h.value - padding, size, h.value, 'b1', z * y * x)

  bool_array_flat_internal:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        type: b1
        repeat: expr
        repeat-expr: z * y * x

  # BYTE
  byte:
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: 1
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', 0)

  byte_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', x)

  byte_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: byte_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  byte_array_3d:
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
        type: byte_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  byte_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', length)

  byte_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', length)

  byte_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u1
    instances:
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u1', length)

  # WORD
  word:
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', 0)

  word_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', x)

  word_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: word_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  word_array_3d:
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
        type: word_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  word_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', length)

  word_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', length)

  word_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align2
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u2
    instances:
      alignment:
        value: 2
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u2', length)

  # DWORD
  dword:
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', 0)

  dword_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', x)

  dword_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: dword_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  dword_array_3d:
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
        type: dword_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  dword_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  dword_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  dword_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  # LWORD
  lword:
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', 0)

  lword_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', x)

  lword_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: lword_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  lword_array_3d:
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
        type: lword_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  lword_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  lword_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  lword_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  # TIME_OF_DAY
  time_of_day_t:
    params:
      - id: v
        type: u8
    instances:
      valid:
        value: timestamp >= 0 and timestamp <= 86400000000000
      timestamp:
        value : v % 86400000000000
      elapsed_ns:
        value: timestamp
      elapsed_us:
        value: timestamp / 1000
      elapsed_ms:
        value: timestamp / 1000000
      elapsed_sec:
        value: timestamp / 1000000000
      residual_ns:
        value: elapsed_ns % 1000000000
      hours:
        value: elapsed_sec / 3600
      miniutes:
        value: (elapsed_sec % 3600) / 60
      seconds:
        value: elapsed_sec % 60
      nano_seconds:
        value: timestamp % 1000
      micro_seconds:
        value: (timestamp % 1000000) / 1000
      milli_seconds:
        value: (timestamp % 1000000000) / 1000000
      to_s:
        value: |
          (hours < 10 ? '0' : '') + hours.to_s + ':'
          + (miniutes < 10 ? '0' : '') + miniutes.to_s + ':'
          + (seconds < 10 ? '0' : '') + seconds.to_s
          + (residual_ns > 0 ? '.' +residual_ns.to_s : '')

  time_of_day:
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        # type: time_of_day_t
        type: u8
        valid:
          min: 0
          max: 86399999999999
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', 0)

  time_of_day_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        # type: time_of_day_t
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', x)

  time_of_day_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: time_of_day_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  time_of_day_array_3d:
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
        type: time_of_day_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  time_of_day_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        # type: time_of_day_t
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  time_of_day_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        # type: time_of_day_t
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  time_of_day_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        # type: time_of_day_t
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  # TIME
  time_t:
    params:
      - id: v
        type: s8
    instances:
      valid:
        value: true
      sign:
        value: |
          v < 0 ? -1 : 1
      abs_elapsed:
        value : v * sign
      elapsed_ns:
        value: v
      elapsed_us:
        value: sign * (abs_elapsed / 1000)
      elapsed_ms:
        value: sign * (abs_elapsed / 1000000)
      elapsed_sec:
        value: sign * (abs_elapsed / 1000000000)
      abs_sec_of_day:
        value: (sign * elapsed_sec) % 86400
      abs_residual_ns:
        value: (sign * elapsed_ns) % 1000000000
      days:
        value: (sign * elapsed_sec) / 86400
      hours:
        value: abs_sec_of_day / 3600
      minutes:
        value: (abs_sec_of_day % 3600) / 60
      seconds:
        value: abs_sec_of_day % 60
      nano_seconds:
        value: abs_residual_ns % 1000
      micro_seconds:
        value: (abs_residual_ns % 1000000) / 1000
      milli_seconds:
        value: (abs_residual_ns % 1000000000) / 1000000
      to_s:
        value: |
          (sign > 0 ? '' : '-')
          + (days > 0 ? 'D' + days.to_s : '')
          + (hours > 0 or minutes > 0 or seconds > 0 or abs_residual_ns > 0 ? 'T' : '')
          + (hours > 0 ? 'H' + hours.to_s : '')
          + (minutes > 0 ? 'M' + minutes.to_s : '')
          + (seconds > 0 ? 'S' + seconds.to_s : '')
          + (abs_residual_ns > 0 ? ((seconds > 0 ? '.' : 'S0.') + abs_residual_ns.to_s) : '')

  time:
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        # type: time_t
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', 0)

  time_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        # type: time_t
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', x)

  time_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: time_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  time_array_3d:
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
        type: time_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  time_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        # type: time_t
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', length)

  time_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        # type: time_t
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', length)

  time_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        # type: time_t
        type: s8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 's8', length)

  # DATE
  date:
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', 0)

  date_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', x)

  date_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: date_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  date_array_3d:
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
        type: date_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  date_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  date_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  date_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  # DATE_AND_TIME
  date_and_time:
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', 0)

  date_and_time_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', x)

  date_and_time_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: date_and_time_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  date_and_time_array_3d:
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
        type: date_and_time_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  date_and_time_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  date_and_time_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  date_and_time_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align8
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u8
    instances:
      alignment:
        value: 8
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', length)

  # Define auxiliary types.

  # Enum Common
  enum_t:
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        type: u4
    instances:
      alignment:
        value: 4
      size:
        value: padding + alignment
      padding:
        value: p.size
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', 0)

  enum_t_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + alignment * x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u8', x)

  enum_t_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: enum_t_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  enum_t_array_3d:
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
        type: enum_t_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + alignment * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  enum_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  enum_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: y * x
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  enum_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: p
        type: align4
      - id: h
        type: pos_capturer(_io.pos)
      - id: v
        repeat: expr
        repeat-expr: z * y * x
        type: u4
    instances:
      alignment:
        value: 4
      padding:
        value: p.size
      size:
        value: padding + length * alignment
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: block_info(h.value - padding, size, h.value, 'u4', length)

  # Define union primitive types.

  u_bool:
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        value: instance.v
      instance:
        io: _io
        pos: pos.value
        type: u_bool_internal
      alignment:
        value: 2
      padding:
        value: 0
      size:
        value: alignment
      block_info:
        type: block_info(pos.value, size, pos.value, 'b1', 0)

  u_bool_internal:
    seq:
      - id: block
        type: single_block(2, true)
    instances:
      v:
        io: block.io_block
        pos: 0
        type: b1

  u_bool_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_bool_array(1, 1, x)
    instances:
      v:
        value: instance.v.v[0].v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[x]'
      block_info:
        value: instance.block_info

  u_bool_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_bool_array(1, y, x)
    instances:
      v:
        value: instance.v.v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[y, x]'
      block_info:
        value: instance.block_info

  u_bool_array_3d:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_bool_array(z, y, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[z, y, x]'
      block_info:
        value: instance.block_info

  u_bool_array:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
      - id: ctx
        type: array_context(z, y, x)
    instances:
      v:
        value: instance.v
      instance:
        io: _io
        pos: pos.value
        type: u_bool_array_internal
        parent: ctx
      alignment:
        value: 2
      padding:
        value: 0
      size:
        value: (((z * y * x) + 15) / 16) * 2
      block_info:
        type: block_info(pos.value, size, pos.value, 'b1', z * y * x)

  u_bool_array_internal:
    seq:
      - id: v
        size: ((_parent.as<array_context>.length + 15) / 16) * 2
        type: u_bool_array_internal_d1
        parent: _parent.as<array_context>

  u_bool_array_internal_d1:
    seq:
      - id: v
        type: u_bool_array_internal_d2
        repeat: expr
        repeat-expr: _parent.as<array_context>.z
        parent: _parent.as<array_context>

  u_bool_array_internal_d2:
    seq:
      - id: v
        type: u_bool_array_internal_d3
        repeat: expr
        repeat-expr: _parent.as<array_context>.y
        parent: _parent.as<array_context>

  u_bool_array_internal_d3:
    seq:
      - id: v
        type: b1
        repeat: expr
        repeat-expr: _parent.as<array_context>.x

  u_bool_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_bool_array_flat(1, 1, x)
    instances:
      v:
        value: instance.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        value: instance.block_info

  u_bool_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_bool_array_flat(1, y, x)
    instances:
      v:
        value: instance.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        value: instance.block_info

  u_bool_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_bool_array_flat(z, y, x)
    instances:
      v:
        value: instance.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        value: instance.block_info

  u_bool_array_flat:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
      - id: ctx
        type: array_context(z, y, x)
    instances:
      v:
        value: instance.v
      instance:
        io: _io
        pos: pos.value
        type: u_bool_array_flat_internal
        parent: ctx
      alignment:
        value: 2
      padding:
        value: 0
      size:
        value: (((z * y * x) + 15) / 16) * 2
      block_info:
        type: block_info(pos.value, size, pos.value, 'b1', z * y * x)

  u_bool_array_flat_internal:
    seq:
      - id: v
        type: b1
        repeat: expr
        repeat-expr: _parent.as<array_context>.length

  u_byte:
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u1
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: alignment + padding
      block_info:
        type: block_info(pos.value, size, pos.value, 'u1', 0)

  u_byte_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_byte_array(1, 1, x)
    instances:
      v:
        value: instance.v.v[0].v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[x]'
      block_info:
        value: instance.block_info

  u_byte_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_byte_array(1, y, x)
    instances:
      v:
        value: instance.v.v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[y, x]'
      block_info:
        value: instance.block_info

  u_byte_array_3d:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_byte_array(z, y, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[z, y, x]'
      block_info:
        value: instance.block_info

  u_byte_array:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
      - id: ctx
        type: array_context(z, y, x)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u_byte_array_internal_d1
        parent: ctx
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + alignment * z * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u1', z * y * x)

  u_byte_array_internal_d1:
    seq:
      - id: v
        type: u_byte_array_internal_d2
        repeat: expr
        repeat-expr: _parent.as<array_context>.z
        parent: _parent.as<array_context>

  u_byte_array_internal_d2:
    seq:
      - id: v
        type: u_byte_array_internal_d3
        repeat: expr
        repeat-expr: _parent.as<array_context>.y
        parent: _parent.as<array_context>

  u_byte_array_internal_d3:
    seq:
      - id: v
        type: u1
        repeat: expr
        repeat-expr: _parent.as<array_context>.x

  u_byte_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u1
        repeat: expr
        repeat-expr: x + 0
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + alignment * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u1', x)

  u_byte_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u1
        repeat: expr
        repeat-expr: y * x
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + alignment * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u1', y * x)

  u_byte_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u1
        repeat: expr
        repeat-expr: z * y * x
      alignment:
        value: 1
      padding:
        value: 0
      size:
        value: padding + alignment * z * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u1', z * y * x)

  u_word:
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u2
      alignment:
        value: 2
      padding:
        value: 0
      size:
        value: alignment + padding
      block_info:
        type: block_info(pos.value, size, pos.value, 'u2', 0)

  u_word_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_word_array(1, 1, x)
    instances:
      v:
        value: instance.v.v[0].v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[x]'
      block_info:
        value: instance.block_info

  u_word_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_word_array(1, y, x)
    instances:
      v:
        value: instance.v.v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[y, x]'
      block_info:
        value: instance.block_info

  u_word_array_3d:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_word_array(z, y, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[z, y, x]'
      block_info:
        value: instance.block_info

  u_word_array:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
      - id: ctx
        type: array_context(z, y, x)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u_word_array_internal_d1
        parent: ctx
      alignment:
        value: 2
      padding:
        value: 0
      size:
        value: padding + alignment * z * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u2', z * y * x)

  u_word_array_internal_d1:
    seq:
      - id: v
        type: u_word_array_internal_d2
        repeat: expr
        repeat-expr: _parent.as<array_context>.z
        parent: _parent.as<array_context>

  u_word_array_internal_d2:
    seq:
      - id: v
        type: u_word_array_internal_d3
        repeat: expr
        repeat-expr: _parent.as<array_context>.y
        parent: _parent.as<array_context>

  u_word_array_internal_d3:
    seq:
      - id: v
        type: u2
        repeat: expr
        repeat-expr: _parent.as<array_context>.x

  u_word_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u2
        repeat: expr
        repeat-expr: x + 0
      alignment:
        value: 2
      padding:
        value: 0
      size:
        value: padding + alignment * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u2', x)

  u_word_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u2
        repeat: expr
        repeat-expr: y * x
      alignment:
        value: 2
      padding:
        value: 0
      size:
        value: padding + alignment * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u2', y * x)

  u_word_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u2
        repeat: expr
        repeat-expr: z * y * x
      alignment:
        value: 2
      padding:
        value: 0
      size:
        value: padding + alignment * z * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u2', z * y * x)

  u_dword:
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u4
      alignment:
        value: 4
      padding:
        value: 0
      size:
        value: alignment + padding
      block_info:
        type: block_info(pos.value, size, pos.value, 'u4', 0)

  u_dword_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_dword_array(1, 1, x)
    instances:
      v:
        value: instance.v.v[0].v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[x]'
      block_info:
        value: instance.block_info

  u_dword_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_dword_array(1, y, x)
    instances:
      v:
        value: instance.v.v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[y, x]'
      block_info:
        value: instance.block_info

  u_dword_array_3d:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_dword_array(z, y, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[z, y, x]'
      block_info:
        value: instance.block_info

  u_dword_array:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
      - id: ctx
        type: array_context(z, y, x)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u_dword_array_internal_d1
        parent: ctx
      alignment:
        value: 4
      padding:
        value: 0
      size:
        value: padding + alignment * z * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u4', z * y * x)

  u_dword_array_internal_d1:
    seq:
      - id: v
        type: u_dword_array_internal_d2
        repeat: expr
        repeat-expr: _parent.as<array_context>.z
        parent: _parent.as<array_context>

  u_dword_array_internal_d2:
    seq:
      - id: v
        type: u_dword_array_internal_d3
        repeat: expr
        repeat-expr: _parent.as<array_context>.y
        parent: _parent.as<array_context>

  u_dword_array_internal_d3:
    seq:
      - id: v
        type: u4
        repeat: expr
        repeat-expr: _parent.as<array_context>.x

  u_dword_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u4
        repeat: expr
        repeat-expr: x + 0
      alignment:
        value: 4
      padding:
        value: 0
      size:
        value: padding + alignment * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u4', x)

  u_dword_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u4
        repeat: expr
        repeat-expr: y * x
      alignment:
        value: 4
      padding:
        value: 0
      size:
        value: padding + alignment * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u4', y * x)

  u_dword_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u4
        repeat: expr
        repeat-expr: z * y * x
      alignment:
        value: 4
      padding:
        value: 0
      size:
        value: padding + alignment * z * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u4', z * y * x)

  u_lword:
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u8
      alignment:
        value: 8
      padding:
        value: 0
      size:
        value: alignment + padding
      block_info:
        type: block_info(pos.value, size, pos.value, 'u8', 0)

  u_lword_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_lword_array(1, 1, x)
    instances:
      v:
        value: instance.v.v[0].v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[x]'
      block_info:
        value: instance.block_info

  u_lword_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_lword_array(1, y, x)
    instances:
      v:
        value: instance.v.v[0].v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[y, x]'
      block_info:
        value: instance.block_info

  u_lword_array_3d:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: instance
        type: u_lword_array(z, y, x)
    instances:
      v:
        value: instance.v.v
      alignment:
        value: instance.alignment
      padding:
        value: instance.padding
      size:
        value: instance.size
      cardinalities:
        value: '[z, y, x]'
      block_info:
        value: instance.block_info

  u_lword_array:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
      - id: ctx
        type: array_context(z, y, x)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u_lword_array_internal_d1
        parent: ctx
      alignment:
        value: 8
      padding:
        value: 0
      size:
        value: padding + alignment * z * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u8', z * y * x)

  u_lword_array_internal_d1:
    seq:
      - id: v
        type: u_lword_array_internal_d2
        repeat: expr
        repeat-expr: _parent.as<array_context>.z
        parent: _parent.as<array_context>

  u_lword_array_internal_d2:
    seq:
      - id: v
        type: u_lword_array_internal_d3
        repeat: expr
        repeat-expr: _parent.as<array_context>.y
        parent: _parent.as<array_context>

  u_lword_array_internal_d3:
    seq:
      - id: v
        type: u8
        repeat: expr
        repeat-expr: _parent.as<array_context>.x

  u_lword_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u8
        repeat: expr
        repeat-expr: x + 0
      alignment:
        value: 8
      padding:
        value: 0
      size:
        value: padding + alignment * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u8', x)

  u_lword_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u8
        repeat: expr
        repeat-expr: y * x
      alignment:
        value: 8
      padding:
        value: 0
      size:
        value: padding + alignment * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u8', y * x)

  u_lword_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: pos
        type: pos_capturer(_io.pos)
    instances:
      v:
        io: _io
        pos: pos.value
        type: u8
        repeat: expr
        repeat-expr: z * y * x
      alignment:
        value: 8
      padding:
        value: 0
      size:
        value: padding + alignment * z * y * x
      block_info:
        type: block_info(pos.value, size, pos.value, 'u8', z * y * x)
