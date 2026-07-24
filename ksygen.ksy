# Copyright (c) 2026 KITA Munemitsu
# This script is released under the GNU General Public License v3.0.
# SPDX-License-Identifier: GPL-3.0-or-later

meta:
  id: ksygen
  title: KSY generator for NJ ksy
  application:
    - Sysmac Studio
  license: GPL-3.0-or-later
  ks-version: 0.11
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le

enums:
  ksy_element_type:
    0: empty
    1: meta
    2: imports
    4: params
    8: seq
    16: instances
    32: types

types:
  # Constant
  consts:
    instances:
      utypes:
        value: >-
          '"single_block":{"params":[{"id":"len_block","type":"u2"},{"id":"as_stream","type":"b1"}],"seq":[{"id":"stream_block","type":"block(len_block)","size":"len_block + 0","if":"as_stream"},{"id":"block","type":"block(len_block)","if":"not as_stream"}],"instances":{"io_block":{"value":"as_stream ? stream_block._io : block._io"}}},"block":{"params":[{"id":"len_mem","type":"u2"}],"seq":[{"id":"mem","size":"len_mem"}]},"bool":{"seq":[{"id":"value","type":"b1"}]},"bools":{"params":[{"id":"num_value","type":"u2"}],"seq":[{"id":"value","type":"b1","repeat":"expr","repeat-expr":"num_value"}]}'

  # Generate light KSY as json from structure information.
  to_ksy:
    params:
      - id: info
        # type: nj::struct_info
        type: nj::container_info
      - id: view_suffix
        type: str
        doc: View-type suffix.
      - id: compact
        type: b1
        doc: Whether to generate as a single file.
    seq:
      - id: ctx
        type: to_ksy_context(info, view_suffix, compact)
    instances:
      members:
        type: to_ksy_member(ctx.info.field_ids[_index], ctx.info.field_infos[_index], compact)
        repeat: expr
        repeat-expr: ctx.info.field_ids.size
      join:
        type: ksy_member_joiner(members, 0)
      lazy_eval_ksy:
        type: to_block_view_ksy(ctx, join.view_member, join.view_accessor)
      immediate_eval_ksy:
        type: to_seq_ksy(ctx, join.seq_member)
  
  to_ksy_context:
    params:
      - id: info
        # type: nj::struct_info
        type: nj::container_info
      - id: p_view_suffix
        type: str
      - id: compact
        type: b1
    instances:
      view_suffix:
        value: >-
          p_view_suffix != '' ? p_view_suffix : '_view'
      id:
        value: >-
          info.struct_type
      id_view:
        value: >-
          id + view_suffix
      is_root:
        value: true

  # Generates members of the view type and stream consumption type.
  ksy_member_joiner:
    params:
      - id: values
        type: to_ksy_member[]
      - id: i
        type: u4
    instances:
      next_element:
        type: ksy_member_joiner(values, i + 1)
        if: values.size - i > 1
      view_accessor:
        value: >-
          (
          (i > 0 ? ',' : '')
          + (values[i].view_accessor + (values.size - i > 1 ? next_element.view_accessor : ''))
          ).as<str>
      view_member:
        value: >-
          (
          (i > 0 ? ',' : '')
          + (values[i].view_member + (values.size - i > 1 ? next_element.view_member : ''))
          ).as<str>
      seq_member:
        value: >-
          (
          (i > 0 ? ',' : '')
          + (values[i].seq_member + (values.size - i > 1 ? next_element.seq_member : ''))
          ).as<str>

  to_ksy_member:
    params:
      - id: id
        type: str
      - id: info
        type: nj::block_info
      - id: compact
        type: b1
    instances:
      to_ksy_view_member:
        type: to_ksy_view_member(id, info, compact)
      to_ksy_seq_member:
        type: to_ksy_seq_member(id, info)
      view_member:
        value: to_ksy_view_member.value
      view_accessor:
        value: to_ksy_view_member.accessor
      seq_member:
        value: to_ksy_seq_member.value

  # Generate a KSY of the view type.
  to_block_view_ksy:
    params:
      - id: ctx
        type: to_ksy_context
      - id: members
        type: str
      - id: accessors
        type: str
    instances:
      consts:
        type: consts
      get_view_type:
        value: >-
          '"' + ctx.id_view + '":{'
          + '"params":[{"id":"block","type":"io"}],'
          + '"instances":{'
          + members
          + '}'
      get_align_element:
        value: >-
          '{"type":"u1","repeat":"expr","repeat-expr":"'
          + '(' + ctx.info.alignment.to_s + ' - (_io.pos % ' + ctx.info.alignment.to_s + ')) % ' + ctx.info.alignment.to_s
          + '"}'
      get_seq:
        value: >-
          '"seq":['
          + get_align_element + ','
          + '{"id":"block","type":'
          + (ctx.compact ? '"' : '"utypes::') + 'single_block(' + (ctx.info.data_size + ctx.info.tail_padding).to_s + ',true)"}]'
      get_instances:
        value: >-
          '"instances":{'
          '"view":{"type":"' + ctx.id_view + '(block.io_block)"},'
          + accessors
          + '}'
      get_types:
        value: >-
          '"types":{'
          + '"' + ctx.id_view + '":{'
          + '"params":[{"id":"block","type":"io"}],'
          + '"instances":{'
          + members
          + '}}'
          + (ctx.compact ? (',' + consts.utypes) : '')
          + '}'
      value:
        value: >-
          '{"meta":{"id":"' + ctx.id + '",'
          + (ctx.compact ? '' : '"imports":["utypes"],')
          + '"-alloc-size":' + ctx.info.size.to_s + ','
          + '"-size":' + ctx.info.data_size.to_s + ','
          + '"-alignment":' + ctx.info.alignment.to_s + ','
          + '"encoding":"UTF-8","endian":"le","bit-endian":"le"},'
          + get_seq + ','
          + get_instances + ','
          + get_types +
          + '}'

  to_ksy_view_member:
    params:
      - id: key
        type: str
      - id: info
        type: nj::block_info
      - id: compact
        type: b1
    instances:
      accessor:
        value: >-
          '"' + key + '":{"value":"view.' + key + (info.ks_type == 'b1' ? '.value' : '') + '"}'
      get_b1_type:
        value: >-
          '"size":' + (info.num_repeat > 0 ? (((info.num_repeat + 15) / 16) * 2) : 2).to_s + ',"type":"' + (compact ? '' : 'utypes::') + (info.num_repeat > 0 ? 'bools(' + info.num_repeat.to_s + ')' : 'bool') + '"'
      get_str_type:
        value: >-
          '"type":"str","terminator":0,"encoding":"UTF-8","size":' + info.num_repeat.to_s + ''
      get_repeat_type:
        value: >-
          '"type":"' + info.ks_type + '","repeat":"expr","repeat-expr":' + info.num_repeat.to_s + ''
      get_default_type:
        value: >-
          '"type":"' + info.ks_type + '"'
      get_type:
        value: >-
          '' + (info.ks_type == 'b1' ? get_b1_type : (info.ks_type == 'str' ? get_str_type : (info.num_repeat > 0 ? get_repeat_type : get_default_type))) + ''
      value:
        value: >-
          '"' + key + '":'
          + '{"io":"block",'
          + '"pos":' + info.pos_data.to_s + ','
          + get_type
          + '}'

  to_seq_ksy:
    params:
      - id: ctx
        type: to_ksy_context
      - id: members
        type: str
    instances:
      get_align_element:
        value: >-
          ctx.info.alignment < 2 ? '' :
          '{"type":"u1","repeat":"expr","repeat-expr":"'
          + '(' + ctx.info.alignment.to_s + ' - (_io.pos % ' + ctx.info.alignment.to_s + ')) % ' + ctx.info.alignment.to_s + ''
          + '"},'
      get_tail_pad_element:
        value: >-
          ctx.info.tail_padding < 1 ? '' :
          ',{"type":"u1","repeat":"expr","repeat-expr":' + ctx.info.tail_padding.to_s + '}'
      value:
        value: >-
          '{"meta":{"id":"' + ctx.id + '",'
          + '"-alloc-size":' + ctx.info.size.to_s + ','
          + '"-size":' + ctx.info.data_size.to_s + ','
          + '"-alignment":' + ctx.info.alignment.to_s + ','
          + '"encoding":"UTF-8","endian":"le","bit-endian":"le"},'
          + '"seq":['
          + get_align_element
          + members
          + get_tail_pad_element
          + ']}'

  to_ksy_seq_member:
    params:
      - id: key
        type: str
      - id: info
        type: nj::block_info
    instances:
      get_str_type:
        value: >-
          '"type":"str","terminator":0,"encoding":"UTF-8","size":' + info.num_repeat.to_s
      get_repeat_type:
        value: >-
          '"type":"' + info.ks_type + '","repeat":"expr","repeat-expr":' + info.num_repeat.to_s
      get_default_type:
        value: >-
          '"type":"' + info.ks_type + '"'
      get_type:
        value: >-
          (info.ks_type == 'str' ? get_str_type : (info.num_repeat > 0 ? get_repeat_type : get_default_type))
      value:
        value: >-
          (info.space > 0 ? '{"size":' + info.space.to_s + '},' : '')
          + '{"id":"' + key + '",'
          + get_type +
          + '}'
          + ((info.ks_type == 'b1' and (info.num_repeat % 16 > 0 or info.num_repeat < 1)) ? ',{"type":"u1"}' : '')

  # Chained KSY Generator

  ksy_element_chain:
    params:
      - id: type
        type: u1
        enum: ksy_element_type
      - id: value
        type: str
      - id: prev
        type: struct
    instances:
      chain:
        value: prev.as<ksy_element_chain>
        if: type != ksy_element_type::empty
      chain_root:
        value: >-
          (type != ksy_element_type::empty ? chain.chain_root : prev).as<ksy_element_chain_root>
      chain_depth:
        value: >-
          (type != ksy_element_type::empty ? chain.chain_depth + 1 : 0).as<u4>
      meta:
        value: >-
          type == ksy_element_type::empty ? '' :
          (type != ksy_element_type::meta ? chain.meta : (chain.meta != '' ? chain.meta + ',' : '') + value).as<str>
      imports:
        value: >-
          type == ksy_element_type::empty ? '' :
          (type != ksy_element_type::imports ? chain.imports : (chain.imports != '' ? chain.imports + ',' : '') + value).as<str>
      params:
        value: >-
          type == ksy_element_type::empty ? '' :
          (type != ksy_element_type::params ? chain.params : (chain.params != '' ? chain.params + ',' : '') + value).as<str>
      seq:
        value: >-
          type == ksy_element_type::empty ? '' :
          (type != ksy_element_type::seq ? chain.seq : (chain.seq != '' ? chain.seq + ',' : '') + value).as<str>
      instances:
        value: >-
          type == ksy_element_type::empty ? '' :
          (type != ksy_element_type::instances ? chain.instances : (chain.instances != '' ? chain.instances + ',' : '') + value).as<str>
      types:
        value: >-
          type == ksy_element_type::empty ? '' :
          (type != ksy_element_type::types ? chain.types : (chain.types != '' ? chain.types + ',' : '') + value).as<str>

  ksy_meta:
    params:
      - id: value
        type: str
      - id: prev
        type: struct
    seq:
      - id: chain
        type: ksy_element_chain(ksy_element_type::meta, value, prev)

  ksy_imports:
    params:
      - id: value
        type: str
      - id: prev
        type: struct
    seq:
      - id: chain
        type: ksy_element_chain(ksy_element_type::imports, value, prev)

  ksy_params:
    params:
      - id: value
        type: str
      - id: prev
        type: struct
    seq:
      - id: chain
        type: ksy_element_chain(ksy_element_type::params, value, prev)

  ksy_seq:
    params:
      - id: value
        type: str
      - id: prev
        type: struct
    seq:
      - id: chain
        type: ksy_element_chain(ksy_element_type::seq, value, prev)

  ksy_instances:
    params:
      - id: value
        type: str
      - id: prev
        type: struct
    seq:
      - id: chain
        type: ksy_element_chain(ksy_element_type::instances, value, prev)

  ksy_types:
    params:
      - id: value
        type: str
      - id: prev
        type: struct
    seq:
      - id: chain
        type: ksy_element_chain(ksy_element_type::types, value, prev)

  ksy_element_shallow_copy:
    params:
      - id: source
        type: ksy_element_chain
      - id: prev
        type: struct
    seq:
      - id: chain
        type: ksy_element_chain(source.type, source.value, prev)

  ksy_element_chain_root:
    params:
      - id: key
        type: str

  ksy_element_chain_begin:
    params:
      - id: key
        type: str
    seq:
      - id: root
        type: ksy_element_chain_root(key)
      - id: chain
        type: ksy_element_chain(ksy_element_type::empty, '', root)

  ksy_element_chain_end:
    params:
      - id: chain
        type: ksy_element_chain
    instances:
      chain_root:
        value: chain.chain_root
      chain_depth:
        value: chain.chain_depth
      meta:
        value: chain.meta
      imports:
        value: chain.imports
      params:
        value: chain.params
      seq:
        value: chain.seq
      instances:
        value: chain.instances
      types:
        value: chain.types
      ksy_element_chain_to_ksy:
        type: ksy_element_chain_to_ksy(chain)
      to_ksy:
        value: ksy_element_chain_to_ksy.value
      ksy_element_chain_to_ksy_type:
        type: ksy_element_chain_to_ksy_type(chain)
      to_ksy_type:
        value: ksy_element_chain_to_ksy_type.value

  ksy_element_chain_to_ksy:
    params:
      - id: chain
        type: ksy_element_chain
    instances:
      value:
        value: >-
          '{'
          + '"meta":{'
          + '"id":"' + chain.chain_root.key + '"'
          + (chain.meta != '' ? ',' + chain.meta : '')
          + (chain.imports != '' ? ',"imports":[' + chain.imports + ']' : '')
          + '}'
          + (chain.params != '' ? ',"params":[' + chain.params + ']' : '')
          + (chain.seq != '' ? ',"seq":[' + chain.seq + ']' : '')
          + (chain.instances != '' ? ',"instances":{' + chain.instances + '}' : '')
          + (chain.types != '' ? ',"types":{' + chain.types + '}' : '')
          + '}'

  ksy_element_chain_to_ksy_type:
    params:
      - id: chain
        type: ksy_element_chain
    instances:
      value:
        value: >-
          + '"' + chain.chain_root.key + '":{'
          + (chain.params != '' ? '"params":[' + chain.params + ']' : '')
          + (chain.params != '' ? ',' : '')
          + (chain.seq != '' ? '"seq":[' + chain.seq + ']' : '')
          + (chain.seq != '' ? ',' : '')
          + (chain.instances != '' ? '"instances":{' + chain.instances + '}' : '')
          + '}'
