meta:
  id: example_struct
  license: GPL-3.0-or-later
  imports:
    - ../nj
    - ../ksygen
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  - id: struct_begin
    type: nj::struct_begin('example_struct', 8)

  - id: vel
    type: nj::lreal
  - id: trq
    type: nj::lreal
  - id: acc
    type: nj::lreal
  - id: status_code
    type: nj::dword

  - id: struct_end
    type: nj::struct_end(struct_begin)
instances:
  block_info:
    value: struct_end.struct_block_info
  
  fields:
    type: fields
  struct_info:
    type: >-
      nj::struct_info(
        struct_end,
        ['vel', 'trq', 'acc', 'status_code'],
        [vel.block_info, trq.block_info, acc.block_info, status_code.block_info]
      )
  to_ksy:
    type: ksygen::to_ksy(struct_info.as_container_info, '_view', true)
  lazy_eval_ksy:
    value: to_ksy.lazy_eval_ksy.value
  immediate_eval_ksy:
    value: to_ksy.immediate_eval_ksy.value

types:
  fields:
    instances:
      vel:
        value: _parent.vel.v
      trq:
        value: _parent.trq.v
      acc:
        value: _parent.acc.v
      status_code:
        value: _parent.status_code.v
